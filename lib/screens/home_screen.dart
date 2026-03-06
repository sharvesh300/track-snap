import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/listen_state.dart';
import '../providers/recognition_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/header_bar.dart';
import '../widgets/listen_button.dart';
import '../widgets/song_result_card.dart';
import '../widgets/waveform_animation.dart';

/// The sole screen of TrackSnap.
///
/// Reads [RecognitionProvider] from context and drives the UI accordingly:
/// 1. Idle → user taps the button.
/// 2. Listening → audio is recorded and streamed to the backend.
/// 3. Detected / NoMatch / Error → result card or hint text updates.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleButtonTap(BuildContext context, ListenState state) {
    final provider = context.read<RecognitionProvider>();
    switch (state) {
      case ListenState.idle:
      case ListenState.error:
        provider.startListening();
      case ListenState.listening:
        provider.stopListening();
      case ListenState.detected:
      case ListenState.noMatch:
        provider.dismissResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecognitionProvider>();
    final state = provider.state;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────────
              HeaderBar(onSettingsTap: () {}),

              // ── Spacer / greeting section ──────────────────────────────────
              const Expanded(flex: 2, child: _GreetingSection()),

              // ── Detection button ───────────────────────────────────────────
              ListenButton(
                state: state,
                onTap: () => _handleButtonTap(context, state),
              ),

              const SizedBox(height: 28),

              // ── Waveform ───────────────────────────────────────────────────
              WaveformAnimation(isActive: state == ListenState.listening),

              // ── Hint text below waveform ───────────────────────────────────
              const SizedBox(height: 12),
              _HintText(state: state, errorMessage: provider.errorMessage),

              // ── Spacer + result card ──────────────────────────────────────
              // Card lives inside the Expanded so it can never overflow the column.
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: provider.song != null
                        ? SongResultCard(
                            song: provider.song!,
                            isVisible: state == ListenState.detected,
                            onDismiss: provider.dismissResult,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting section ───────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
                'What\'s playing?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 700.ms)
              .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 700.ms),

          const SizedBox(height: 8),

          Text(
            'Tap the button to identify\nany song around you',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms, duration: 700.ms),
        ],
      ),
    );
  }
}

// ── Hint text ──────────────────────────────────────────────────────────────

class _HintText extends StatelessWidget {
  const _HintText({required this.state, this.errorMessage});

  final ListenState state;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (state) {
      ListenState.idle => ('', AppTheme.textSecondary),
      ListenState.listening => (
        'Listening… hold near the music source',
        AppTheme.textSecondary,
      ),
      ListenState.detected => ('Song identified!', const Color(0xFF22C55E)),
      ListenState.noMatch => (
        'No match found. Tap to try again.',
        AppTheme.textMuted,
      ),
      ListenState.error => (
        errorMessage ?? 'Something went wrong.',
        Colors.redAccent,
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: text.isEmpty
          ? const SizedBox(key: ValueKey('empty'), height: 20)
          : Text(
              text,
              key: ValueKey(text),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}
