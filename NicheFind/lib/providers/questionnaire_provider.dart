import 'package:flutter/material.dart';
import '../models/questionnaire_data.dart';
import '../models/niche_suggestion.dart';
import '../services/deepseek_service.dart';
import '../services/reddit_service.dart';

class QuestionnaireProvider extends ChangeNotifier {
  QuestionnaireProvider({
    DeepSeekService? service,
    RedditService? redditService,
  })  : _service = service ?? DeepSeekService(),
        _reddit = redditService ?? RedditService();

  final DeepSeekService _service;
  final RedditService _reddit;
  final QuestionnaireData _data = QuestionnaireData();
  List<NicheSuggestion> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  QuestionnaireData get data => _data;
  List<NicheSuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setInterests(List<String> interests) {
    _data.interests = List.of(interests);
    notifyListeners();
  }

  void setGoal(String goal) {
    _data.goal = goal;
    notifyListeners();
  }

  void setSkillLevel(String level) {
    _data.skillLevel = level;
    notifyListeners();
  }

  void setTimeCommitment(String time) {
    _data.timeCommitment = time;
    notifyListeners();
  }

  void setAdditionalNotes(String notes) {
    _data.additionalNotes = notes;
    notifyListeners();
  }

  Future<void> generateNiches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final niches = await _service.generateNiches(_data);
      _suggestions = await _reddit.enrichAll(niches);
    } catch (e) {
      _errorMessage = e.toString();
      _suggestions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> regenerateNiches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final niches = await _service.regenerateNiches(_data);
      _suggestions = await _reddit.enrichAll(niches);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refineNiches(String refinement) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final niches = await _service.refineNiches(_data, refinement);
      _suggestions = await _reddit.enrichAll(niches);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _data
      ..interests = const []
      ..goal = ''
      ..skillLevel = ''
      ..timeCommitment = ''
      ..additionalNotes = '';
    _suggestions = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
