import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_config.dart';
import '../models/song_model.dart';

// ── Recognition result types ───────────────────────────────────────────────

sealed class RecognitionResult {
  const RecognitionResult();
}

class MatchedResult extends RecognitionResult {
  const MatchedResult(this.song);
  final SongModel song;
}

class RecognitionError extends RecognitionResult {
  const RecognitionError(this.message);
  final String message;
}

// ── WebSocket service ──────────────────────────────────────────────────────

/// Manages the WebSocket connection to the song-recognition backend.
///
/// Usage:
/// ```dart
/// await service.connect();
/// service.results.listen((result) { ... });
/// service.sendAudioChunk(pcmBytes);
/// service.disconnect();
/// ```
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  final _resultController = StreamController<RecognitionResult>.broadcast();

  /// Stream of parsed recognition results emitted by the server.
  Stream<RecognitionResult> get results => _resultController.stream;

  bool get isConnected => _channel != null;

  /// Opens a WebSocket connection to [AppConfig.wsUrl].
  Future<void> connect() async {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));

    _sub = _channel!.stream.listen(
      _handleMessage,
      onError: (Object error) {
        if (!_resultController.isClosed) {
          _resultController.add(RecognitionError(error.toString()));
        }
        disconnect();
      },
      onDone: disconnect,
    );
  }

  void _handleMessage(dynamic message) {
    if (_resultController.isClosed) return;
    try {
      final Map<String, dynamic> json =
          jsonDecode(message as String) as Map<String, dynamic>;

      // matched:false frames are progress signals – keep recording.
      if (json['matched'] == true) {
        _resultController.add(MatchedResult(SongModel.fromJson(json)));
      }
    } catch (e) {
      _resultController.add(RecognitionError('Invalid server response: $e'));
    }
  }

  /// Sends a raw PCM chunk to the server as binary data.
  void sendAudioChunk(Uint8List chunk) {
    _channel?.sink.add(chunk);
  }

  /// Closes the WebSocket connection and cancels the listener subscription.
  void disconnect() {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
  }

  /// Disposes resources. Call once when the service is no longer needed.
  void dispose() {
    disconnect();
    _resultController.close();
  }
}
