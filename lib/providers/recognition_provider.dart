import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/listen_state.dart';
import '../models/song_model.dart';
import '../services/audio_service.dart';
import '../services/websocket_service.dart';

/// Combines [AudioService] and [WebSocketService] and exposes reactive
/// recognition state to the UI.
///
/// Lifecycle:
/// 1. [startListening] → opens WS, starts recording, streams binary chunks.
/// 2. Server reply arrives → state transitions to [ListenState.detected] or
///    [ListenState.error] and recording/WS are closed automatically.
///    Frames with `matched: false` are silently ignored (progress signal only).
/// 3. [stopListening] cancels everything and returns to [ListenState.idle].
/// 4. [dismissResult] clears the result card back to [ListenState.idle].
class RecognitionProvider extends ChangeNotifier {
  RecognitionProvider() : _audio = AudioService(), _ws = WebSocketService();

  final AudioService _audio;
  final WebSocketService _ws;
  StreamSubscription<RecognitionResult>? _resultSub;

  ListenState _state = ListenState.idle;
  SongModel? _song;
  String? _errorMessage;

  /// Current recognition state – drives the UI.
  ListenState get state => _state;

  /// The last successfully identified song.
  SongModel? get song => _song;

  /// Human-readable error message when [state] is [ListenState.error].
  String? get errorMessage => _errorMessage;

  // ── Public actions ─────────────────────────────────────────────────────

  Future<void> startListening() async {
    if (_state == ListenState.listening) return;

    _song = null;
    _errorMessage = null;
    _state = ListenState.listening;
    notifyListeners();

    try {
      await _ws.connect();
      _resultSub = _ws.results.listen(_onResult);
      await _audio.startRecording(_ws.sendAudioChunk);
    } catch (e) {
      _errorMessage = e.toString();
      _state = ListenState.error;
      notifyListeners();
      await _cleanup();
    }
  }

  Future<void> stopListening() async {
    await _cleanup();
    _state = ListenState.idle;
    notifyListeners();
  }

  /// Clears a result or no-match card and returns to idle.
  void dismissResult() {
    _song = null;
    _state = ListenState.idle;
    notifyListeners();
  }

  // ── Internal ───────────────────────────────────────────────────────────

  void _onResult(RecognitionResult result) {
    switch (result) {
      case MatchedResult(:final song):
        _song = song;
        _state = ListenState.detected;
        notifyListeners();
        unawaited(_cleanup());

      case RecognitionError(:final message):
        _errorMessage = message;
        _state = ListenState.error;
        notifyListeners();
        unawaited(_cleanup());
    }
  }

  Future<void> _cleanup() async {
    await _resultSub?.cancel();
    _resultSub = null;
    await _audio.stopRecording();
    _ws.disconnect();
  }

  @override
  Future<void> dispose() async {
    await _cleanup();
    _ws.dispose();
    await _audio.dispose();
    super.dispose();
  }
}
