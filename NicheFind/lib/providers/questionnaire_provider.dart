import 'dart:async';

import 'package:flutter/material.dart';

import '../models/niche_suggestion.dart';
import '../models/questionnaire_data.dart';
import '../services/deepseek_service.dart';
import '../services/niche_exceptions.dart';
import '../services/reddit_service.dart';

enum _LastAction { generate, regenerate, refine }

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
  final List<String> _activeRefinements = [];
  bool _isLoading = false;
  NicheException? _error;

  _LastAction _lastAction = _LastAction.generate;
  String? _lastRefinement;
  Completer<void>? _activeRun;

  QuestionnaireData get data => _data;
  List<NicheSuggestion> get suggestions => _suggestions;
  List<String> get activeRefinements => List.unmodifiable(_activeRefinements);
  bool get isLoading => _isLoading;
  NicheException? get error => _error;
  String? get errorMessage => _error?.message;

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
    _lastAction = _LastAction.generate;
    _activeRefinements.clear();
    await _runAction(() => _service.generateNiches(_data));
  }

  Future<void> regenerateNiches() async {
    _lastAction = _LastAction.regenerate;
    final previous = List<NicheSuggestion>.of(_suggestions);
    await _runAction(
      () => _service.regenerateNiches(_data, previousResults: previous),
    );
  }

  Future<void> refineNiches(String refinement) async {
    final trimmed = refinement.trim();
    if (trimmed.isEmpty) return;
    _lastAction = _LastAction.refine;
    _lastRefinement = trimmed;
    if (!_activeRefinements.contains(trimmed)) {
      _activeRefinements.add(trimmed);
    }
    await _runAction(() => _service.refineNiches(_data, trimmed));
  }

  Future<void> retry() async {
    switch (_lastAction) {
      case _LastAction.generate:
        return generateNiches();
      case _LastAction.regenerate:
        return regenerateNiches();
      case _LastAction.refine:
        if (_lastRefinement != null) return refineNiches(_lastRefinement!);
        return generateNiches();
    }
  }

  void cancel() {
    final run = _activeRun;
    if (run != null && !run.isCompleted) {
      run.complete();
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearRefinements() {
    if (_activeRefinements.isEmpty) return;
    _activeRefinements.clear();
    notifyListeners();
  }

  void removeRefinement(String refinement) {
    if (_activeRefinements.remove(refinement)) {
      notifyListeners();
    }
  }

  Future<void> _runAction(
    Future<List<NicheSuggestion>> Function() action,
  ) async {
    final run = Completer<void>();
    _activeRun = run;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Future.any<List<NicheSuggestion>?>([
        action().then<List<NicheSuggestion>?>((v) => v),
        run.future.then<List<NicheSuggestion>?>((_) => null),
      ]);

      if (run.isCompleted) return;

      if (result != null) {
        final enriched = await _reddit.enrichAll(result);
        if (run.isCompleted) return;
        _suggestions = enriched;
      }
    } on NicheException catch (e) {
      _error = e;
    } catch (e) {
      _error = NicheException.unknown(details: e.toString());
    } finally {
      if (!run.isCompleted) run.complete();
      _activeRun = null;
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
    _activeRefinements.clear();
    _lastRefinement = null;
    _lastAction = _LastAction.generate;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
