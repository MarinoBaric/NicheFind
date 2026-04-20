import '../models/questionnaire_data.dart';
import '../models/niche_suggestion.dart';

class DeepSeekService {
  Future<List<NicheSuggestion>> generateNiches(QuestionnaireData data) async {
    // TODO: Build prompt from questionnaire data, call DeepSeek API, parse response
    throw UnimplementedError();
  }

  Future<List<NicheSuggestion>> regenerateNiches(QuestionnaireData data) async {
    // TODO: Call DeepSeek again with same data for fresh suggestions
    throw UnimplementedError();
  }

  Future<List<NicheSuggestion>> refineNiches(
    QuestionnaireData data,
    String refinementPrompt,
  ) async {
    // TODO: Send follow-up refinement request to DeepSeek
    throw UnimplementedError();
  }
}
