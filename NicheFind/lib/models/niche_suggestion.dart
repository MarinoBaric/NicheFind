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
      title: _readString(json, ['title', 'name']) ?? 'Untitled niche',
      description: _readString(json, ['description', 'summary', 'desc']) ?? '',
      demand: _readString(json, ['demand', 'demand_level']) ?? '-',
      competition:
          _readString(json, ['competition', 'competition_level']) ?? '-',
      firstSteps:
          _readStringList(json, ['firstSteps', 'first_steps', 'steps']),
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static List<String> _readStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        return value
            .map((e) => e?.toString().trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value is String && value.trim().isNotEmpty) {
        return value
            .split(RegExp(r'[\n;]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }
}
