import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/questionnaire_provider.dart';
import 'loading_screen.dart';
import 'results_screen.dart';

class ExtraNotesScreen extends StatefulWidget {
  const ExtraNotesScreen({super.key});

  @override
  State<ExtraNotesScreen> createState() => _ExtraNotesScreenState();
}

class _ExtraNotesScreenState extends State<ExtraNotesScreen> {
  static const List<_QuickChip> _chips = [
    _QuickChip('Past experience', 'I have past experience in '),
    _QuickChip('Budget constraints', 'My budget is around '),
    _QuickChip('Preferred platforms', 'I prefer to publish on '),
    _QuickChip('Audience preference', 'My target audience is '),
  ];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initial = context.read<QuestionnaireProvider>().data.additionalNotes;
    _controller = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _appendChip(String snippet) {
    final current = _controller.text.trimRight();
    final next = current.isEmpty ? snippet : '$current\n$snippet';
    _controller
      ..text = next
      ..selection = TextSelection.collapsed(offset: next.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 5 of 5'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anything else we should know?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Optional — add context that helps tailor the suggestions.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                minLines: 4,
                maxLines: 8,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'E.g.: I have experience in marketing...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final chip in _chips)
                    ActionChip(
                      label: Text(chip.label),
                      onPressed: () => _appendChip(chip.snippet),
                    ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Back'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _onGenerate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Generate',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onGenerate(BuildContext context) async {
    final provider = context.read<QuestionnaireProvider>();
    provider.setAdditionalNotes(_controller.text.trim());

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
    );

    await provider.generateNiches();
    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ResultsScreen()),
    );
  }
}

class _QuickChip {
  final String label;
  final String snippet;
  const _QuickChip(this.label, this.snippet);
}
