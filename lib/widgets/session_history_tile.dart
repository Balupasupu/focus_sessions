import 'package:flutter/material.dart';

import '../models/session_model.dart';

// Turns 600 into "10:00", same MM:SS style as the timer.
String formatSessionDuration(int seconds) {
  final mm = (seconds ~/ 60).toString().padLeft(2, '0');
  final ss = (seconds % 60).toString().padLeft(2, '0');
  return '$mm:$ss';
}

// Turns a DateTime into "Nov 6, 2026 • 2:05 PM".
String formatSessionDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';
  return '${months[date.month - 1]} ${date.day}, ${date.year} • '
      '$hour12:$minute $period';
}

// Turns 5400 into "1h 30m" and 2100 into "35 min".
String formatTotalFocusTime(int seconds) {
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
}

// One saved session in the history list.
class SessionHistoryTile extends StatelessWidget {
  const SessionHistoryTile({super.key, required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNote = session.note.isNotEmpty;

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.timer_outlined)),
        title: Text(formatSessionDate(session.startedAt)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focused ${formatSessionDuration(session.actualSeconds)} '
                'of ${formatSessionDuration(session.plannedSeconds)}',
              ),
              const SizedBox(height: 4),
              Text(
                hasNote ? session.note : 'No note',
                style: hasNote
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}