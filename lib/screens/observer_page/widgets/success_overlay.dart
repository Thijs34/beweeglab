import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/screens/observer_page/models/observation_mode.dart';

class ObserverSuccessOverlay extends StatelessWidget {
  final ObservationMode mode;
  final String personId;
  final int groupSize;

  const ObserverSuccessOverlay({
    super.key,
    required this.mode,
    required this.personId,
    required this.groupSize,
  });

  @override
  Widget build(BuildContext context) {
    final message = mode == ObservationMode.individual
        ? 'Person #$personId has been recorded.'
        : 'Group of $groupSize people has been recorded.';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.2),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F8EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Observation Saved!',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamilyHeading,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Preparing next observation...',
                  style: TextStyle(fontSize: 12, color: AppTheme.gray500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
