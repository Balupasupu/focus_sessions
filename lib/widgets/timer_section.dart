import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/timer_provider.dart';
import 'focus_timer_ring.dart';
import 'session_save_card.dart';

// Duration chips, circular countdown and the Start / Pause / End controls.
// All timer logic lives in TimerProvider; this widget only shows it.
class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  // The three duration choices, in minutes.
  static const List<int> durationOptions = [15, 25, 45];

  String _statusText(TimerProvider timer) {
    if (timer.isRunning) return 'FOCUSING';
    if (timer.isPaused) return 'PAUSED';
    if (timer.hasUnsavedSession) return 'FINISHED';
    return 'READY';
  }

  @override
  Widget build(BuildContext context) {
    // watch: rebuild this widget whenever TimerProvider changes
    // (every second while the timer runs).
    final timer = context.watch<TimerProvider>();
    final scheme = Theme.of(context).colorScheme;

    // Locked while running, paused, and while an ended session awaits
    // Save/Discard.
    final locked =
        timer.isRunning || timer.isPaused || timer.hasUnsavedSession;
    final canPauseOrResume = timer.isRunning || timer.isPaused;

    // Size the ring from the screen so small phones still show the buttons
    // without scrolling, and big screens do not get a huge circle.
    final screen = MediaQuery.sizeOf(context);
    final availableHeight =
        screen.height - kToolbarHeight - MediaQuery.paddingOf(context).vertical;
    final ringSize = math
        .min(screen.width * 0.72, availableHeight * 0.34)
        .clamp(170.0, 300.0)
        .toDouble();

    final totalSeconds = timer.selectedMinutes * 60;
    final progress = timer.remainingSeconds / totalSeconds;

    final buttonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Duration options
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: [
            for (final minutes in durationOptions)
              _DurationChip(
                minutes: minutes,
                selected: minutes == timer.selectedMinutes,
                // null disables the chip.
                onSelected: locked
                    ? null
                    : () => context
                        .read<TimerProvider>()
                        .selectDuration(minutes),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Live countdown inside the circular timer
        Center(
          child: FocusTimerRing(
            size: ringSize,
            progress: progress,
            timeText: timer.formattedTime,
            statusText: _statusText(timer),
          ),
        ),
        const SizedBox(height: 8),

        // Selected duration
        Text(
          'Session length: ${timer.selectedMinutes} minutes',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // Start Focus: disabled while running, paused or pending a save
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: buttonShape,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          onPressed:
              locked ? null : () => context.read<TimerProvider>().startSession(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded),
              SizedBox(width: 8),
              Text('Start Focus'),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Pause while running, Resume while paused
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: buttonShape,
                ),
                onPressed: canPauseOrResume
                    ? () {
                        final t = context.read<TimerProvider>();
                        if (t.isPaused) {
                          t.resumeSession();
                        } else {
                          t.pauseSession();
                        }
                      }
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(timer.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded),
                    const SizedBox(width: 6),
                    Text(timer.isPaused ? 'Resume' : 'Pause'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // End Session: enabled while a session is running or paused
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: buttonShape,
                ),
                onPressed: canPauseOrResume
                    ? () => context.read<TimerProvider>().endSession()
                    : null,
                child: const Text('End Session'),
              ),
            ),
          ],
        ),

        // Save / Discard card for the session that just ended
        if (timer.hasUnsavedSession) ...[
          const SizedBox(height: 24),
          const SessionSaveCard(),
        ],
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.minutes,
    required this.selected,
    required this.onSelected,
  });

  final int minutes;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text('$minutes min'),
      selected: selected,
      showCheckmark: false,
      // Disabled chips keep the same colors, so the chosen length stays
      // easy to see while the timer is locked.
      selectedColor: scheme.primary,
      disabledColor: selected ? scheme.primary : scheme.surface,
      backgroundColor: scheme.surface,
      shape: const StadiumBorder(),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? scheme.onPrimary : scheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      // null disables the chip.
      onSelected: onSelected == null ? null : (_) => onSelected!(),
    );
  }
}
