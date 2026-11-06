import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_sessions/models/session_model.dart';
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

// Starts SharedPreferences with a fake in-memory store.
Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

// Turns sessions into JSON maps so tests can compare them field by field
// without knowing the model's field names.
List<dynamic> asJson(List<SessionModel> sessions) {
  return sessions.map((s) => s.toJson()).toList();
}

void main() {
  group('SessionStorageService loading', () {
    test('returns an empty list when nothing has been saved', () async {
      final service = SessionStorageService(await prefsWith({}));

      expect(service.loadSessions(), isEmpty);
    });

    test('returns an empty list when the stored text is empty', () async {
      final prefs = await prefsWith({SessionStorageService.storageKey: ''});

      expect(SessionStorageService(prefs).loadSessions(), isEmpty);
    });

    test('returns an empty list when the stored text is not valid JSON',
        () async {
      final prefs = await prefsWith({
        SessionStorageService.storageKey: '{this is not json',
      });

      expect(SessionStorageService(prefs).loadSessions(), isEmpty);
    });

    test('returns an empty list when the JSON is not a list', () async {
      final prefs = await prefsWith({
        SessionStorageService.storageKey: '{"id": "a"}',
      });

      expect(SessionStorageService(prefs).loadSessions(), isEmpty);
    });

    test('skips entries that are not objects and keeps the good ones',
        () async {
      final good = makeSession('a', DateTime(2026, 1, 1));
      final prefs = await prefsWith({
        SessionStorageService.storageKey:
            jsonEncode([good.toJson(), 42, 'garbage', null]),
      });

      final loaded = SessionStorageService(prefs).loadSessions();

      expect(loaded.length, 1);
      expect(loaded.first.id, 'a');
    });
  });

  group('SessionStorageService saving', () {
    test('saved sessions load back with all their data', () async {
      final service = SessionStorageService(await prefsWith({}));
      final sessions = [
        makeSession('b', DateTime(2026, 1, 2)),
        makeSession('a', DateTime(2026, 1, 1)),
      ];

      await service.saveSessions(sessions);
      final loaded = service.loadSessions();

      expect(loaded.length, 2);
      expect(asJson(loaded), asJson(sessions));
    });

    test('saving again replaces the previous history', () async {
      final service = SessionStorageService(await prefsWith({}));
      await service.saveSessions([
        makeSession('a', DateTime(2026, 1, 1)),
        makeSession('b', DateTime(2026, 1, 2)),
      ]);

      await service.saveSessions([makeSession('c', DateTime(2026, 1, 3))]);
      final loaded = service.loadSessions();

      expect(loaded.map((s) => s.id).toList(), ['c']);
    });

    test('saving an empty list clears the history', () async {
      final service = SessionStorageService(await prefsWith({}));
      await service.saveSessions([makeSession('a', DateTime(2026, 1, 1))]);

      await service.saveSessions([]);

      expect(service.loadSessions(), isEmpty);
    });
  });
}