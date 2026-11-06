import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_history_provider.dart';
import '../providers/timer_provider.dart';

// Shown after a session ends. Lets the user add a note, then Save or Discard.
class SessionSaveCard extends StatefulWidget {
  const SessionSaveCard({super.key});

  @override
  State<SessionSaveCard> createState() => _SessionSaveCardState();
}

class _SessionSaveCardState extends State<SessionSaveCard> {
  // Only the text typed so far lives here. That is local to this widget,
  // not shared app state, so a StatefulWidget is fine.
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final timer = context.read<TimerProvider>();
    context
        .read<SessionHistoryProvider>()
        .savePendingSession(timer, _noteController.text);
  }

  void _discard() {
    context.read<TimerProvider>().resetSession();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Session finished',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('You focused for ${timer.formattedActualDuration}'),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLength: 140,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _discard,
                  child: const Text('Discard'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}