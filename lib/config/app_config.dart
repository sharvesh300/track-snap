/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  /// WebSocket endpoint for the song-recognition backend.
  /// Update this to point to your server before running.
  static const String wsUrl = 'ws://10.169.136.31:8000/ws/stream';
}
