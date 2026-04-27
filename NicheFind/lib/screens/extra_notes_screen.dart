import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/questionnaire_provider.dart';
import 'loading_screen.dart';
import 'results_screen.dart';

class ExtraNotesScreen extends StatelessWidget {
  const ExtraNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Step 5 of 5 - Optional free-text input + idea chips
    // Free text field with hint: "E.g.: I have experience in marketing..."
    // Quick-add chips: Past experience, Budget constraints, Preferred platforms, Audience preference
    // Back / Generate navigation (Generate button calls _onGenerate below)
    throw UnimplementedError();
  }

  Future<void> _onGenerate(BuildContext context) async {
    final provider = context.read<QuestionnaireProvider>();

    // Push loading screen first so it shows for full duration of the call.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
    );

    await provider.generateNiches();
    if (!context.mounted) return;

    // Replace loading with results (or show error in results screen).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ResultsScreen()),
    );
  }
}
