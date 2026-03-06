import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

typedef AudioChunkCallback = void Function(Uint8List chunk);

/// Records audio at 8 000 Hz (mono, PCM-16) and streams raw chunks
/// to the provided [AudioChunkCallback].
class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  StreamController<Uint8List>? _chunkController;
  StreamSubscription<Uint8List>? _chunkSub;
  bool _isOpen = false;

  /// Requests the microphone permission and opens the recorder.
  /// Must be called before [startRecording].
  Future<void> init() async {
    if (_isOpen) return;

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw Exception(
        'Microphone permission denied. '
        'Please enable it in system settings.',
      );
    }

    await _recorder.openRecorder();
    _recorder.setLogLevel(Level.off); // suppress flutter_sound debug output
    _isOpen = true;
  }

  /// Starts recording and calls [onChunk] for every PCM-16 frame received.
  ///
  /// The audio is captured at 8 000 Hz, mono channel, so each chunk is a
  /// raw 16-bit little-endian byte buffer ready to be forwarded over the
  /// WebSocket connection.
  Future<void> startRecording(AudioChunkCallback onChunk) async {
    if (!_isOpen) await init();
    if (_recorder.isRecording) return;

    _chunkController = StreamController<Uint8List>();

    _chunkSub = _chunkController!.stream.listen(onChunk);

    await _recorder.startRecorder(
      toStream: _chunkController!.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 8000,
    );
  }

  /// Stops the current recording and cleans up the chunk stream.
  Future<void> stopRecording() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    await _chunkSub?.cancel();
    _chunkSub = null;
    await _chunkController?.close();
    _chunkController = null;
  }

  /// Stops recording and closes the underlying recorder.
  /// Call once when the service is no longer needed.
  Future<void> dispose() async {
    await stopRecording();
    if (_isOpen) {
      await _recorder.closeRecorder();
      _isOpen = false;
    }
  }
}
