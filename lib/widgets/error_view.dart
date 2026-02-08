import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// A user-friendly error view with a retry button.
/// Replaces raw `Text('Error: $e')` across all screens.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.message = 'Something went wrong.\nTap the button below to try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A sliver-compatible wrapper for ErrorView, for use inside CustomScrollView.
class SliverErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const SliverErrorView({
    super.key,
    this.message = 'Something went wrong.\nTap the button below to try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ErrorView(message: message, onRetry: onRetry),
    );
  }
}
