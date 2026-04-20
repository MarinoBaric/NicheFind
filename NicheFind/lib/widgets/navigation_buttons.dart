import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const NavigationButtons({
    super.key,
    this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Build Back / Next (or Generate) button row at bottom of each step
    throw UnimplementedError();
  }
}
