import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';

/// Glassmorphic card that slides up from the bottom of the screen once a
/// song has been detected.
///
/// Visibility is controlled by [isVisible]. The card handles its own
/// entrance animation internally so the parent only needs to toggle the flag.
class SongResultCard extends StatelessWidget {
  const SongResultCard({
    super.key,
    required this.song,
    required this.isVisible,
    this.onDismiss,
  });

  final SongModel song;
  final bool isVisible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1.2),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: isVisible
            ? _CardBody(song: song, onDismiss: onDismiss)
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ── Card body ──────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({required this.song, this.onDismiss});

  final SongModel song;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child:
          DecoratedBox(
                decoration: BoxDecoration(
                  // Glassmorphism: semi-transparent surface + frosted border.
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.glowPurple.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: -4,
                      offset: const Offset(0, -4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Album art ───────────────────────────────────────────────
                        _AlbumArt(url: song.albumArtUrl),
                        const SizedBox(width: 16),

                        // ── Metadata ────────────────────────────────────────────────
                        Expanded(child: _SongMeta(song: song)),

                        // ── Dismiss ─────────────────────────────────────────────────
                        if (onDismiss != null)
                          GestureDetector(
                            onTap: onDismiss,
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              // Stagger the inner content with flutter_animate for extra polish.
              .animate()
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

// ── Album art ──────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowPurple.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, err, stack) => const ColoredBox(
            color: AppTheme.surfaceVariant,
            child: Icon(
              Icons.album_rounded,
              color: AppTheme.neonPurple,
              size: 36,
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const ColoredBox(
              color: AppTheme.surfaceVariant,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.neonPurple,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Song metadata column ───────────────────────────────────────────────────

class _SongMeta extends StatelessWidget {
  const _SongMeta({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    final confidence = song.confidence.toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
              song.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideX(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms),

        const SizedBox(height: 3),

        // Artist
        Text(
              song.artist,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
            .animate()
            .fadeIn(delay: 180.ms, duration: 400.ms)
            .slideX(begin: 0.2, end: 0, delay: 180.ms, duration: 400.ms),

        const SizedBox(height: 2),

        // Album
        Text(
          song.album,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

        const SizedBox(height: 8),

        // Confidence pill
        _ConfidencePill(confidence: confidence)
            .animate()
            .fadeIn(delay: 320.ms, duration: 400.ms)
            .slideX(begin: -0.1, end: 0, delay: 320.ms, duration: 400.ms),
      ],
    );
  }
}

// ── Confidence pill ────────────────────────────────────────────────────────

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({required this.confidence});

  final int confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$confidence% match',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
