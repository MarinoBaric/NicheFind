import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Display niche suggestions as scrollable cards
    // Each card: title, description, demand badge, competition badge, expandable "First steps"
    // Bottom bar: Regenerate button + Refine button
    // Handle loading state (spinner) and error state (message + retry)
    throw UnimplementedError();
  }

  void _onRegenerate(BuildContext context) {
    // TODO: Trigger regenerateNiches via provider
    throw UnimplementedError();
  }

  void _onRefine(BuildContext context) {
    // TODO: Show refinement dialog/bottom sheet, then call refineNiches
    throw UnimplementedError();
  }
}
