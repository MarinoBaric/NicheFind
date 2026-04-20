class NicheSuggestion {
  final String title;
  final String description;
  final String demand;
  final String competition;
  final List<String> firstSteps;

  NicheSuggestion({
    required this.title,
    required this.description,
    required this.demand,
    required this.competition,
    required this.firstSteps,
  });

  factory NicheSuggestion.fromJson(Map<String, dynamic> json) {
    // TODO: Parse DeepSeek response into NicheSuggestion
    throw UnimplementedError();
  }
}
