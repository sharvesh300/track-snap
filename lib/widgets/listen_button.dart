import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The three possible states for the listen button.
enum ListenState { idle, listening, detected }

/// Large circular button that acts as the primary interaction point.
///
/// • Idle:      static gradient ring + mic icon.
/// • Listening: animated concentric pulse rings + spinning gradient.
/// • Detected:  check-mark icon with a green accent flash.
class ListenButton extends StatefulWidget {
  const ListenButton({super.key, required this.state, required this.onTap});

  final ListenState state;
  final VoidCallback onTap;

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton>
    with TickerProviderStateMixin {
  // Ring-pulse animation – three staggered repeating rings.
  late final AnimationController _pulseController;

  // Spinning gradient border animation.
  late final AnimationController _spinController;

  // Scale-down on tap.
  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _tapScale = Tween<double>(
      begin: 1.0,
      end: 0.91,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ListenButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ListenState.listening) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _tapController.forward();

  void _handleTapUp(TapUpDetails _) {
    _tapController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() => _tapController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _tapScale,
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Pulse rings (visible only while listening) ────────────────
              if (widget.state == ListenState.listening) ...[
                _PulseRing(
                  controller: _pulseController,
                  delay: 0.0,
                  maxScale: 1.8,
                ),
                _PulseRing(
                  controller: _pulseController,
                  delay: 0.35,
                  maxScale: 1.55,
                ),
                _PulseRing(
                  controller: _pulseController,
                  delay: 0.70,
                  maxScale: 1.30,
                ),
              ],

              // ── Ambient glow beneath button ───────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.state == ListenState.listening
                          ? AppTheme.glowPurple.withValues(alpha: 0.7)
                          : AppTheme.glowPurple.withValues(alpha: 0.3),
                      blurRadius: widget.state == ListenState.listening
                          ? 60
                          : 30,
                      spreadRadius: widget.state == ListenState.listening
                          ? 10
                          : 2,
                    ),
                    BoxShadow(
                      color: AppTheme.glowBlue.withValues(alpha: 0.25),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),

              // ── Spinning gradient ring border ─────────────────────────────
              AnimatedBuilder(
                animation: _spinController,
                builder: (context, s) => Transform.rotate(
                  angle: _spinController.value * 2 * 3.14159,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          AppTheme.neonPurple,
                          AppTheme.neonBlue,
                          AppTheme.neonCyan,
                          AppTheme.neonPurple,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Inner solid circle (masks the gradient ring to a border) ──
              const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1A2E),
                ),
                child: SizedBox(width: 150, height: 150),
              ),

              // ── Button face with icon ─────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: _ButtonFace(
                  state: widget.state,
                  key: ValueKey(widget.state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulse ring ─────────────────────────────────────────────────────────────

/// A single expanding + fading ring driven by a shared [AnimationController].
/// [delay] is a fractional offset (0–1) within the animation cycle.
class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.controller,
    required this.delay,
    required this.maxScale,
  });

  final AnimationController controller;
  final double delay;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, s) {
        // Shift the animation phase by [delay] and wrap around.
        final t = ((controller.value + delay) % 1.0);
        final scale = 1.0 + (maxScale - 1.0) * t;
        final opacity = (1.0 - t).clamp(0.0, 0.6);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.neonPurple.withValues(alpha: opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Button face ────────────────────────────────────────────────────────────

class _ButtonFace extends StatelessWidget {
  const _ButtonFace({super.key, required this.state});

  final ListenState state;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (state) {
      ListenState.idle => (
        Icons.mic_rounded,
        'TAP TO LISTEN',
        AppTheme.textSecondary,
      ),
      ListenState.listening => (
        Icons.graphic_eq_rounded,
        'LISTENING…',
        AppTheme.neonCyan,
      ),
      ListenState.detected => (
        Icons.check_circle_rounded,
        'FOUND IT!',
        const Color(0xFF22C55E),
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, b.width, b.height),
          ),
          child: Icon(icon, size: 42, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}
