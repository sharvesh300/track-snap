/// Immutable data model representing a detected song.
class SongModel {
  const SongModel({
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtUrl,
    required this.confidence,
    this.duration,
    this.releaseYear,
  });

  final String title;
  final String artist;
  final String album;

  /// URL (or asset path) for the album artwork.
  final String albumArtUrl;

  /// Detection confidence in the range [0, 100].
  final double confidence;

  final Duration? duration;
  final int? releaseYear;

  // ── Mock data used during UI development ─────────────────────────────────
  static const SongModel mock = SongModel(
    title: 'Blinding Lights',
    artist: 'The Weeknd',
    album: 'After Hours',
    albumArtUrl:
        'https://upload.wikimedia.org/wikipedia/en/e/e6/The_Weeknd_-_After_Hours.png',
    confidence: 98.0,
    releaseYear: 2020,
    duration: Duration(minutes: 3, seconds: 20),
  );

  @override
  String toString() =>
      'SongModel(title: $title, artist: $artist, confidence: $confidence%)';
}
