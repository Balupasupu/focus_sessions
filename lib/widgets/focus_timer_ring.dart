import 'package:flutter/material.dart';

// A circular countdown: a progress ring with the time and a status label
// in the middle. It only draws what it is given; the timer logic stays in
// TimerProvider.
class FocusTimerRing extends StatelessWidget {
  const FocusTimerRing({
    super.key,
    required this.size,
    required this.progress,
    required this.timeText,
    required this.statusText,
  });

  final double size;

  // 1.0 = full time left, 0.0 = finished.
  final double progress;
  final String timeText;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(size * 0.06),
            child: SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0).toDouble(),
                strokeWidth: size * 0.045,
                strokeCap: StrokeCap.round,
                backgroundColor: scheme.primaryContainer,
                color: scheme.primary,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size * 0.62,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    timeText,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
              Text(
                statusText,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
