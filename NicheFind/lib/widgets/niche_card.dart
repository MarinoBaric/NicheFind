import 'package:flutter/material.dart';
import '../models/niche_suggestion.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NicheCard extends StatefulWidget {
  final NicheSuggestion suggestion;

  const NicheCard({super.key, required this.suggestion});

  @override
  State<NicheCard> createState() => _NicheCardState();
}

class _NicheCardState extends State<NicheCard> {
  bool _firstStepsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.forum_outlined,
                    size: 16,
                    color: Color(0xFFFF4500),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _buildMetricsLabel(s.metrics),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Badge(label: 'Demand: ${s.demand}', color: Colors.green),
                _Badge(
                  label: 'Competition: ${s.competition}',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(
                () => _firstStepsExpanded = !_firstStepsExpanded,
              ),
              child: Row(
                children: [
                  const Text(
                    'First steps',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Icon(
                    _firstStepsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            if (_firstStepsExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: s.firstSteps
                      .map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $step'),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Search on Google',
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () => _openSearch(s),
                ),
                IconButton(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () => _shareSuggestion(s),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearch(NicheSuggestion s) async {
    final query = Uri.encodeQueryComponent(s.title);
    final url = Uri.parse('https://www.google.com/search?q=$query');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareSuggestion(NicheSuggestion s) async {
    final buffer = StringBuffer()
      ..writeln(s.title)
      ..writeln()
      ..writeln(s.description)
      ..writeln()
      ..writeln('Demand: ${s.demand}  ·  Competition: ${s.competition}');

    if (s.firstSteps.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('First steps:');
      for (final step in s.firstSteps) {
        buffer.writeln('• $step');
      }
    }
    buffer
      ..writeln()
      ..writeln('Found with NicheFind');
    await Share.share(buffer.toString(), subject: s.title);
  }

  String _buildMetricsLabel(NicheMetrics? m) {
    if (m == null || m.postCount == null) return 'Reddit: —';
    final sub = m.topSubreddit != null ? ' · r/${m.topSubreddit}' : '';
    return 'Reddit: ${m.postCount} posts$sub';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
