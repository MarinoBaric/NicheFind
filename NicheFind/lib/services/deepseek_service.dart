import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/niche_suggestion.dart';
import '../models/questionnaire_data.dart';
import 'niche_exceptions.dart';
import 'niche_parser.dart';
import 'prompt_builder.dart';

class DeepSeekService {
  DeepSeekService({
    PromptBuilder? promptBuilder,
    NicheParser? parser,
    Connectivity? connectivity,
    http.Client? client,
    Duration? timeout,
  })  : _prompts = promptBuilder ?? PromptBuilder(),
        _parser = parser ?? const NicheParser(),
        _connectivity = connectivity ?? Connectivity(),
        _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 30);

  final PromptBuilder _prompts;
  final NicheParser _parser;
  final Connectivity _connectivity;
  final http.Client _client;
  final Duration _timeout;

  static const String _endpoint = '/chat/completions';
  static const String _model = 'deepseek-chat';

  Future<List<NicheSuggestion>> generateNiches(QuestionnaireData data) {
    return _run(_prompts.buildUserPrompt(data));
  }

  Future<List<NicheSuggestion>> regenerateNiches(
    QuestionnaireData data, {
    List<NicheSuggestion> previousResults = const [],
  }) {
    final base = _prompts.buildUserPrompt(data);
    final hint = _prompts.buildRegeneratePrompt(previousResults);
    return _run('$base\n\n$hint');
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
    await _ensureOnline();
    final raw = await _chat(_prompts.buildSystemPrompt(), userPrompt);
    try {
      return _parser.parse(raw);
    } on NicheParseException catch (e) {
      throw NicheException.parse(details: e.message);
    }
  }

  Future<void> _ensureOnline() async {
    try {
      final result = await _connectivity
          .checkConnectivity()
          .timeout(const Duration(seconds: 3));
      final results = result;
      final offline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (offline) throw NicheException.offline();
    } on TimeoutException {
      // If connectivity check times out, fall through and let the request try.
    } on NicheException {
      rethrow;
    } catch (_) {
      // Ignore other connectivity check failures and let HTTP report it.
    }
  }

  Future<String> _chat(String systemPrompt, String userPrompt) async {
    final uri = Uri.parse('${ApiConfig.deepSeekBaseUrl}$_endpoint');
    http.Response response;
    try {
      response = await _client
          .post(
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
          )
          .timeout(_timeout);
    } on SocketException {
      throw NicheException.offline();
    } on HttpException {
      throw NicheException.server(details: 'HTTP exception');
    } on TimeoutException {
      throw NicheException.server(details: 'Request timed out');
    } catch (e) {
      throw NicheException.unknown(details: e.toString());
    }

    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return _extractContent(response.body);
    }
    if (status >= 400 && status < 500) {
      throw NicheException.badRequest(details: 'HTTP $status');
    }
    throw NicheException.server(details: 'HTTP $status');
  }

  String _extractContent(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw NicheException.parse(details: 'No choices in response');
      }
      final message = choices.first['message'] as Map<String, dynamic>;
      return (message['content'] as String?) ?? '';
    } on NicheException {
      rethrow;
    } catch (e) {
      throw NicheException.parse(details: 'Malformed envelope: $e');
    }
  }
}
