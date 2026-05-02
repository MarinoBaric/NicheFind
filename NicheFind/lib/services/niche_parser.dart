import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../models/niche_suggestion.dart';

class NicheParseException implements Exception {
  final String message;
  final String rawResponse;

  const NicheParseException(this.message, this.rawResponse);

  @override
  String toString() => 'NicheParseException: $message';
}

class NicheParser {
  const NicheParser();

  List<NicheSuggestion> parse(String raw) {
    if (kDebugMode) {
      developer.log(
        raw,
        name: 'NicheParser.raw',
        level: 500,
      );
    }

    final cleaned = _stripCodeFences(raw).trim();
    if (cleaned.isEmpty) {
      throw NicheParseException('Empty response from DeepSeek', raw);
    }

    try {
      return _parseJson(cleaned);
    } on FormatException catch (_) {
      final extracted = _extractJsonObject(cleaned);
      if (extracted != null) {
        try {
          return _parseJson(extracted);
        } on FormatException catch (_) {}
      }
      final markdown = _parseMarkdown(cleaned);
      if (markdown.isNotEmpty) return markdown;
      throw NicheParseException(
        'Could not parse response as JSON or markdown',
        raw,
      );
    } on NicheParseException {
      rethrow;
    } catch (e) {
      throw NicheParseException('Unexpected parser error: $e', raw);
    }
  }

  List<NicheSuggestion> _parseJson(String input) {
    final decoded = jsonDecode(input);
    final List<dynamic> items;

    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final candidate = decoded['niches'] ??
          decoded['suggestions'] ??
          decoded['results'] ??
          decoded['data'];
      if (candidate is List) {
        items = candidate;
      } else {
        items = [decoded];
      }
    } else {
      throw const FormatException('Unexpected payload shape');
    }

    final niches = items
        .whereType<Map<String, dynamic>>()
        .map(NicheSuggestion.fromJson)
        .toList();

    if (niches.isEmpty) {
      throw const FormatException('No niches found in JSON payload');
    }
    return niches;
  }

  String _stripCodeFences(String input) {
    final fenced = RegExp(r'```(?:[a-zA-Z0-9_-]+)?\s*([\s\S]*?)```');
    final match = fenced.firstMatch(input);
    if (match != null) {
      final inner = match.group(1)?.trim() ?? '';
      if (inner.isNotEmpty) return inner;
    }
    return input;
  }

  String? _extractJsonObject(String input) {
    final startObj = input.indexOf('{');
    final startArr = input.indexOf('[');
    int start;
    String open;
    String close;
    if (startObj == -1 && startArr == -1) return null;
    if (startObj == -1 || (startArr != -1 && startArr < startObj)) {
      start = startArr;
      open = '[';
      close = ']';
    } else {
      start = startObj;
      open = '{';
      close = '}';
    }

    int depth = 0;
    bool inString = false;
    bool escape = false;
    for (var i = start; i < input.length; i++) {
      final ch = input[i];
      if (inString) {
        if (escape) {
          escape = false;
        } else if (ch == r'\') {
          escape = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }
      if (ch == '"') {
        inString = true;
      } else if (ch == open) {
        depth++;
      } else if (ch == close) {
        depth--;
        if (depth == 0) return input.substring(start, i + 1);
      }
    }
    return null;
  }

  List<NicheSuggestion> _parseMarkdown(String input) {
    final lines = input.split('\n');
    final blocks = <List<String>>[];
    List<String>? current;

    for (final line in lines) {
      final headingMatch = RegExp(r'^\s*#{1,6}\s+(.+)$').firstMatch(line);
      final numberedMatch =
          RegExp(r'^\s*\d+[\.\)]\s+\*{0,2}([^\*].+)\*{0,2}$').firstMatch(line);
      if (headingMatch != null || numberedMatch != null) {
        if (current != null && current.isNotEmpty) blocks.add(current);
        final title = (headingMatch ?? numberedMatch)!.group(1)!.trim();
        current = ['__title__: $title'];
        continue;
      }
      if (current != null) current.add(line);
    }
    if (current != null && current.isNotEmpty) blocks.add(current);

    final suggestions = <NicheSuggestion>[];
    for (final block in blocks) {
      final niche = _blockToNiche(block);
      if (niche != null) suggestions.add(niche);
    }
    return suggestions;
  }

  NicheSuggestion? _blockToNiche(List<String> block) {
    String title = '';
    final desc = StringBuffer();
    String demand = '-';
    String competition = '-';
    final steps = <String>[];

    String section = 'description';
    bool inSteps = false;

    for (final raw in block) {
      final line = raw.trim();
      if (line.startsWith('__title__:')) {
        title = line.substring('__title__:'.length).trim();
        continue;
      }
      if (line.isEmpty) continue;

      final labelMatch = RegExp(
        r'^[*_-]*\s*(description|summary|demand|competition|first\s*steps|steps)\s*[*_]*\s*[:\-]\s*(.*)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (labelMatch != null) {
        final label = labelMatch.group(1)!.toLowerCase().replaceAll(' ', '');
        final value = labelMatch.group(2)!.trim();
        inSteps = false;
        switch (label) {
          case 'description':
          case 'summary':
            section = 'description';
            if (value.isNotEmpty) desc.writeln(value);
            break;
          case 'demand':
            section = 'demand';
            if (value.isNotEmpty) demand = value;
            break;
          case 'competition':
            section = 'competition';
            if (value.isNotEmpty) competition = value;
            break;
          case 'firststeps':
          case 'steps':
            section = 'steps';
            inSteps = true;
            if (value.isNotEmpty) steps.add(value);
            break;
        }
        continue;
      }

      final bullet = RegExp(r'^\s*(?:[-*•]|\d+[\.\)])\s+(.*)$').firstMatch(line);
      if (bullet != null) {
        final value = bullet.group(1)!.trim();
        if (section == 'steps' || inSteps) {
          steps.add(value);
        } else if (section == 'description') {
          desc.writeln(value);
        }
        continue;
      }

      switch (section) {
        case 'description':
          desc.writeln(line);
          break;
        case 'demand':
          demand = '$demand $line'.trim();
          break;
        case 'competition':
          competition = '$competition $line'.trim();
          break;
        case 'steps':
          steps.add(line);
          break;
      }
    }

    if (title.isEmpty) return null;
    return NicheSuggestion(
      title: title,
      description: desc.toString().trim(),
      demand: demand,
      competition: competition,
      firstSteps: steps,
    );
  }
}
