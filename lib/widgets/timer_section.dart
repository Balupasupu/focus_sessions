import 'package:flutter/material.dart';

class TimerSection extends StatelessWidget {
  const TimerSection({super.key});

  // The three duration choices, in minutes.
  static const List<int> durationOptions = [15, 25, 45];

  // Which duration looks selected. Fixed at 25 for now.
  static const int selectedMinutes = 25;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration options
        Wrap(
          spacing: 8,
          children: [
            for (final minutes in durationOptions)
              ChoiceChip(
                label: Text('$minutes min'),
                selected: minutes == selectedMinutes,
                onSelected: (_) {
                  // Intentionally empty: selection logic comes later.
                },
              ),
          ],
        ),
        const SizedBox(height: 32),

        // Countdown display
        Text(
          '25:00',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 32),

        // Start Focus button (enabled)
        FilledButton(
          onPressed: () {
            // Intentionally empty: the countdown comes later.
          },
          child: const Text('Start Focus'),
        ),
        const SizedBox(height: 12),

        // End Session button (disabled)
        const OutlinedButton(
          onPressed: null,
          child: Text('End Session'),
        ),
      ],
    );
  }
}