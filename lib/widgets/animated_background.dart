import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Full-screen animated background with drifting blurred orbs and a
/// slow-rotating gradient overlay. Completely self-contained; no state
/// is lifted to the parent.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slow drift animation – full cycle every 20 seconds.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
        ),

        // Drifting orbs – three layered blurred circles.
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value; // 0.0 → 1.0
            return Stack(
              fit: StackFit.expand,
              children: [
                _Orb(
                  color: AppTheme.neonPurple.withValues(alpha: 0.18),
                  size: 340,
                  // Gentle Lissajous-like drift
                  dx: 0.15 + 0.25 * math.sin(2 * math.pi * t),
                  dy: 0.10 + 0.20 * math.cos(2 * math.pi * t),
                ),
                _Orb(
                  color: AppTheme.neonBlue.withValues(alpha: 0.14),
                  size: 280,
                  dx: 0.70 + 0.20 * math.cos(2 * math.pi * t + 1.0),
                  dy: 0.60 + 0.15 * math.sin(2 * math.pi * t + 0.5),
                ),
                _Orb(
                  color: AppTheme.neonCyan.withValues(alpha: 0.10),
                  size: 200,
                  dx: 0.50 + 0.20 * math.sin(2 * math.pi * t + 2.0),
                  dy: 0.75 + 0.12 * math.cos(2 * math.pi * t + 1.5),
                ),
              ],
            );
          },
        ),

        // Subtle noise / grain overlay using a very faint white container
        // (real grain would need a shader; this approximation keeps deps lean).
        Opacity(opacity: 0.025, child: Container(color: Colors.white)),

        // Child content sits on top.
        widget.child,
      ],
    );
  }
}

/// A single blurred glowing orb positioned at fractional [dx], [dy] offsets.
class _Orb extends StatelessWidget {
  const _Orb({
    required this.color,
    required this.size,
    required this.dx,
    required this.dy,
  });

  final Color color;
  final double size;

  /// Fractional position (0.0 – 1.0) relative to parent dimensions.
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    // Alignment maps fractional (0–1) coords to Flutter's (-1 to 1) space
    // so the orb's center sits at (dx * parentWidth, dy * parentHeight).
    return Align(
      alignment: Alignment(dx * 2 - 1, dy * 2 - 1),
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              )
              // Gaussian blur via ImageFilter is expensive when used inside
              // AnimatedBuilder, so we use flutter_animate's blur effect once
              // with a large sigma for a cheap pass.
              .animate(onPlay: (c) => c.forward())
              .blurXY(begin: 60, end: 80, duration: 0.ms),
    );
  }
}
