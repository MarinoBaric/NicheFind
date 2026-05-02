import 'package:flutter/material.dart';

class RefineBottomSheet extends StatefulWidget {
  final void Function(String refinement) onSubmit;
  final List<String> activeRefinements;

  const RefineBottomSheet({
    super.key,
    required this.onSubmit,
    this.activeRefinements = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(String) onSubmit,
    List<String> activeRefinements = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RefineBottomSheet(
        onSubmit: onSubmit,
        activeRefinements: activeRefinements,
      ),
    );
  }

  @override
  State<RefineBottomSheet> createState() => _RefineBottomSheetState();
}

class _RefineBottomSheetState extends State<RefineBottomSheet> {
  static const List<String> _presets = [
    'More beginner-friendly',
    'Focus on physical products',
    'Lower competition',
    'Under \$100 to start',
    'Faster to launch',
    'Audience-first ideas',
  ];

  final Set<String> _selected = {};
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parts = <String>[
      ..._selected,
      if (_controller.text.trim().isNotEmpty) _controller.text.trim(),
    ];
    if (parts.isEmpty) return;
    final combined = parts.join('; ');
    Navigator.of(context).pop();
    widget.onSubmit(combined);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Refine results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pick presets or describe what to change. We will rerun the prompt.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _presets)
                    FilterChip(
                      label: Text(preset),
                      selected: _selected.contains(preset),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selected.add(preset);
                          } else {
                            _selected.remove(preset);
                          }
                        });
                      },
                      selectedColor: Colors.deepPurple.withValues(alpha: 0.18),
                      checkmarkColor: Colors.deepPurple,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Custom refinement (optional)',
                  hintText: 'e.g. focus on creators in the EU',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty &&
                              _controller.text.trim().isEmpty
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Apply refinement',
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
}
