import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/header_bar.dart';
import '../widgets/listen_button.dart';
import '../widgets/song_result_card.dart';
import '../widgets/waveform_animation.dart';

/// The sole screen of TrackSnap.
///
/// Owns all detection UI state and drives the mock detection flow:
/// 1. Idle → user taps the button.
/// 2. Listening → waveform appears, 3-second mock "analysis" timer starts.
/// 3. Detected → song result card slides up.
///
/// Tapping the button while listening cancels and returns to idle.
/// Dismissing the result card also returns to idle.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ListenState _listenState = ListenState.idle;
  SongModel? _detectedSong;

  void _handleButtonTap() {
    switch (_listenState) {
      case ListenState.idle:
        _startListening();
      case ListenState.listening:
        _resetToIdle();
      case ListenState.detected:
        _resetToIdle();
    }
  }

  /// Begins the mock detection flow.
  void _startListening() {
    setState(() {
      _listenState = ListenState.listening;
      _detectedSong = null;
    });

    // Simulate a 3-second audio analysis delay.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_listenState != ListenState.listening) return; // was cancelled
      setState(() {
        _listenState = ListenState.detected;
        _detectedSong = SongModel.mock;
      });
    });
  }

  void _resetToIdle() {
    setState(() {
      _listenState = ListenState.idle;
      _detectedSong = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ListenButton(state: _listenState, onTap: _handleButtonTap),

              const SizedBox(height: 28),

              // ── Waveform ───────────────────────────────────────────────────
              WaveformAnimation(
                isActive: _listenState == ListenState.listening,
              ),

              // ── Hint text below waveform ───────────────────────────────────
              const SizedBox(height: 12),
              _HintText(state: _listenState),

              // ── Spacer before card ─────────────────────────────────────────
              const Expanded(flex: 3, child: SizedBox()),

              // ── Song result card ───────────────────────────────────────────
              SongResultCard(
                song: _detectedSong ?? SongModel.mock,
                isVisible: _listenState == ListenState.detected,
                onDismiss: _resetToIdle,
              ),

              const SizedBox(height: 32),
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
  const _HintText({required this.state});

  final ListenState state;

  @override
  Widget build(BuildContext context) {
    final text = switch (state) {
      ListenState.idle => '',
      ListenState.listening => 'Hold near the music source…',
      ListenState.detected => 'Song identified!',
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: text.isEmpty
          ? const SizedBox(key: ValueKey('empty'), height: 20)
          : Text(
              text,
              key: ValueKey(text),
              style: TextStyle(
                color: state == ListenState.detected
                    ? const Color(0xFF22C55E)
                    : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
    );
  }
}
