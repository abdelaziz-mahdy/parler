import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/adaptive_colors.dart';
import '../core/constants/app_colors.dart';
import '../services/session_engine.dart';
import '../services/tts_service.dart';

/// A word-matching quiz widget.
///
/// Displays 4 French words on the left and 4 English words on the right
/// (shuffled). The user taps a French word, then taps the matching English
/// word. Correct matches are highlighted green and locked; wrong matches
/// flash red briefly. Calls [onComplete] when all 4 pairs are matched.
class MatchingCard extends StatefulWidget {
  final MatchingChallenge challenge;
  final TtsService tts;
  final void Function(int wrongAttempts) onComplete;

  const MatchingCard({
    super.key,
    required this.challenge,
    required this.tts,
    required this.onComplete,
  });

  @override
  State<MatchingCard> createState() => _MatchingCardState();
}

class _MatchingCardState extends State<MatchingCard> {
  /// Indices of French items that have been correctly matched.
  final Set<int> _matchedFrench = {};

  /// Indices of English items that have been correctly matched.
  final Set<int> _matchedEnglish = {};

  /// Currently selected French index, or null if nothing is selected.
  int? _selectedFrench;

  /// Currently selected English index, or null if nothing is selected.
  int? _selectedEnglish;

  /// Index of the French button currently flashing red (wrong attempt).
  int? _wrongFrench;

  /// Index of the English button currently flashing red (wrong attempt).
  int? _wrongEnglish;

  /// Running count of incorrect attempts.
  int _wrongAttempts = 0;

  /// Keys used to trigger the scale-pulse animation on newly matched items.
  /// We regenerate a key for a slot when it becomes matched so
  /// flutter_animate replays its entrance animation.
  final Map<String, UniqueKey> _animKeys = {};

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------

  /// Build a lookup from frenchWithArticle -> english using the word list.
  Map<String, String> get _answerMap {
    final map = <String, String>{};
    for (final w in widget.challenge.words) {
      map[w.frenchWithArticle] = w.english;
    }
    return map;
  }

  UniqueKey _keyFor(String tag) {
    return _animKeys.putIfAbsent(tag, () => UniqueKey());
  }

  // ------------------------------------------------------------------
  // Selection logic
  // ------------------------------------------------------------------

  void _onFrenchTap(int index) {
    if (_matchedFrench.contains(index)) return;

    // Speak the French word via TTS.
    final frenchText = widget.challenge.shuffledFrench[index];
    widget.tts.speak(frenchText);

    setState(() {
      _selectedFrench = index;
      _selectedEnglish = null;
    });

    // If an English word was already selected before this tap, try to match.
    // (Not applicable here because we reset _selectedEnglish above, matching
    // only happens after selecting French then English.)
  }

  void _onEnglishTap(int index) {
    if (_matchedEnglish.contains(index)) return;

    setState(() {
      _selectedEnglish = index;
    });

    if (_selectedFrench != null) {
      _tryMatch(_selectedFrench!, index);
    }
  }

  void _tryMatch(int frenchIdx, int englishIdx) {
    final frenchText = widget.challenge.shuffledFrench[frenchIdx];
    final englishText = widget.challenge.shuffledEnglish[englishIdx];
    final correctEnglish = _answerMap[frenchText];

    if (correctEnglish == englishText) {
      // Correct match.
      setState(() {
        _matchedFrench.add(frenchIdx);
        _matchedEnglish.add(englishIdx);
        _selectedFrench = null;
        _selectedEnglish = null;
        // Reset animation keys so the pulse replays.
        _animKeys['fr_$frenchIdx'] = UniqueKey();
        _animKeys['en_$englishIdx'] = UniqueKey();
      });

      if (_matchedFrench.length == widget.challenge.shuffledFrench.length) {
        // All matched -- notify parent after a short delay so the user sees
        // the last green highlight.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onComplete(_wrongAttempts);
          }
        });
      }
    } else {
      // Wrong match.
      _wrongAttempts++;
      setState(() {
        _wrongFrench = frenchIdx;
        _wrongEnglish = englishIdx;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _wrongFrench = null;
            _wrongEnglish = null;
            _selectedFrench = null;
            _selectedEnglish = null;
          });
        }
      });
    }
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Match the pairs',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),

              // Two columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column -- French words
                  Expanded(
                    child: Column(
                      children: List.generate(
                        widget.challenge.shuffledFrench.length,
                        (i) => _buildFrenchButton(context, i),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right column -- English words
                  Expanded(
                    child: Column(
                      children: List.generate(
                        widget.challenge.shuffledEnglish.length,
                        (i) => _buildEnglishButton(context, i),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrenchButton(BuildContext context, int index) {
    final text = widget.challenge.shuffledFrench[index];
    final isMatched = _matchedFrench.contains(index);
    final isSelected = _selectedFrench == index && !isMatched;
    final isWrong = _wrongFrench == index;

    final button = _MatchButton(
      text: text,
      isItalic: true,
      isMatched: isMatched,
      isSelected: isSelected,
      isWrong: isWrong,
      onTap: () => _onFrenchTap(index),
    );

    if (isMatched) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: button
            .animate(key: _keyFor('fr_$index'))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 150.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.05, 1.05),
              end: const Offset(1.0, 1.0),
              duration: 150.ms,
            ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: button,
    );
  }

  Widget _buildEnglishButton(BuildContext context, int index) {
    final text = widget.challenge.shuffledEnglish[index];
    final isMatched = _matchedEnglish.contains(index);
    final isSelected = _selectedEnglish == index && !isMatched;
    final isWrong = _wrongEnglish == index;

    final button = _MatchButton(
      text: text,
      isItalic: false,
      isMatched: isMatched,
      isSelected: isSelected,
      isWrong: isWrong,
      onTap: () => _onEnglishTap(index),
    );

    if (isMatched) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: button
            .animate(key: _keyFor('en_$index'))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 150.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.05, 1.05),
              end: const Offset(1.0, 1.0),
              duration: 150.ms,
            ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: button,
    );
  }
}

// ------------------------------------------------------------------
// Individual match button
// ------------------------------------------------------------------

class _MatchButton extends StatelessWidget {
  final String text;
  final bool isItalic;
  final bool isMatched;
  final bool isSelected;
  final bool isWrong;
  final VoidCallback onTap;

  const _MatchButton({
    required this.text,
    required this.isItalic,
    required this.isMatched,
    required this.isSelected,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colours based on state.
    Color background;
    Color borderColor;
    Color textColor;

    if (isWrong) {
      background = AppColors.red;
      borderColor = AppColors.red;
      textColor = Colors.white;
    } else if (isMatched) {
      background = AppColors.success;
      borderColor = AppColors.success;
      textColor = Colors.white;
    } else if (isSelected) {
      background = AppColors.gold.withValues(alpha: 0.1);
      borderColor = AppColors.gold;
      textColor = context.textPrimary;
    } else {
      background = context.surfaceColor;
      borderColor = context.dividerColor;
      textColor = context.textPrimary;
    }

    return GestureDetector(
      onTap: isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
