import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vocabulary_word.dart';
import '../../models/progress.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/spaced_repetition.dart';
import '../../widgets/french_card.dart';

/// A multiple-choice vocabulary quiz screen.
///
/// Supply either a [category] to quiz all words in a category,
/// or [wordIds] to quiz a specific set of words (e.g. from a flashcard session).
class VocabQuizScreen extends ConsumerStatefulWidget {
  final String? category;
  final List<String>? wordIds;

  const VocabQuizScreen({super.key, this.category, this.wordIds})
      : assert(category != null || wordIds != null,
            'Provide either category or wordIds');

  @override
  ConsumerState<VocabQuizScreen> createState() => _VocabQuizScreenState();
}

class _VocabQuizScreenState extends ConsumerState<VocabQuizScreen> {
  final _random = Random();

  // Quiz state
  List<_QuizQuestion> _questions = [];
  bool _loaded = false;
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _completed = false;
  int _score = 0;

  /// Tracks which words were answered wrong for review display.
  final List<_WrongAnswer> _wrongAnswers = [];

  @override
  Widget build(BuildContext context) {
    final vocabAsync = ref.watch(vocabularyProvider);

    return vocabAsync.when(
      data: (allWords) {
        if (!_loaded) {
          _buildQuiz(allWords);
          _loaded = true;
        }

        if (_questions.isEmpty) {
          return _buildEmptyState(context);
        }

        if (_completed) {
          return _buildResults(context);
        }

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
                  'Failed to load vocabulary',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(vocabularyProvider),
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
  // Quiz Building
  // ---------------------------------------------------------------------------

  void _buildQuiz(List<VocabularyWord> allWords) {
    List<VocabularyWord> quizWords;

    if (widget.wordIds != null && widget.wordIds!.isNotEmpty) {
      // Quiz specific words by their card IDs (e.g. 'vocab_bonjour').
      final idSet = widget.wordIds!.toSet();
      quizWords = allWords.where((w) {
        final cardId = 'vocab_${w.french}';
        return idSet.contains(cardId) || idSet.contains(w.id);
      }).toList();
    } else if (widget.category != null) {
      quizWords = allWords
          .where((w) => w.category == widget.category)
          .toList();
    } else {
      quizWords = [];
    }

    if (quizWords.length < 4) {
      // Not enough words for a meaningful quiz with 4 options.
      _questions = [];
      return;
    }

    // Build a pool of distractor words from the same category / level.
    final distractorPool = <VocabularyWord>[];
    if (widget.category != null) {
      distractorPool.addAll(
        allWords.where((w) => w.category == widget.category),
      );
    } else {
      // For word-ID based quizzes, use all words that share a level or
      // category with any of the quiz words.
      final levels = quizWords.map((w) => w.level).toSet();
      final categories = quizWords.map((w) => w.category).toSet();
      distractorPool.addAll(
        allWords.where(
            (w) => levels.contains(w.level) || categories.contains(w.category)),
      );
    }

    // Ensure the pool has enough variety; if not, fall back to all words.
    if (distractorPool.length < 4) {
      distractorPool
        ..clear()
        ..addAll(allWords);
    }

    // Shuffle quiz words.
    quizWords.shuffle(_random);

    // Generate a question for each word.
    _questions = quizWords.map((word) {
      // Randomly choose mode: 0 = French -> English, 1 = English -> French.
      final mode = _random.nextInt(2);
      return _generateQuestion(word, mode, distractorPool);
    }).toList();
  }

  _QuizQuestion _generateQuestion(
    VocabularyWord word,
    int mode,
    List<VocabularyWord> pool,
  ) {
    // Pick 3 unique distractor words different from the correct word.
    final distractors = <VocabularyWord>[];
    final available = pool.where((w) => w.french != word.french).toList()
      ..shuffle(_random);
    for (final d in available) {
      if (distractors.length >= 3) break;
      // Avoid duplicate translations.
      final isDuplicate = mode == 0
          ? distractors.any((x) => x.english == d.english) ||
              d.english == word.english
          : distractors.any((x) => x.french == d.french) ||
              d.french == word.french;
      if (!isDuplicate) {
        distractors.add(d);
      }
    }

    // Build options list: correct + 3 distractors.
    final options = <String>[];
    if (mode == 0) {
      // French -> English: options are English translations.
      options.add(word.english);
      for (final d in distractors) {
        options.add(d.english);
      }
    } else {
      // English -> French: options are French words.
      options.add(word.french);
      for (final d in distractors) {
        options.add(d.french);
      }
    }

    // Shuffle and find correct index.
    final shuffled = List<String>.from(options)..shuffle(_random);
    final correctIndex =
        shuffled.indexWhere((o) => o == (mode == 0 ? word.english : word.french));

    return _QuizQuestion(
      word: word,
      mode: mode,
      prompt: mode == 0 ? word.french : word.english,
      options: shuffled,
      correctIndex: correctIndex,
    );
  }

  // ---------------------------------------------------------------------------
  // Question View
  // ---------------------------------------------------------------------------

  Widget _buildQuestionView(BuildContext context) {
    final q = _questions[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // -- Top bar: close + progress bar + counter --
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _confirmExit(context),
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
                            AppColors.gold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.navyAdaptive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${_questions.length}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.navyAdaptive,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // -- Question counter --
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
                    '$_score correct',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // -- Scrollable content: prompt + options --
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Mode label
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          q.mode == 0
                              ? Icons.translate_rounded
                              : Icons.g_translate_rounded,
                          size: 16,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          q.mode == 0
                              ? 'Translate to English'
                              : 'Translate to French',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Prompt word
                  FrenchCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    child: Column(
                      children: [
                        Text(
                          q.prompt,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (q.mode == 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            q.word.phonetic,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03),
                  const SizedBox(height: 24),

                  // Options
                  ...q.options.asMap().entries.map((entry) {
                    final i = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedIndex == i;
                    final isCorrect = i == q.correctIndex;

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

                  // Feedback after answering
                  if (_answered) ...[
                    const SizedBox(height: 8),
                    FrenchCard(
                      margin: EdgeInsets.zero,
                      color: context.creamColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _selectedIndex == q.correctIndex
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            color: _selectedIndex == q.correctIndex
                                ? AppColors.success
                                : context.navyAdaptive,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedIndex == q.correctIndex
                                      ? 'Correct!'
                                      : 'The correct answer is:',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedIndex == q.correctIndex
                                        ? AppColors.success
                                        : context.textPrimary,
                                  ),
                                ),
                                if (_selectedIndex != q.correctIndex) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${q.word.french} = ${q.word.english}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  q.word.exampleFr,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: context.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  q.word.exampleEn,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: context.textLight,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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

            // -- Bottom button: Check / Continue --
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
                            _checkAnswer();
                          } else {
                            _nextQuestion();
                          }
                        },
                  child: Text(_answered ? 'Continue' : 'Check'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Check / Next Logic
  // ---------------------------------------------------------------------------

  void _checkAnswer() {
    final q = _questions[_currentIndex];
    final isCorrect = _selectedIndex == q.correctIndex;

    if (isCorrect) {
      _score++;
    } else {
      _wrongAnswers.add(_WrongAnswer(
        word: q.word,
        selectedOption: q.options[_selectedIndex!],
        correctOption: q.options[q.correctIndex],
      ));
    }

    // Spaced repetition integration.
    final cardId = 'vocab_${q.word.french}';
    final progress = ref.read(progressProvider);
    final existingCard =
        progress.flashcards[cardId] ?? CardProgress.initial(cardId);
    final quality = isCorrect ? 4 : 0; // Good vs Again
    final updatedCard = SpacedRepetition.review(existingCard, quality);
    ref.read(progressProvider.notifier).updateCardProgress(updatedCard);

    setState(() => _answered = true);
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      // Quiz complete.
      ref.read(progressProvider.notifier).updateStreak();
      setState(() => _completed = true);
    }
  }

  // ---------------------------------------------------------------------------
  // Results Screen
  // ---------------------------------------------------------------------------

  Widget _buildResults(BuildContext context) {
    final total = _questions.length;
    final pct = total > 0 ? ((_score / total) * 100).round() : 0;
    final passed = pct >= 70;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 28),

                // Title
                Text(
                  passed ? 'Great Job!' : 'Keep Practicing!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),

                // Score text
                Text(
                  'You scored $_score out of $total ($pct%)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      label: '$_score',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: '${_wrongAnswers.length}',
                      icon: Icons.cancel_rounded,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: '$pct%',
                      icon: Icons.percent_rounded,
                      color: AppColors.gold,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                // Wrong answers review section
                if (_wrongAnswers.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.refresh_rounded,
                                size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(
                              'Words to Review',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ..._wrongAnswers.map((wa) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: context.textPrimary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: wa.word.french,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text: ' = ${wa.word.english}',
                                            style: TextStyle(
                                              color: context.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetQuiz,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Done'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void _resetQuiz() {
    setState(() {
      _loaded = false;
      _questions = [];
      _currentIndex = 0;
      _selectedIndex = null;
      _answered = false;
      _completed = false;
      _score = 0;
      _wrongAnswers.clear();
    });
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_rounded, size: 64, color: context.textLight),
              const SizedBox(height: 16),
              Text(
                'Not enough words',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Need at least 4 words to generate a quiz.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.textLight,
                ),
                textAlign: TextAlign.center,
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

  // ---------------------------------------------------------------------------
  // Confirm exit
  // ---------------------------------------------------------------------------

  Future<void> _confirmExit(BuildContext context) async {
    if (_currentIndex == 0 && !_answered) {
      context.pop();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave quiz?'),
        content: const Text('Your quiz progress will be lost.'),
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
  }
}

// =============================================================================
// Data classes
// =============================================================================

class _QuizQuestion {
  final VocabularyWord word;
  final int mode; // 0 = French->English, 1 = English->French
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.word,
    required this.mode,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

class _WrongAnswer {
  final VocabularyWord word;
  final String selectedOption;
  final String correctOption;

  const _WrongAnswer({
    required this.word,
    required this.selectedOption,
    required this.correctOption,
  });
}

// =============================================================================
// Stat chip widget (matches TEF results pattern)
// =============================================================================

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
