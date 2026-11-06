import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_sessions/models/session_model.dart';
import 'package:focus_sessions/providers/session_history_provider.dart';
import 'package:focus_sessions/services/session_storage_service.dart';

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

Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

// Builds a provider the way main.dart does: with storage, then load().
SessionHistoryProvider startApp(SharedPreferences prefs) {
  return SessionHistoryProvider(storage: SessionStorageService(prefs))..load();
}

void main() {
  group('SessionHistoryProvider persistence', () {
    test('starts empty when nothing has been saved', () async {
      final provider = startApp(await prefsWith({}));

      expect(provider.sessions, isEmpty);
    });

    test('added sessions are still there after a restart', () async {
      final prefs = await prefsWith({});
      final firstRun = startApp(prefs);

      firstRun.addSession(makeSession('old', DateTime(2026, 1, 1)));
      firstRun.addSession(makeSession('new', DateTime(2026, 1, 2)));
      await pumpEventQueue(); // let the background save finish

      // "Restart": a brand new provider reading the same storage.
      final secondRun = startApp(prefs);

      expect(secondRun.sessions.map((s) => s.id).toList(), ['new', 'old']);
    });

    test('deleting a session is remembered after a restart', () async {
      final prefs = await prefsWith({});
      final firstRun = startApp(prefs);
      firstRun.addSession(makeSession('a', DateTime(2026, 1, 1)));
      firstRun.addSession(makeSession('b', DateTime(2026, 1, 2)));
      await pumpEventQueue();

      firstRun.deleteSession('b');
      await pumpEventQueue();
      final secondRun = startApp(prefs);

      expect(secondRun.sessions.map((s) => s.id).toList(), ['a']);
    });

    test('load sorts newest first even if stored oldest first', () async {
      final prefs = await prefsWith({});
      await SessionStorageService(prefs).saveSessions([
        makeSession('old', DateTime(2026, 1, 1)),
        makeSession('mid', DateTime(2026, 1, 2)),
        makeSession('new', DateTime(2026, 1, 3)),
      ]);

      final provider = startApp(prefs);

      expect(provider.sessions.map((s) => s.id).toList(),
          ['new', 'mid', 'old']);
    });

    test('load ignores duplicate ids in stored data', () async {
      final prefs = await prefsWith({});
      await SessionStorageService(prefs).saveSessions([
        makeSession('a', DateTime(2026, 1, 1)),
        makeSession('a', DateTime(2026, 2, 2)),
      ]);

      final provider = startApp(prefs);

      expect(provider.sessions.length, 1);
      expect(provider.sessions.first.id, 'a');
    });

    test('corrupted data gives an empty history, and saving repairs it',
        () async {
      final prefs = await prefsWith({
        SessionStorageService.storageKey: 'definitely not json',
      });
      final firstRun = startApp(prefs);
      expect(firstRun.sessions, isEmpty);

      firstRun.addSession(makeSession('a', DateTime(2026, 1, 1)));
      await pumpEventQueue();
      final secondRun = startApp(prefs);

      expect(secondRun.sessions.map((s) => s.id).toList(), ['a']);
    });

    test('load notifies listeners', () async {
      final prefs = await prefsWith({});
      await SessionStorageService(prefs)
          .saveSessions([makeSession('a', DateTime(2026, 1, 1))]);
      final provider =
          SessionHistoryProvider(storage: SessionStorageService(prefs));
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.load();

      expect(notifications, 1);
    });
  });
}