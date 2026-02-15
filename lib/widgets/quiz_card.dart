import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/adaptive_colors.dart';
import '../core/constants/app_colors.dart';
import '../models/vocabulary_word.dart';
import '../services/session_engine.dart';
import '../services/tts_service.dart';

/// A quiz-style review card that shows a word and 4 options.
/// Supports frenchToEnglish, englishToFrench, and cloze question modes.
class QuizCard extends StatefulWidget {
  final ReviewQuestion question;
  final TtsService ttsService;
  final void Function(bool isCorrect, int responseTimeMs) onComplete;

  const QuizCard({
    super.key,
    required this.question,
    required this.ttsService,
    required this.onComplete,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int? _selectedIndex;
  bool _answered = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    // Only auto-play TTS for frenchToEnglish mode
    if (widget.question.mode == QuestionMode.frenchToEnglish) {
      widget.ttsService.speakAuto(widget.question.word.french);
    }
  }

  void _onOptionTap(int index) {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_startTime).inMilliseconds;
    final isCorrect = index == widget.question.correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    // For englishToFrench: play TTS of the French word after answering
    if (widget.question.mode == QuestionMode.englishToFrench) {
      widget.ttsService.speak(widget.question.word.french);
    }
    // For cloze: play TTS of the full example sentence after answering
    if (widget.question.mode == QuestionMode.cloze) {
      widget.ttsService.speak(widget.question.word.exampleFr);
    }

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onComplete(isCorrect, responseTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.question.word;
    final mode = widget.question.mode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            // Question header — varies by mode
            _buildQuestionHeader(context, word, mode),
            const SizedBox(height: 32),
            // 2x2 option grid
            _buildOptionsGrid(context),
            // Post-answer context section
            if (_answered) ...[
              const SizedBox(height: 20),
              _buildPostAnswerContext(context, word),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(
    BuildContext context,
    VocabularyWord word,
    QuestionMode mode,
  ) {
    switch (mode) {
      case QuestionMode.frenchToEnglish:
        return _buildFrenchToEnglishHeader(context, word);
      case QuestionMode.englishToFrench:
        return _buildEnglishToFrenchHeader(context, word);
      case QuestionMode.cloze:
        return _buildClozeHeader(context);
    }
  }

  Widget _buildFrenchToEnglishHeader(BuildContext context, VocabularyWord word) {
    return Column(
      children: [
        Text(
          'What does this mean?',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          word.frenchWithArticle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        Text(
          word.phonetic,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        IconButton(
          onPressed: () => widget.ttsService.speak(word.french),
          icon: Icon(
            Icons.volume_up_rounded,
            size: 28,
            color: AppColors.gold,
          ),
          tooltip: 'Replay audio',
        ),
      ],
    );
  }

  Widget _buildEnglishToFrenchHeader(BuildContext context, VocabularyWord word) {
    return Column(
      children: [
        Text(
          'How do you say this in French?',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          word.english,
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  Widget _buildClozeHeader(BuildContext context) {
    final sentence =
        widget.question.clozeSentence ?? widget.question.word.exampleFr;
    return Column(
      children: [
        Text(
          'Fill in the blank',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sentence,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  /// Post-answer learning context: example sentence, memory hint, correction.
  Widget _buildPostAnswerContext(BuildContext context, VocabularyWord word) {
    final isCorrect = _selectedIndex == widget.question.correctIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.creamColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Correction line for wrong answers
          if (!isCorrect) ...[
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.red),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Correct: ${word.frenchWithArticle} = ${word.english}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          // Example sentence
          Text(
            word.exampleFr,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.exampleEn,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: context.textSecondary,
            ),
          ),
          // Memory hint
          if (widget.question.memoryHint != null &&
              widget.question.memoryHint!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: context.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.question.memoryHint!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildOptionsGrid(BuildContext context) {
    final options = widget.question.options;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildOption(context, 0, options[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildOption(context, 1, options[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOption(context, 2, options[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildOption(context, 3, options[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, int index, String text) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (!_answered) {
      bgColor = context.surfaceColor;
      borderColor = context.dividerColor;
      textColor = context.textPrimary;
    } else if (index == widget.question.correctIndex) {
      bgColor = AppColors.success.withValues(alpha: 0.15);
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else if (index == _selectedIndex) {
      bgColor = AppColors.red.withValues(alpha: 0.15);
      borderColor = AppColors.red;
      textColor = AppColors.red;
    } else {
      bgColor = context.surfaceColor.withValues(alpha: 0.5);
      borderColor = context.dividerColor.withValues(alpha: 0.5);
      textColor = context.textLight;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _answered ? null : () => _onOptionTap(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_answered && index == widget.question.correctIndex)
                const Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColors.success),
              if (_answered &&
                  index == _selectedIndex &&
                  index != widget.question.correctIndex)
                const Icon(Icons.cancel_rounded,
                    size: 20, color: AppColors.red),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
