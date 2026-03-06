/// The possible states for the song-recognition flow.
enum ListenState {
  /// Waiting for the user to start.
  idle,

  /// Actively recording and streaming audio to the backend.
  listening,

  /// Recognition succeeded – a song was identified.
  detected,

  /// Recognition returned no match.
  noMatch,

  /// An error occurred (permissions denied, network failure, etc.).
  error,
}
