import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/questionnaire_provider.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback? onCancel;

  const LoadingScreen({super.key, this.onCancel});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  static const List<String> _captions = [
    'Looking at your interests…',
    'Weighing competition…',
    'Finding gaps…',
    'Cross-checking with Reddit…',
    'Sharpening the angles…',
  ];

  late final AnimationController _shimmer;
  late final AnimationController _pulse;
  Timer? _captionTimer;
  int _captionIndex = 0;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _captionTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _captionIndex = (_captionIndex + 1) % _captions.length);
    });
  }

  @override
  void dispose() {
    _captionTimer?.cancel();
    _shimmer.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _handleCancel() {
    final cb = widget.onCancel;
    if (cb != null) {
      cb();
    } else {
      context.read<QuestionnaireProvider>().cancel();
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                _PulseSparkle(controller: _pulse),
                const SizedBox(height: 32),
                _Shimmer(controller: _shimmer),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    _captions[_captionIndex],
                    key: ValueKey(_captionIndex),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This usually takes 5–10 seconds.',
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _handleCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseSparkle extends StatelessWidget {
  final AnimationController controller;
  const _PulseSparkle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final scale = 0.92 + 0.08 * controller.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.deepPurple,
            ),
          ),
        );
      },
    );
  }
}

class _Shimmer extends StatelessWidget {
  final AnimationController controller;
  const _Shimmer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(color: Colors.deepPurple.withValues(alpha: 0.10)),
                FractionallySizedBox(
                  alignment: Alignment(-1 + 2 * t, 0),
                  widthFactor: 0.35,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withValues(alpha: 0.0),
                          Colors.deepPurple.withValues(alpha: 0.6),
                          Colors.deepPurple.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
