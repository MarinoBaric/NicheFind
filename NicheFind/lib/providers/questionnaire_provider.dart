import 'package:flutter/material.dart';
import '../models/questionnaire_data.dart';
import '../models/niche_suggestion.dart';
import '../services/deepseek_service.dart';

class QuestionnaireProvider extends ChangeNotifier {
  final QuestionnaireData _data = QuestionnaireData();
  List<NicheSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  QuestionnaireData get data => _data;
  List<NicheSuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setInterests(List<String> interests) {
    // TODO: Update interests and notify listeners
    throw UnimplementedError();
  }

  void setGoal(String goal) {
    // TODO: Update goal and notify listeners
    throw UnimplementedError();
  }

  void setSkillLevel(String level) {
    // TODO: Update skill level and notify listeners
    throw UnimplementedError();
  }

  void setTimeCommitment(String time) {
    // TODO: Update time commitment and notify listeners
    throw UnimplementedError();
  }

  void setAdditionalNotes(String notes) {
    // TODO: Update additional notes and notify listeners
    throw UnimplementedError();
  }

  Future<void> generateNiches() async {
    // TODO: Call DeepSeekService, update suggestions/loading/error state
    throw UnimplementedError();
  }

  Future<void> regenerateNiches() async {
    // TODO: Regenerate with same data
    throw UnimplementedError();
  }

  Future<void> refineNiches(String refinement) async {
    // TODO: Refine existing results with user feedback
    throw UnimplementedError();
  }

  void reset() {
    // TODO: Clear all data and suggestions for a fresh start
    throw UnimplementedError();
  }
}
