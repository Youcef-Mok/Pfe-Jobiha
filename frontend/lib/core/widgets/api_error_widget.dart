// lib/core/widgets/api_error_widget.dart
//
// Reusable error display that never overflows.
// Use this in any AsyncValue.when(error: ...) callback.
//
// Key decisions:
//   - SingleChildScrollView: keeps content scrollable in constrained-height
//     tab bodies (NestedScrollView slivers) so long DioException messages
//     don't overflow the layout.
//   - mainAxisSize.min on Column: the widget only takes as much vertical
//     space as its children need — no unbounded expansion.
//   - The error message is clipped to a max of 4 lines with an ellipsis to
//     prevent the DioException stack-trace from flooding the UI.

import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';

class ApiErrorWidget extends StatelessWidget {
  /// The error object (usually a DioException or Exception).
  final Object error;

  /// Optional retry callback. When provided a "Réessayer" button is shown.
  final VoidCallback? onRetry;

  /// Icon shown above the message. Defaults to [Icons.error_outline].
  final IconData icon;

  const ApiErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    // Extract a human-readable message.
    // DioException.toString() is very verbose — we only show the .error
    // field when it's a DioException, falling back to the full toString().
    final message = _extractMessage(error);

    return SingleChildScrollView(
      // Physics allow the widget to scroll if content exceeds the available
      // height (e.g., inside a constrained SliverToBoxAdapter tab body).
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        // min: only consumes the height of its children, never expands to fill.
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.slate400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            // Limit to 4 lines so a long stack trace doesn't fill the screen.
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.slate600,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.violet,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _extractMessage(Object error) {
    // Try to get the clean .error field from DioException first.
    final msg = error.toString();

    // DioException messages start with "DioException [...]:" — strip it.
    final dioPrefix = RegExp(r'^DioException\s*\[[^\]]*\]:\s*');
    if (dioPrefix.hasMatch(msg)) {
      final clean = msg.replaceFirst(dioPrefix, '').trim();
      // If still looks like a raw HTTP dump, show a generic message.
      if (clean.startsWith('This is typically') || clean.contains('\n')) {
        return 'Une erreur est survenue. Vérifiez votre connexion et réessayez.';
      }
      return clean;
    }

    // Exception("...") wrapper — unwrap it.
    final exceptionPrefix = RegExp(r'^Exception:\s*');
    if (exceptionPrefix.hasMatch(msg)) {
      return msg.replaceFirst(exceptionPrefix, '').trim();
    }

    return msg;
  }
}
