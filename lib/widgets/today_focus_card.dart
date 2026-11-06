import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/today_summary.dart';
import '../providers/session_history_provider.dart';

// "Today's Focus" summary: how many sessions and how much focus time today.
class TodayFocusCard extends StatelessWidget {
  const TodayFocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionHistoryProvider>().sessions;
    final summary = TodaySummary.fromSessions(sessions, DateTime.now());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Today's Focus",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  value: '${summary.sessionCount}',
                  label: 'Sessions',
                ),
              ),
              Expanded(
                child: _Stat(
                  value: summary.focusedLabel,
                  label: 'Focused',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
