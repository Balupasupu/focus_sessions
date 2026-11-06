import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/models/session_model.dart';
import 'package:focus_sessions/providers/session_history_provider.dart';

// The ONLY place that calls SessionModel's constructor. If your model uses
// different field names, change this helper and nothing else.
SessionModel makeSession(String id, DateTime startedAt) {
  return SessionModel(
    id: id,
    startedAt: startedAt,
    plannedSeconds: 1500,
    actualSeconds: 600,
    note: 'Note $id',
  );
}

void main() {
  group('SessionHistoryProvider defaults', () {
    test('starts with an empty history', () {
      final provider = SessionHistoryProvider();

      expect(provider.sessions, isEmpty);
    });
  });

  group('SessionHistoryProvider addSession', () {
    test('adds a session', () {
      final provider = SessionHistoryProvider();

      final added = provider.addSession(makeSession('a', DateTime(2026, 1, 1)));

      expect(added, true);
      expect(provider.sessions.length, 1);
      expect(provider.sessions.first.id, 'a');
    });

    test('notifies listeners when a session is added', () {
      final provider = SessionHistoryProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.addSession(makeSession('a', DateTime(2026, 1, 1)));

      expect(notifications, 1);
    });

    test('rejects a duplicate id without changing the list', () {
      final provider = SessionHistoryProvider();
      provider.addSession(makeSession('a', DateTime(2026, 1, 1)));
      var notifications = 0;
      provider.addListener(() => notifications++);

      final added = provider.addSession(makeSession('a', DateTime(2026, 2, 2)));

      expect(added, false);
      expect(provider.sessions.length, 1);
      expect(provider.sessions.first.startedAt, DateTime(2026, 1, 1));
      expect(notifications, 0);
    });
  });

  group('SessionHistoryProvider sorting', () {
    test('keeps the newest session first when added oldest to newest', () {
      final provider = SessionHistoryProvider();

      provider.addSession(makeSession('old', DateTime(2026, 1, 1)));
      provider.addSession(makeSession('mid', DateTime(2026, 1, 2)));
      provider.addSession(makeSession('new', DateTime(2026, 1, 3)));

      expect(provider.sessions.map((s) => s.id).toList(), ['new', 'mid', 'old']);
    });

    test('sorts by start time, not by the order sessions were added', () {
      final provider = SessionHistoryProvider();

      provider.addSession(makeSession('mid', DateTime(2026, 1, 2)));
      provider.addSession(makeSession('new', DateTime(2026, 1, 3)));
      provider.addSession(makeSession('old', DateTime(2026, 1, 1)));

      expect(provider.sessions.map((s) => s.id).toList(), ['new', 'mid', 'old']);
    });

    test('the sessions list cannot be modified from outside', () {
      final provider = SessionHistoryProvider();
      provider.addSession(makeSession('a', DateTime(2026, 1, 1)));

      expect(
        () => provider.sessions.add(makeSession('b', DateTime(2026, 1, 2))),
        throwsUnsupportedError,
      );
      expect(provider.sessions.length, 1);
    });
  });

  group('SessionHistoryProvider deleteSession', () {
    test('removes the session with the given id', () {
      final provider = SessionHistoryProvider();
      provider.addSession(makeSession('a', DateTime(2026, 1, 1)));
      provider.addSession(makeSession('b', DateTime(2026, 1, 2)));

      final removed = provider.deleteSession('a');

      expect(removed, true);
      expect(provider.sessions.map((s) => s.id).toList(), ['b']);
    });

    test('keeps the remaining sessions in newest-first order', () {
      final provider = SessionHistoryProvider();
      provider.addSession(makeSession('old', DateTime(2026, 1, 1)));
      provider.addSession(makeSession('mid', DateTime(2026, 1, 2)));
      provider.addSession(makeSession('new', DateTime(2026, 1, 3)));

      provider.deleteSession('mid');

      expect(provider.sessions.map((s) => s.id).toList(), ['new', 'old']);
    });

    test('notifies listeners when a session is deleted', () {
      final provider = SessionHistoryProvider();
      provider.addSession(makeSession('a', DateTime(2026, 1, 1)));
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.deleteSession('a');

      expect(notifications, 1);
    });

    test('does nothing and does not notify for an unknown id', () {
      final provider = SessionHistoryProvider();
      provider.addSession(makeSession('a', DateTime(2026, 1, 1)));
      var notifications = 0;
      provider.addListener(() => notifications++);

      final removed = provider.deleteSession('missing');

      expect(removed, false);
      expect(provider.sessions.length, 1);
      expect(notifications, 0);
    });
  });

  group('SessionHistoryProvider generateId', () {
    test('produces unique ids', () {
      final ids = {
        for (var i = 0; i < 1000; i++) SessionHistoryProvider.generateId(),
      };

      expect(ids.length, 1000);
    });
  });
}