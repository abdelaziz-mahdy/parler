import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/constants/responsive.dart';
import '../../widgets/french_card.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final int chapterId;
  const QuizPlayScreen({super.key, required this.chapterId});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(chapterQuestionsProvider(widget.chapterId));

    if (questions.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_rounded,
                    size: 64, color: context.textLight),
                const SizedBox(height: 16),
                Text(
                  'No quiz available yet',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_completed) {
      return _QuizResultsView(
        score: _score,
        total: questions.length,
        onRetry: () => setState(() {
          _currentIndex = 0;
          _score = 0;
          _selectedAnswer = null;
          _answered = false;
          _completed = false;
        }),
        onDone: () => context.pop(),
      );
    }

    final question = questions[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 800,
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_currentIndex > 0 && !_completed) {
                        final leave = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Leave quiz?'),
                            content: const Text(
                              'Your progress will be lost.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Stay'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Leave'),
                              ),
                            ],
                          ),
                        );
                        if (leave == true && context.mounted) {
                          context.pop();
                        }
                      } else {
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.close_rounded),
                    color: context.textPrimary,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / questions.length,
                        minHeight: 6,
                        backgroundColor: context.progressBgColor,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${questions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Question
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    question.question,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _difficultyColor(context, question.difficulty)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      question.difficulty.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _difficultyColor(context, question.difficulty),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...question.options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedAnswer == option;
                    final isCorrect = option == question.correctAnswer;
                    Color borderColor = context.dividerColor;
                    Color bgColor = context.surfaceColor;
                    Color textColor = context.textPrimary;

                    if (_answered) {
                      if (isCorrect) {
                        borderColor = AppColors.success;
                        bgColor = AppColors.successLight;
                        textColor = AppColors.success;
                      } else if (isSelected && !isCorrect) {
                        borderColor = AppColors.error;
                        bgColor = AppColors.errorLight;
                        textColor = AppColors.error;
                      }
                    } else if (isSelected) {
                      borderColor = context.navyAdaptive;
                      bgColor = context.navyAdaptive.withValues(alpha: 0.05);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                        onTap: _answered
                            ? null
                            : () => setState(() => _selectedAnswer = option),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected || (_answered && isCorrect)
                                  ? 2
                                  : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected || (_answered && isCorrect)
                                      ? borderColor
                                      : context.dividerColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: _answered
                                      ? Icon(
                                          isCorrect
                                              ? Icons.check_rounded
                                              : (isSelected
                                                  ? Icons.close_rounded
                                                  : null),
                                          color: AppColors.white,
                                          size: 16,
                                        )
                                      : Text(
                                          String.fromCharCode(65 + i),
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.white
                                                : context.textSecondary,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  option,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: (100 + i * 60).ms,
                          duration: 300.ms,
                        )
                        .slideX(begin: 0.05);
                  }),
                  if (_answered && question.explanation != null) ...[
                    const SizedBox(height: 8),
                    FrenchCard(
                      margin: EdgeInsets.zero,
                      color: context.creamColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: context.navyAdaptive, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              question.explanation!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: context.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ],
                ],
              ),
            ),
            // Bottom button
            Builder(builder: (context) {
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              return Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : AppColors.navy.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswer == null
                      ? null
                      : () {
                          if (!_answered) {
                            setState(() {
                              _answered = true;
                              if (_selectedAnswer ==
                                  question.correctAnswer) {
                                _score++;
                              }
                            });
                          } else {
                            if (_currentIndex < questions.length - 1) {
                              setState(() {
                                _currentIndex++;
                                _selectedAnswer = null;
                                _answered = false;
                              });
                            } else {
                              final pct = ((_score / questions.length) * 100)
                                  .round();
                              ref
                                  .read(progressProvider.notifier)
                                  .recordQuizScore(
                                      widget.chapterId, pct);
                              setState(() => _completed = true);
                            }
                          }
                        },
                  child: Text(_answered ? 'Continue' : 'Check'),
                ),
              ),
            );
            }),
          ],
        ),
        ),
      ),
    );
  }

  Color _difficultyColor(BuildContext context, String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return context.navyAdaptive;
    }
  }
}

class _QuizResultsView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _QuizResultsView({
    required this.score,
    required this.total,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? ((score / total) * 100).round() : 0;
    final passed = pct >= 70;

    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 800,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: (passed ? AppColors.success : AppColors.warning)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed
                          ? Icons.celebration_rounded
                          : Icons.refresh_rounded,
                      color: passed ? AppColors.success : AppColors.warning,
                      size: 48,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 28),
                  Text(
                    passed ? 'Excellent!' : 'Keep Practicing!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'You scored $score out of $total ($pct%)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                Text(
                  '+$pct XP',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDone,
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
