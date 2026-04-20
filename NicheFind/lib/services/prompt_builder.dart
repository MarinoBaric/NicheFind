import '../models/questionnaire_data.dart';

class PromptBuilder {
  String buildSystemPrompt() {
    // TODO: Return the system prompt that instructs DeepSeek how to respond
    throw UnimplementedError();
  }

  String buildUserPrompt(QuestionnaireData data) {
    // TODO: Build a structured user prompt from questionnaire answers
    throw UnimplementedError();
  }

  String buildRefinementPrompt(String userFeedback) {
    // TODO: Build a follow-up prompt for refining previous results
    throw UnimplementedError();
  }
}
