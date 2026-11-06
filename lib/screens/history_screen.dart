import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_history_provider.dart';
import '../widgets/session_history_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: rebuild whenever the history changes.
    final sessions = context.watch<SessionHistoryProvider>().sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
      ),
      body: sessions.isEmpty
          ? const _EmptyHistory()
          : Column(
              children: [
                _SummaryBar(
                  count: sessions.length,
                  totalSeconds:
                      sessions.fold(0, (sum, s) => sum + s.actualSeconds),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
  final session = sessions[index];

  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete Session?'),
            content: const Text(
              'Are you sure you want to delete this session?',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },

      onDismissed: (direction) {
        context
            .read<SessionHistoryProvider>()
            .deleteSession(session.id);
      },

      child: SessionHistoryTile(session: session),
    ),
  );
},
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.count, required this.totalSeconds});

  final int count;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? 'session' : 'sessions';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        '$count $label • ${formatTotalFocusTime(totalSeconds)} focused',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No focus sessions yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Finish a focus session and save it to see it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}