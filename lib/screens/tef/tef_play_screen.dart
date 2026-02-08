import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../models/tef_test.dart';
import '../../models/progress.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/constants/responsive.dart';
import '../../widgets/french_card.dart';

class TefPlayScreen extends ConsumerStatefulWidget {
  final String testId;
  const TefPlayScreen({super.key, required this.testId});

  @override
  ConsumerState<TefPlayScreen> createState() => _TefPlayScreenState();
}

class _TefPlayScreenState extends ConsumerState<TefPlayScreen> {
  // Flattened list of (passage, question) pairs
  late List<_FlatQuestion> _questions;
  late TefTest _test;
  bool _loaded = false;

  // Per-question state
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _completed = false;
  final Map<String, int> _answers = {};
  TefTestResult? _result;

  // Timer
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _totalSeconds = _test.timeMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _autoSubmit();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  /// When the timer expires, record the current selection if any and finish.
  void _autoSubmit() {
    _timer?.cancel();
    // If user selected but hasn't checked, record that selection
    if (_selectedIndex != null && !_answered) {
      final fq = _questions[_currentIndex];
      _answers[fq.question.id] = _selectedIndex!;
      if (_selectedIndex == fq.question.correctIndex) {
        _score++;
      }
    }
    _finishTest();
  }

  void _finishTest() {
    _timer?.cancel();
    final timeTaken = _totalSeconds - _remainingSeconds;
    final pct = _questions.isNotEmpty
        ? ((_score / _questions.length) * 100).round()
        : 0;
    final nclc = _nclcLevel(pct);

    final result = TefTestResult(
      testId: widget.testId,
      score: _score,
      totalQuestions: _questions.length,
      timeTakenSeconds: timeTaken,
      nclcLevel: nclc,
      completedAt: DateTime.now().toIso8601String(),
      answers: Map<String, int>.from(_answers),
    );

    ref.read(progressProvider.notifier).recordTefResult(result);
    ref.read(progressProvider.notifier).updateStreak();
    setState(() {
      _result = result;
      _completed = true;
    });
  }

