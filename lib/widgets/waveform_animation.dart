import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated equalizer-style waveform displayed while the app is listening.
///
/// Shows [barCount] vertical bars that smoothly oscillate at randomised
/// frequencies, creating an organic audio-waveform feel. Each bar has an
/// independent speed and phase offset so no two bars move in sync.
class WaveformAnimation extends StatefulWidget {
  const WaveformAnimation({
    super.key,
    this.barCount = 28,
    this.isActive = false,
  });

  final int barCount;

  /// When false the bars collapse to a flat line (idle state).
  final bool isActive;

  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BarConfig> _bars;
  final _rng = math.Random(42); // deterministic seed for consistent layout

  @override
  void initState() {
    super.initState();

    // Generate per-bar randomised config.
    _bars = List.generate(widget.barCount, (_) {
      return _BarConfig(
        speed: 0.8 + _rng.nextDouble() * 2.4,
        phase: _rng.nextDouble() * 2 * math.pi,
        maxHeightFraction: 0.35 + _rng.nextDouble() * 0.65,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: widget.isActive ? 1.0 : 0.0,
      child: SizedBox(
        height: 64,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, s) {
            final t = _controller.value * 2 * math.pi;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(widget.barCount, (i) {
                final cfg = _bars[i];
                // Drive bar height with a sine wave per bar.
                final rawHeight = widget.isActive
                    ? (0.5 + 0.5 * math.sin(t * cfg.speed + cfg.phase)) *
                          cfg.maxHeightFraction
                    : 0.04;

                final barHeight = (rawHeight * 64).clamp(4.0, 60.0);

                // Colour interpolates from purple (short bars) to cyan (tall).
                final frac = rawHeight / cfg.maxHeightFraction;
                final color = Color.lerp(
                  AppTheme.neonPurple,
                  AppTheme.neonCyan,
                  frac,
                )!.withValues(alpha: 0.85);

                return Container(
                  width: 3,
                  height: barHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Immutable per-bar animation configuration.
class _BarConfig {
  const _BarConfig({
    required this.speed,
    required this.phase,
    required this.maxHeightFraction,
  });

  /// Multiplier applied to the global time value.
  final double speed;

  /// Initial phase offset in radians.
  final double phase;

  /// Max bar height as a fraction of the 64px container.
  final double maxHeightFraction;
}
