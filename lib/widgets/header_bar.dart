import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Top app bar with logo mark, app name and a settings icon button.
/// Stateless – all interaction callbacks are lifted up.
class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key, this.onSettingsTap});

  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // ── Logo mark ────────────────────────────────────────────────────
              _LogoMark(),
              const SizedBox(width: 10),

              // ── App name ─────────────────────────────────────────────────────
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: Text(
                  'TrackSnap',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white, // will be masked by shader
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontSize: 22,
                  ),
                ),
              ),

              const Spacer(),

              // ── Settings button ───────────────────────────────────────────────
              _GlassIconButton(icon: Icons.tune_rounded, onTap: onSettingsTap),
            ],
          ),
        )
        // Fade + slide-down entrance animation triggered once at build time.
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

/// 36×36 gradient circle logo mark.
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowPurple,
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

/// Small glassmorphic icon button with a subtle frost border.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0x0FFFFFFF),
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: Color(0x1FFFFFFF), width: 1),
          ),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }
}
