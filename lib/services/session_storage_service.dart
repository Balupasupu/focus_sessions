import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_model.dart';

class SessionStorageService {
  // The single key under which the whole history is stored.
  static const String storageKey = 'focus_sessions_history';

  final SharedPreferences _prefs;

  SessionStorageService(this._prefs);

  // Reads the saved sessions. Never throws: missing or damaged data
  // gives an empty list (or just the readable entries).
  List<SessionModel> loadSessions() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final sessions = <SessionModel>[];
      for (final item in decoded) {
        try {
          if (item is Map<String, dynamic>) {
            sessions.add(SessionModel.fromJson(item));
          }
        } catch (_) {
          // Skip one damaged entry; keep the rest of the history.
        }
      }
      return sessions;
    } catch (_) {
      // The stored text was not valid JSON.
      return [];
    }
  }

  // Replaces the saved history with the given sessions.
  // The JSON text is built immediately, before any waiting.
  Future<bool> saveSessions(List<SessionModel> sessions) {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    return _prefs.setString(storageKey, encoded);
  }
}