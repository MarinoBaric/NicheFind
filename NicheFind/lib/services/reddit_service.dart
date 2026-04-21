import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/niche_suggestion.dart';

class RedditService {
  Future<NicheMetrics?> fetchMetrics(String nicheTitle) async {
    try {
      final query = Uri.encodeQueryComponent(nicheTitle);
      final url = Uri.parse(
        '${ApiConfig.redditBaseUrl}/search.json'
        '?q=$query&limit=25&sort=relevance&type=link',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': ApiConfig.redditUserAgent},
      ).timeout(const Duration(seconds: 8));
      if(response.statusCode != 200) return null;

      final body = json.decode(response.body) as Map<String, dynamic>;
      final children = (body['data']?['children'] as List?) ?? const[];
      if(children.isEmpty) {
        return NicheMetrics(postCount: 0, totalUpvotes: 0, topSubreddit: null);
      }

      int totalUpvotes = 0; 
      final subredditCounts = <String, int>{};

      for (final child in children){
        final data = child['data'] as Map<String, dynamic>?;
        if(data == null) continue;
        totalUpvotes += (data['score'] as int?) ?? 0;
        final sub = data['subreddit'] as String?;
        if(sub != null && sub.isNotEmpty) {
          subredditCounts[sub] = (subredditCounts[sub] ?? 0) + 1;
        }
      }

      String? topSubreddit;
      if(subredditCounts.isNotEmpty){
        topSubreddit = subredditCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      }

      return NicheMetrics(
        postCount: children.length,
        totalUpvotes: totalUpvotes,
        topSubreddit: topSubreddit,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<NicheSuggestion>> enrichAll(List<NicheSuggestion> niches) async {
    return Future.wait(
      niches.map((n) async {
        final metrics = await fetchMetrics(n.title);
        return n.copyWith(metrics: metrics);
      }),
    );
  }
}