import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/questionnaire_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/niche_card.dart';
import '../widgets/refine_bottom_sheet.dart';
import 'loading_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionnaireProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return LoadingScreen(onCancel: () => provider.cancel());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your niches'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: SafeArea(
            child: provider.error != null
                ? ErrorView(
                    error: provider.error!,
                    onRetry: () => provider.retry(),
                    onSendFeedback: () => _sendFeedback(context),
                  )
                : _ResultsBody(provider: provider),
          ),
          bottomNavigationBar: provider.error == null
              ? _BottomBar(
                  onRegenerate: () => provider.regenerateNiches(),
                  onRefine: () => _onRefine(context),
                )
              : null,
        );
      },
    );
  }

  void _onRefine(BuildContext context) {
    final provider = context.read<QuestionnaireProvider>();
    RefineBottomSheet.show(
      context,
      activeRefinements: provider.activeRefinements,
      onSubmit: (refinement) => provider.refineNiches(refinement),
    );
  }

  void _sendFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks — feedback noted.')),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  final QuestionnaireProvider provider;
  const _ResultsBody({required this.provider});

  @override
  Widget build(BuildContext context) {
    final suggestions = provider.suggestions;
    final refinements = provider.activeRefinements;

    if (suggestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No niches yet. Tap Regenerate to try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (refinements.isNotEmpty)
          _RefinementBar(
            refinements: refinements,
            onClear: () => provider.clearRefinements(),
            onRemove: provider.removeRefinement,
          ),
        for (final s in suggestions) NicheCard(suggestion: s),
        const SizedBox(height: 96),
      ],
    );
  }
}

class _RefinementBar extends StatelessWidget {
  final List<String> refinements;
  final VoidCallback onClear;
  final void Function(String) onRemove;

  const _RefinementBar({
    required this.refinements,
    required this.onClear,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Refined:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: const Text('Clear all'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final r in refinements)
                InputChip(
                  label: Text(r),
                  onDeleted: () => onRemove(r),
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  deleteIconColor: Colors.deepPurple,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onRegenerate;
  final VoidCallback onRefine;

  const _BottomBar({required this.onRegenerate, required this.onRefine});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRefine,
                icon: const Icon(Icons.tune),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Refine'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRegenerate,
                icon: const Icon(Icons.refresh),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Regenerate'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