  String _nclcLevel(int pct) {
    if (pct >= 85) return 'NCLC 9-10';
    if (pct >= 70) return 'NCLC 7-8';
    if (pct >= 55) return 'NCLC 5-6';
    if (pct >= 40) return 'NCLC 3-4';
    return 'NCLC 1-2';
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _resetTest() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _answered = false;
      _completed = false;
      _answers.clear();
      _result = null;
      _loaded = false;
    });
  }

  IconData _passageIcon(String type) {
    switch (type) {
      case 'sign':
        return Icons.signpost_outlined;
      case 'notice':
        return Icons.campaign_outlined;
      case 'advertisement':
        return Icons.storefront_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'letter':
        return Icons.mail_outlined;
      case 'article':
        return Icons.article_outlined;
      case 'form':
        return Icons.description_outlined;
      default:
        return Icons.text_snippet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final testsAsync = ref.watch(tefTestsProvider);

    return testsAsync.when(
      data: (tests) {
        // Initialise on first load (or after retry)
        if (!_loaded) {
          final test = tests.where((t) => t.id == widget.testId).firstOrNull;
          if (test == null) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 64, color: context.textLight),
                      const SizedBox(height: 16),
                      Text(
                        'Test not found',
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

          _test = test;
          _questions = [];
          for (final passage in test.passages) {
            for (final q in passage.questions) {
              _questions.add(_FlatQuestion(passage: passage, question: q));
            }
          }
          _loaded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
        }

        // Empty test guard
        if (_questions.isEmpty) {
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
                      'This test has no questions',
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

        // Results screen
        if (_completed && _result != null) {
          return _TefResultsView(
            result: _result!,
            test: _test,
            onRetry: _resetTest,
            onDone: () => context.pop(),
          );
        }

        // Active question view
        return _buildQuestionView(context);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: context.textLight),
                const SizedBox(height: 16),
                Text(
                  'Failed to load test',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(tefTestsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Question view
  // ---------------------------------------------------------------------------

  Widget _buildQuestionView(BuildContext context) {
    final fq = _questions[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timerWarning = _remainingSeconds < 300; // less than 5 minutes

    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 800,
          child: Column(
          children: [
            // ---- Top bar: close, progress bar, timer ----
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (_currentIndex > 0 || _answers.isNotEmpty) {
                        final leave = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Leave test?'),
                            content: const Text(
                              'Your progress will be lost.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                child: const Text('Stay'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(ctx).pop(true),
                                child: const Text('Leave'),
                              ),
                            ],
                          ),
                        );
                        if (leave == true && context.mounted) {
                          _timer?.cancel();
                          context.pop();
                        }
                      } else {
                        _timer?.cancel();
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
                        value: (_currentIndex + 1) / _questions.length,
                        minHeight: 6,
                        backgroundColor: context.progressBgColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Timer chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: timerWarning
                          ? AppColors.error.withValues(alpha: 0.1)
                          : context.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: timerWarning
                              ? AppColors.error
                              : AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: timerWarning
                                ? AppColors.error
                                : AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ---- Question counter ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  Text(
                    '${_answers.length} answered',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ---- Scrollable content: passage + question + options ----
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Passage card
                  FrenchCard(
                    margin: EdgeInsets.zero,
                    color: context.creamColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _passageIcon(fq.passage.type),
                              size: 16,
                              color: context.navyAdaptive,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fq.passage.title,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.navyAdaptive,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          fq.passage.content,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: context.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        if (fq.passage.source != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            fq.passage.source!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: context.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question text
                  Text(
                    fq.question.question,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Options
                  ...fq.question.options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedIndex == i;
                    final isCorrect = i == fq.question.correctIndex;

                    // Determine colours
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
                      bgColor =
                          context.navyAdaptive.withValues(alpha: 0.05);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: _answered
                              ? null
                              : () => setState(() => _selectedIndex = i),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: borderColor,
                                width:
                                    isSelected || (_answered && isCorrect)
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
                                    color: isSelected ||
                                            (_answered && isCorrect)
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
                          delay: (80 + i * 50).ms,
                          duration: 300.ms,
                        )
                        .slideX(begin: 0.05);
                  }),

                  // Explanation (shown after checking)
                  if (_answered) ...[
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
                              fq.question.explanation,
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
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ---- Bottom button: Check / Continue ----
            Container(
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
                  onPressed: _selectedIndex == null
                      ? null
                      : () {
                          if (!_answered) {
                            // Check the answer
                            final fq = _questions[_currentIndex];
                            _answers[fq.question.id] = _selectedIndex!;
                            if (_selectedIndex ==
                                fq.question.correctIndex) {
                              _score++;
                            }
                            setState(() => _answered = true);
                          } else {
                            // Continue to next question or finish
                            if (_currentIndex < _questions.length - 1) {
                              setState(() {
                                _currentIndex++;
                                _selectedIndex = null;
                                _answered = false;
                              });
                            } else {
                              _finishTest();
                            }
                          }
                        },
                  child: Text(_answered ? 'Continue' : 'Check'),
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

// -----------------------------------------------------------------------------
// Helper class
// -----------------------------------------------------------------------------

class _FlatQuestion {
  final TefPassage passage;
  final TefQuestion question;
  const _FlatQuestion({required this.passage, required this.question});
}

// -----------------------------------------------------------------------------
// Results view
// -----------------------------------------------------------------------------

class _TefResultsView extends StatelessWidget {
  final TefTestResult result;
  final TefTest test;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _TefResultsView({
    required this.result,
    required this.test,
    required this.onRetry,
    required this.onDone,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final pct = result.percentage;
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
                  // Result icon
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

                // Title
                Text(
                  passed ? 'Excellent!' : 'Keep Practicing!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),

                // Score text
                Text(
                  'You scored ${result.score} out of ${result.totalQuestions} ($pct%)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 20),

                // Stats row: NCLC level, time taken, XP earned
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      label: result.nclcLevel,
                      icon: Icons.grade_rounded,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: _formatDuration(result.timeTakenSeconds),
                      icon: Icons.timer_outlined,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: '+$pct XP',
                      icon: Icons.star_rounded,
                      color: AppColors.gold,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),

                // Action buttons
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

// -----------------------------------------------------------------------------
// Stat chip widget
// -----------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
