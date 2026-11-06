import 'package:flutter/material.dart';

import '../widgets/quote_card.dart';
import '../widgets/timer_section.dart';
import '../widgets/today_focus_card.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // The gradient sits behind a transparent Scaffold so it also shows
    // behind the AppBar.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.65),
            scheme.surface,
            scheme.secondaryContainer.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text(
            'Focus Sessions',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        // SingleChildScrollView: the save card plus the on-screen keyboard
        // would not fit on a short screen, so the content must be able to
        // scroll. The width is capped so tablets stay tidy.
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Greeting(),
                    SizedBox(height: 12),
                    TimerSection(),
                    SizedBox(height: 24),
                    TodayFocusCard(),
                    SizedBox(height: 16),
                    QuoteCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Ready to Focus?',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a length, then start your session.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
