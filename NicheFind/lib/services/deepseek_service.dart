import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/questionnaire_data.dart';
import '../models/niche_suggestion.dart';
import 'prompt_builder.dart';

class DeepSeekService {
  DeepSeekService({PromptBuilder? promptBuilder, http.Client? client})
      : _prompts = promptBuilder ?? PromptBuilder(),
        _client = client ?? http.Client();

  final PromptBuilder _prompts;
  final http.Client _client;

  static const String _endpoint = '/chat/completions';
  static const String _model = 'deepseek-chat';

  Future<List<NicheSuggestion>> generateNiches(QuestionnaireData data) {
    return _run(_prompts.buildUserPrompt(data));
  }

  Future<List<NicheSuggestion>> regenerateNiches(QuestionnaireData data) {
    final base = _prompts.buildUserPrompt(data);
    return _run(
      '$base\n\nProvide a different set of niches than the obvious ones. '
      'Vary the angles and combinations.',
    );
  }

  Future<List<NicheSuggestion>> refineNiches(
    QuestionnaireData data,
    String refinementPrompt,
  ) {
    final base = _prompts.buildUserPrompt(data);
    final refine = _prompts.buildRefinementPrompt(refinementPrompt);
    return _run('$base\n\n$refine');
  }

  Future<List<NicheSuggestion>> _run(String userPrompt) async {
    final raw = await _chat(_prompts.buildSystemPrompt(), userPrompt);
    return _parseSuggestions(raw);
  }

  Future<String> _chat(String systemPrompt, String userPrompt) async {
    final uri = Uri.parse('${ApiConfig.deepSeekBaseUrl}$_endpoint');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.deepSeekApiKey}',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.8,
        'response_format': {'type': 'json_object'},
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'DeepSeek request failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('DeepSeek returned no choices');
    }
    final message = choices.first['message'] as Map<String, dynamic>;
    return (message['content'] as String?) ?? '';
  }

  List<NicheSuggestion> _parseSuggestions(String raw) {
    final cleaned = _stripCodeFences(raw).trim();
    if (cleaned.isEmpty) {
      throw const FormatException('Empty response from DeepSeek');
    }

    final decoded = jsonDecode(cleaned);

    List<dynamic> items;
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
      throw const FormatException('Unexpected DeepSeek payload shape');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(NicheSuggestion.fromJson)
        .toList();
  }

  String _stripCodeFences(String input) {
    final fenced = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = fenced.firstMatch(input);
    return match?.group(1) ?? input;
  }
}
