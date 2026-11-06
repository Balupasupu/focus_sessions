import 'dart:async';

import 'package:flutter/foundation.dart';

class TimerProvider extends ChangeNotifier {
  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _startedAt;
  Timer? _timer;

  int get selectedMinutes => _selectedMinutes;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  // True while a started session is temporarily paused. A paused session is
  // still in progress, so it is not "unsaved" yet.
  bool get isPaused => _isPaused;

  // When the current (or last) session was started. Null before the first
  // start and after resetSession().
  DateTime? get startedAt => _startedAt;

  // How many seconds of focus actually happened in this session.
  int get actualDurationSeconds => _selectedMinutes * 60 - _remainingSeconds;

  // True when a session has ended (manually or at 00:00) and has not been
  // saved or discarded yet.
  bool get hasUnsavedSession =>
      !_isRunning &&
      !_isPaused &&
      _startedAt != null &&
      actualDurationSeconds > 0;

  // Turns 1500 into "25:00", 1499 into "24:59", and so on.
  String get formattedTime => _format(_remainingSeconds);

  // The focused time of the ended session, in the same MM:SS style.
  String get formattedActualDuration => _format(actualDurationSeconds);

  String _format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void selectDuration(int minutes) {
    // Locked while running, and while an ended session is waiting to be
    // saved or discarded (changing it would silently erase that session).
    if (_isRunning || _isPaused || hasUnsavedSession) return;
    _selectedMinutes = minutes;
    _remainingSeconds = minutes * 60;
    notifyListeners();
  }

  void startSession() {
    // Can't start while running, paused, or while an unsaved session is
    // pending.
    if (_isRunning || _isPaused || hasUnsavedSession) return;
    // Every session begins from the full selected duration.
    _remainingSeconds = _selectedMinutes * 60;
    _startedAt = DateTime.now();
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  // Freezes the countdown. The session stays in progress until it is
  // resumed or ended.
  void pauseSession() {
    if (!_isRunning) return;
    _stopTimer();
    _isRunning = false;
    _isPaused = true;
    notifyListeners();
  }

  // Continues a paused session from the remaining time.
  void resumeSession() {
    if (!_isPaused) return;
    _isPaused = false;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  // Stops the timer but keeps remainingSeconds, so the actual duration
  // can still be read (and saved) afterwards. Works while running or paused.
  void endSession() {
    if (!_isRunning && !_isPaused) return;
    _stopTimer();
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  // Clears the session and puts the countdown back to the full duration.
  // Used after saving, and for Discard.
  void resetSession() {
    _stopTimer();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = _selectedMinutes * 60;
    _startedAt = null;
    notifyListeners();
  }

  void _tick() {
    _remainingSeconds--;
    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
      _stopTimer();
      _isRunning = false;
    }
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}