import 'package:flutter/material.dart';

import '../services/niche_exceptions.dart';

class ErrorView extends StatelessWidget {
  final NicheException error;
  final VoidCallback onRetry;
  final VoidCallback? onSendFeedback;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.onSendFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _spec(error.kind);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(spec.icon, size: 72, color: spec.color),
            const SizedBox(height: 20),
            Text(
              spec.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Retry', style: TextStyle(fontSize: 15)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (error.kind == NicheErrorKind.parse && onSendFeedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: onSendFeedback,
                  child: const Text('Send feedback'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _ErrorSpec _spec(NicheErrorKind kind) {
    switch (kind) {
      case NicheErrorKind.offline:
        return _ErrorSpec(
          icon: Icons.cloud_off,
          color: Colors.blueGrey,
          title: "You're offline",
        );
      case NicheErrorKind.badRequest:
        return _ErrorSpec(
          icon: Icons.tune,
          color: Colors.orange,
          title: "Something's off with the request",
        );
      case NicheErrorKind.server:
        return _ErrorSpec(
          icon: Icons.error_outline,
          color: Colors.red,
          title: 'DeepSeek is having a moment',
        );
      case NicheErrorKind.parse:
        return _ErrorSpec(
          icon: Icons.broken_image_outlined,
          color: Colors.deepPurple,
          title: "We got a response we couldn't read",
        );
      case NicheErrorKind.unknown:
        return _ErrorSpec(
          icon: Icons.warning_amber_rounded,
          color: Colors.amber,
          title: 'Something went wrong',
        );
    }
  }
}

class _ErrorSpec {
  final IconData icon;
  final Color color;
  final String title;
  _ErrorSpec({required this.icon, required this.color, required this.title});
}
