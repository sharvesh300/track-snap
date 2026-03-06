/// Immutable data model representing a detected song from the recognition backend.
///
/// Maps directly to the WebSocket response:
/// ```json
/// {"matched": true, "name": "...", "confidence": 0.9876, "offset_s": 12.3, "timestamp": "HH:MM:SS"}
/// ```
class SongModel {
  const SongModel({
    required this.name,
    required this.confidence,
    required this.offsetSeconds,
    required this.timestamp,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      offsetSeconds: (json['offset_s'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
    );
  }

  /// Song name returned by the recognition backend.
  final String name;

  /// Detection confidence in the range [0.0, 1.0].
  final double confidence;

  /// Time offset (seconds) within the reference track where the match was found.
  final double offsetSeconds;

  /// Server-side wall-clock timestamp of the recognition event (HH:MM:SS).
  final String timestamp;

  /// Confidence as a 0–100 integer, suitable for display.
  int get confidencePercent => (confidence * 100).round();

  // ── Mock data used during UI development ─────────────────────────────────
  static const SongModel mock = SongModel(
    name: 'Blinding Lights',
    confidence: 0.98,
    offsetSeconds: 12.0,
    timestamp: '00:00:03',
  );

  @override
  String toString() =>
      'SongModel(name: $name, confidence: $confidencePercent%)';
}
