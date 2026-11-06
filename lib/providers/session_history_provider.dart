import 'package:flutter/foundation.dart';

import '../models/session_model.dart';
import '../services/session_storage_service.dart';
import 'timer_provider.dart';

class SessionHistoryProvider extends ChangeNotifier {
  // Optional so SessionHistoryProvider() still works in memory only,
  // which the Step 1 tests rely on.
SessionHistoryProvider({this._storage});

  final SessionStorageService? _storage;
  final List<SessionModel> _sessions = [];

  // Used by generateId() so two ids created in the same microsecond differ.
  static int _idCounter = 0;

  // Newest session first, as a read-only view.
  List<SessionModel> get sessions => List.unmodifiable(_sessions);

  // Creates an id like "1730800000000000_0".
  static String generateId() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    return '${micros}_${_idCounter++}';
  }

  // Loads saved sessions from storage. Call once at app start.
  Future<void> load() async {
    final storage = _storage;
    if (storage == null) return;

    final stored = storage.loadSessions();

    _sessions.clear();
    final seenIds = <String>{};
    for (final session in stored) {
      // Ignore duplicate ids in case the stored data contains any.
      if (seenIds.add(session.id)) {
        _sessions.add(session);
      }
    }
    _sortNewestFirst();
    notifyListeners();
  }

  // Returns true if added, false if a session with this id already exists.
  bool addSession(SessionModel session) {
    final alreadyExists = _sessions.any((s) => s.id == session.id);
    if (alreadyExists) return false;

    _sessions.add(session);
    _sortNewestFirst();
    notifyListeners();
    _save();
    return true;
  }

  // Saves the timer's ended session with the given note, then clears the
  // timer so the same session can't be saved twice.
  // Returns false (and changes nothing) if there is nothing to save.
  bool savePendingSession(TimerProvider timer, String note) {
    if (!timer.hasUnsavedSession) return false;
    final startedAt = timer.startedAt;
    if (startedAt == null) return false;

    final session = SessionModel(
      id: generateId(),
      startedAt: startedAt,
      plannedSeconds: timer.selectedMinutes * 60,
      actualSeconds: timer.actualDurationSeconds,
      note: note.trim(),
    );

    final added = addSession(session);
    if (added) {
      // Clears the pending state right away; a second call now returns false.
      timer.resetSession();
    }
    return added;
  }

  // Returns true if a session was removed, false if the id wasn't found.
  bool deleteSession(String id) {
    final countBefore = _sessions.length;
    _sessions.removeWhere((s) => s.id == id);
    final removed = _sessions.length < countBefore;
    if (removed) {
      notifyListeners();
      _save();
    }
    return removed;
  }

  void _sortNewestFirst() {
    _sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  // Saves in the background. A failed save must not crash the app, and
  // the in-memory history stays correct either way.
  Future<void> _save() async {
    try {
      await _storage?.saveSessions(_sessions);
    } catch (_) {
      // Ignored on purpose.
    }
  }
}