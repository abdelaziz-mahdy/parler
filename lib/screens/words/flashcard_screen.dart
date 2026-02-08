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
import '../../widgets/speaker_button.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String category;
  const FlashcardScreen({super.key, required this.category});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  static const int _maxSessionSize = 15;

  List<VocabularyWord> _sessionWords = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _sessionComplete = false;

  /// Tracks the quality rating given for each word in this session.
  /// Key is the card id, value is the quality rating (0, 3, 4, or 5).
  final Map<String, int> _sessionRatings = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionWords.isEmpty) {
      _buildSession();
    }
  }

  bool get _isReviewMode => widget.category == 'review';

  /// Builds the study session by selecting due cards first, then new cards,
  /// capped at [_maxSessionSize].
  void _buildSession() {
    final List<VocabularyWord> allWords;
    if (_isReviewMode) {
      // Review mode: load all vocabulary and filter to due cards only.
      final vocabAsync = ref.read(vocabularyProvider);
      allWords = vocabAsync.when(
        data: (words) => words,
        loading: () => <VocabularyWord>[],
        error: (_, _) => <VocabularyWord>[],
      );
    } else {
      allWords = ref.read(vocabularyByCategoryProvider(widget.category));
    }
    if (allWords.isEmpty) return;

    final progress = ref.read(progressProvider);

    // Build CardProgress entries for every word so we can prioritize.
    final cardEntries = <_WordCard>[];
    for (final word in allWords) {
      final cardId = 'vocab_${word.french}';
      final card = progress.flashcards[cardId] ?? CardProgress.initial(cardId);
      cardEntries.add(_WordCard(word: word, card: card));
    }

    // Separate into due and not-yet-due cards.
    final due = cardEntries
        .where((e) => SpacedRepetition.isDue(e.card))
        .toList();
    final notDue = cardEntries
        .where((e) => !SpacedRepetition.isDue(e.card))
        .toList();

    // Prioritize due cards (harder ones first).
    final prioritizedDue = SpacedRepetition.prioritize(
      due.map((e) => e.card).toList(),
    );
    final orderedDue = prioritizedDue.map((card) {
      return due.firstWhere((e) => e.card.cardId == card.cardId);
    }).toList();

    // New cards (never reviewed) come next -- skip in review mode.
    final newCards = _isReviewMode
        ? <_WordCard>[]
        : notDue.where((e) => e.card.repetitions == 0).toList();

    final combined = [...orderedDue, ...newCards];
    final selected = combined.take(_maxSessionSize).toList();

    // Fallback: if nothing is due and no new cards, just take the first batch.
    if (selected.isEmpty) {
      final fallback = allWords.take(_maxSessionSize).toList();
      setState(() {
        _sessionWords = fallback;
      });
      return;
    }

    setState(() {
      _sessionWords = selected.map((e) => e.word).toList();
    });
  }

  void _flipCard() {
    if (_isFlipped) return; // Already flipped, wait for rating.
    setState(() {
      _isFlipped = true;
    });
  }

  /// Compute the next review interval (in days) for the current card at a
  /// given quality rating, using the SM-2 algorithm.
  String _intervalLabel(int quality) {
    final word = _sessionWords[_currentIndex];
    final cardId = 'vocab_${word.french}';
    final progress = ref.read(progressProvider);
    final card = progress.flashcards[cardId] ?? CardProgress.initial(cardId);
    final result = SpacedRepetition.review(card, quality);
    final days = result.interval;
    if (days < 1) return '<1m';
    if (days == 1) return '1d';
    if (days < 7) return '${days}d';
    if (days < 30) return '${(days / 7).round()}w';
    return '${(days / 30).round()}mo';
  }

  void _rateCard(int quality) {
    final word = _sessionWords[_currentIndex];
    final cardId = 'vocab_${word.french}';
    final progress = ref.read(progressProvider);
    final existingCard =
        progress.flashcards[cardId] ?? CardProgress.initial(cardId);

    final updatedCard = SpacedRepetition.review(existingCard, quality);
    ref.read(progressProvider.notifier).updateCardProgress(updatedCard);

    // Record session rating.
    _sessionRatings[cardId] = quality;

    // Advance to next card or finish.
    if (_currentIndex < _sessionWords.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      // Update streak on session completion.
      ref.read(progressProvider.notifier).updateStreak();
      setState(() {
        _sessionComplete = true;
      });
    }
  }

  void _restartSession() {
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _sessionComplete = false;
      _sessionRatings.clear();
      _sessionWords = [];
    });
    _buildSession();
  }

  @override
  Widget build(BuildContext context) {
    // In review mode, we don't filter by category -- session words are built from all due cards.
    final List<VocabularyWord> allWords;
    if (_isReviewMode) {
      final vocabAsync = ref.watch(vocabularyProvider);
      allWords = vocabAsync.when(
        data: (words) => words,
        loading: () => <VocabularyWord>[],
        error: (_, _) => <VocabularyWord>[],
      );
    } else {
      allWords = ref.watch(vocabularyByCategoryProvider(widget.category));
    }

    if (_isReviewMode && _sessionWords.isEmpty && !_sessionComplete) {
      return _buildEmptyState(context);
    }
    if (!_isReviewMode && allWords.isEmpty) {
      return _buildEmptyState(context);
    }

    if (_sessionComplete) {
      return _buildSummary(context);
    }

    if (_sessionWords.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = _sessionWords[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: GestureDetector(
                onTap: _isFlipped ? null : _flipCard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _isFlipped
                        ? _buildCardBack(context, word)
                        : _buildCardFront(context, word),
                  ),
                ),
              ),
            ),
            if (_isFlipped) _buildRatingButtons(context),
            if (!_isFlipped)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'Tap the card to reveal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.textLight,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Bar
  // ---------------------------------------------------------------------------

  Widget _buildTopBar(BuildContext context) {
    final total = _sessionWords.length;
    final current = _currentIndex + 1;
    final progressValue = total > 0 ? current / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _confirmExit(context),
            icon: const Icon(Icons.close_rounded),
            color: context.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isReviewMode
                      ? 'Review Due Cards'
                      : _categoryDisplayName(widget.category),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: context.progressBgColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.gold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.navyAdaptive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$current/$total',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.navyAdaptive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Front (French word)
  // ---------------------------------------------------------------------------

  Widget _buildCardFront(BuildContext context, VocabularyWord word) {
    return FrenchCard(
      key: ValueKey('front_${word.french}'),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.level,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              word.french,
              style: GoogleFonts.playfairDisplay(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              word.phonetic,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SpeakerButton(text: word.french, size: 28, color: AppColors.gold),
            const SizedBox(height: 32),
            Icon(
              Icons.touch_app_rounded,
              size: 28,
              color: context.textLight.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03);
  }

  // ---------------------------------------------------------------------------
  // Card Back (Translation + details)
  // ---------------------------------------------------------------------------

  Widget _buildCardBack(BuildContext context, VocabularyWord word) {
    return FrenchCard(
      key: ValueKey('back_${word.french}'),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // French word (smaller on back)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      word.french,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: context.navyAdaptive,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SpeakerButton(
                    text: word.french,
                    size: 22,
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                word.phonetic,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: context.textLight,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: context.dividerColor, height: 1),
              ),

              // English translation
              Text(
                word.english,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Part of speech + Gender tags
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTag(context, word.partOfSpeech, context.navyAdaptive),
                  if (word.gender != null) ...[
                    const SizedBox(width: 8),
                    _buildTag(
                      context,
                      word.gender == 'm' ? 'masculine' : 'feminine',
                      word.gender == 'm' ? AppColors.info : AppColors.red,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Example sentences
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.creamColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Example',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.textLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      word.exampleFr,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: context.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      word.exampleEn,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03);
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rating Buttons
  // ---------------------------------------------------------------------------

  Widget _buildRatingButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How well did you remember?',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RatingButton(
                label: 'Easy',
                subtitle: _intervalLabel(5),
                color: AppColors.info,
                onTap: () => _rateCard(5),
              ),
              const SizedBox(width: 8),
              _RatingButton(
                label: 'Good',
                subtitle: _intervalLabel(4),
                color: AppColors.success,
                onTap: () => _rateCard(4),
              ),
              const SizedBox(width: 8),
              _RatingButton(
                label: 'Hard',
                subtitle: _intervalLabel(3),
                color: AppColors.warning,
                onTap: () => _rateCard(3),
              ),
              const SizedBox(width: 8),
              _RatingButton(
                label: 'Again',
                subtitle: _intervalLabel(0),
                color: AppColors.red,
                onTap: () => _rateCard(0),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1);
  }

  // ---------------------------------------------------------------------------
  // Session Summary
  // ---------------------------------------------------------------------------

  Widget _buildSummary(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final total = _sessionWords.length;

    int againCount = 0;
    int hardCount = 0;
    int goodCount = 0;
    int easyCount = 0;

    for (final entry in _sessionRatings.entries) {
      switch (entry.value) {
        case 0:
          againCount++;
          break;
        case 3:
          hardCount++;
          break;
        case 4:
          goodCount++;
          break;
        case 5:
          easyCount++;
          break;
      }
    }

    final knewWell = goodCount + easyCount;
    final needsReview = againCount + hardCount;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: AppColors.success,
                    size: 48,
                  ),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: 28),
                Text(
                  'Session Complete!',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  _isReviewMode
                      ? 'Spaced Repetition Review'
                      : _categoryDisplayName(widget.category),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 28),

                // Stats grid
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.dividerColor),
                  ),
                  child: Column(
                    children: [
                      _SummaryStatRow(
                        icon: Icons.style_rounded,
                        label: 'Cards studied',
                        value: '$total',
                        color: context.navyAdaptive,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: context.dividerColor, height: 1),
                      ),
                      _SummaryStatRow(
                        icon: Icons.check_circle_rounded,
                        label: 'Knew well',
                        value: '$knewWell',
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 12),
                      _SummaryStatRow(
                        icon: Icons.refresh_rounded,
                        label: 'Needs review',
                        value: '$needsReview',
                        color: AppColors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: context.dividerColor, height: 1),
                      ),
                      _SummaryStatRow(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Current streak',
                        value:
                            '${progress.currentStreak} day${progress.currentStreak == 1 ? '' : 's'}',
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 16),

                // Rating breakdown
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
                      Text(
                        'Breakdown',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _BreakdownBar(
                        total: total,
                        againCount: againCount,
                        hardCount: hardCount,
                        goodCount: goodCount,
                        easyCount: easyCount,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BreakdownLegend(
                            color: AppColors.info,
                            label: 'Easy',
                            count: easyCount,
                          ),
                          _BreakdownLegend(
                            color: AppColors.success,
                            label: 'Good',
                            count: goodCount,
                          ),
                          _BreakdownLegend(
                            color: AppColors.warning,
                            label: 'Hard',
                            count: hardCount,
                          ),
                          _BreakdownLegend(
                            color: AppColors.red,
                            label: 'Again',
                            count: againCount,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 32),

                // Quiz button
                if (_sessionWords.length >= 4)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final wordIds = _sessionWords
                            .map((w) => 'vocab_${w.french}')
                            .toList();
                        context.push(
                          '/words/quiz/${widget.category}',
                          extra: wordIds,
                        );
                      },
                      icon: const Icon(Icons.quiz_rounded),
                      label: const Text('Quiz These Words'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 520.ms),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _restartSession,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Study Again'),
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
                ).animate().fadeIn(delay: 550.ms),
              ],
            ),
          ),
        ),
      ),
    );
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
              Icon(Icons.style_rounded, size: 64, color: context.textLight),
              const SizedBox(height: 16),
              Text(
                _isReviewMode ? 'Nothing to review' : 'No words available',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isReviewMode
                    ? 'No cards are due for review right now.'
                    : 'This category has no vocabulary words yet.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.textLight,
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _confirmExit(BuildContext context) async {
    if (_currentIndex == 0 && !_isFlipped) {
      context.pop();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text(
          'Your progress for reviewed cards has been saved, but you '
          'have not finished all cards in this session.',
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
  }
}

// =============================================================================
// Private helper class for building the session.
// =============================================================================

class _WordCard {
  final VocabularyWord word;
  final CardProgress card;
  const _WordCard({required this.word, required this.card});
}

// =============================================================================
// Rating Button Widget
// =============================================================================

class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Summary Stat Row
// =============================================================================

class _SummaryStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: context.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Breakdown Bar (stacked horizontal bar)
// =============================================================================

class _BreakdownBar extends StatelessWidget {
  final int total;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;

  const _BreakdownBar({
    required this.total,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            if (easyCount > 0)
              Flexible(
                flex: easyCount,
                child: Container(color: AppColors.info),
              ),
            if (goodCount > 0)
              Flexible(
                flex: goodCount,
                child: Container(color: AppColors.success),
              ),
            if (hardCount > 0)
              Flexible(
                flex: hardCount,
                child: Container(color: AppColors.warning),
              ),
            if (againCount > 0)
              Flexible(
                flex: againCount,
                child: Container(color: AppColors.red),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Breakdown Legend Item
// =============================================================================

class _BreakdownLegend extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _BreakdownLegend({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $count',
          style: GoogleFonts.inter(fontSize: 11, color: context.textSecondary),
        ),
      ],
    );
  }
}

// =============================================================================
// Helper: Convert snake_case category to Title Case display name.
// =============================================================================

String _categoryDisplayName(String cat) {
  return cat
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
