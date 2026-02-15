import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/adaptive_colors.dart';
import '../core/constants/app_colors.dart';
import '../services/session_engine.dart';
import '../services/tts_service.dart';

/// A quiz-style review card that shows a French word and 4 English options.
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
    widget.ttsService.speakAuto(widget.question.word.french);
  }

  void _onOptionTap(int index) {
    if (_answered) return;
    final responseTime = DateTime.now().difference(_startTime).inMilliseconds;
    final isCorrect = index == widget.question.correctIndex;

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        widget.onComplete(isCorrect, responseTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.question.word;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // French word
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
          // Phonetic
          Text(
            word.phonetic,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Speaker replay button
          IconButton(
            onPressed: () => widget.ttsService.speak(word.french),
            icon: Icon(
              Icons.volume_up_rounded,
              size: 28,
              color: AppColors.gold,
            ),
            tooltip: 'Replay audio',
          ),
          const Spacer(flex: 1),
          // 2x2 option grid
          _buildOptionsGrid(context),
          const Spacer(flex: 2),
        ],
      ),
    );
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
    ).animate().fadeIn(duration: 200.ms, delay: (50 * index).ms);
  }
}
