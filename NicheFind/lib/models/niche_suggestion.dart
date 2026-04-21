class NicheMetrics {
  final int? postCount;
  final int? totalUpvotes;
  final String? topSubreddit;
  final String source;

  NicheMetrics({
    this.postCount,
    this.totalUpvotes,
    this.topSubreddit,
    this.source = 'reddit',
  });
}

class NicheSuggestion {
  final String title;
  final String description;
  final String demand;
  final String competition;
  final List<String> firstSteps;
  final NicheMetrics? metrics;

  NicheSuggestion({
    required this.title,
    required this.description,
    required this.demand,
    required this.competition,
    required this.firstSteps,
    this.metrics,
  });

  NicheSuggestion copyWith({NicheMetrics? metrics}) {
    return NicheSuggestion(
      title: title,
      description: description,
      demand: demand,
      competition: competition,
      firstSteps: firstSteps,
      metrics: metrics ?? this.metrics,
    );
  }

  factory NicheSuggestion.fromJson(Map<String, dynamic> json) {
    return NicheSuggestion(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      demand: json['demand'] as String? ?? '',
      competition: json['competition'] as String? ?? '',
      firstSteps: (json['firstSteps'] as List?)?.cast<String>() ?? const [],
    );
  }
}
