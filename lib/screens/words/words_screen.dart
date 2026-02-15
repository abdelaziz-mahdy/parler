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
import '../../core/constants/responsive.dart';
import '../../widgets/french_card.dart';
import '../../widgets/error_view.dart';

/// Data class holding metadata for each vocabulary category.
class _CategoryInfo {
  final String key;
  final String label;
  final IconData icon;

  const _CategoryInfo({
    required this.key,
    required this.label,
    required this.icon,
  });
}

const _categories = <_CategoryInfo>[
  _CategoryInfo(
    key: 'greetings',
    label: 'Greetings',
    icon: Icons.waving_hand_rounded,
  ),
  _CategoryInfo(
    key: 'family',
    label: 'Family',
    icon: Icons.family_restroom_rounded,
  ),
  _CategoryInfo(key: 'food', label: 'Food', icon: Icons.restaurant_rounded),
  _CategoryInfo(key: 'home', label: 'Home', icon: Icons.home_rounded),
  _CategoryInfo(
    key: 'daily_routine',
    label: 'Daily Routine',
    icon: Icons.schedule_rounded,
  ),
  _CategoryInfo(key: 'work', label: 'Work', icon: Icons.work_rounded),
  _CategoryInfo(key: 'emotions', label: 'Emotions', icon: Icons.mood_rounded),
  _CategoryInfo(key: 'colors', label: 'Colors', icon: Icons.palette_rounded),
  _CategoryInfo(key: 'time', label: 'Time', icon: Icons.access_time_rounded),
  _CategoryInfo(key: 'weather', label: 'Weather', icon: Icons.cloud_rounded),
  _CategoryInfo(
    key: 'shopping',
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
  ),
  _CategoryInfo(key: 'city', label: 'City', icon: Icons.location_city_rounded),
  _CategoryInfo(key: 'travel', label: 'Travel', icon: Icons.flight_rounded),
  _CategoryInfo(
    key: 'health',
    label: 'Health',
    icon: Icons.health_and_safety_rounded,
  ),
  _CategoryInfo(
    key: 'education',
    label: 'Education',
    icon: Icons.school_rounded,
  ),
  _CategoryInfo(key: 'nature', label: 'Nature', icon: Icons.park_rounded),
  _CategoryInfo(
    key: 'clothing',
    label: 'Clothing',
    icon: Icons.checkroom_rounded,
  ),
  _CategoryInfo(
    key: 'body',
    label: 'Body',
    icon: Icons.accessibility_new_rounded,
  ),
  _CategoryInfo(key: 'numbers_misc', label: 'Numbers', icon: Icons.tag_rounded),
  _CategoryInfo(
    key: 'hobbies',
    label: 'Hobbies',
    icon: Icons.sports_tennis_rounded,
  ),
  _CategoryInfo(
    key: 'technology',
    label: 'Technology',
    icon: Icons.devices_rounded,
  ),
  _CategoryInfo(
    key: 'transportation',
    label: 'Transport',
    icon: Icons.directions_bus_rounded,
  ),
  _CategoryInfo(
    key: 'finance',
    label: 'Finance',
    icon: Icons.account_balance_rounded,
  ),
  _CategoryInfo(
    key: 'media',
    label: 'Media',
    icon: Icons.newspaper_rounded,
  ),
  _CategoryInfo(
    key: 'environment',
    label: 'Environment',
    icon: Icons.eco_rounded,
  ),
  _CategoryInfo(
    key: 'society',
    label: 'Society',
    icon: Icons.groups_rounded,
  ),
];

class WordsScreen extends ConsumerWidget {
  const WordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabularyProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Words',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: vocabAsync.when(
        data: (allWords) =>
            _WordsCategoryBrowser(allWords: allWords, progress: progress),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorView(onRetry: () => ref.invalidate(vocabularyProvider)),
      ),
    );
  }
}

class _WordsCategoryBrowser extends StatelessWidget {
  final List<VocabularyWord> allWords;
  final UserProgress progress;

  const _WordsCategoryBrowser({required this.allWords, required this.progress});

  @override
  Widget build(BuildContext context) {
    // Pre-compute word counts per category for efficient lookup.
    final wordsPerCategory = <String, List<VocabularyWord>>{};
    for (final word in allWords) {
      wordsPerCategory.putIfAbsent(word.category, () => []).add(word);
    }

    // Compute review-due count across all vocabulary flashcards.
    final today = DateTime.now().toIso8601String().split('T').first;
    final dueCards = progress.flashcards.entries.where((entry) {
      // Only count vocabulary cards (prefixed with 'vocab_').
      if (!entry.key.startsWith('vocab_')) return false;
      return entry.value.nextReviewDate.compareTo(today) <= 0;
    }).toList();
    final dueCount = dueCards.length;

    // Filter categories that actually have words in the data.
    final activeCategories = _categories
        .where((c) => wordsPerCategory.containsKey(c.key))
        .toList();

    final hPad = context.horizontalPadding;
    final columns = context.gridColumns;

    return ContentConstraint(
      child: CustomScrollView(
        slivers: [
          // -- Stats bar --
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 8),
              child: _VocabStatsBar(
                totalWords: allWords.length,
                totalCategories: activeCategories.length,
                learnedCount: progress.flashcards.entries
                    .where(
                      (e) =>
                          e.key.startsWith('vocab_') && e.value.repetitions > 0,
                    )
                    .length,
              ),
            ),
          ),

          // -- Review Due card (conditionally shown) --
          if (dueCount > 0)
            SliverToBoxAdapter(
              child: _ReviewDueCard(
                dueCount: dueCount,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08),
            ),

          // -- Section label --
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
              child: Text(
                'CATEGORIES',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: context.textLight,
                ),
              ),
            ),
          ),

          // -- Category grid --
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad - 4),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: context.isCompact ? 0.92 : 1.2,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final cat = activeCategories[index];
                final words = wordsPerCategory[cat.key] ?? [];
                return _CategoryCard(
                  info: cat,
                  words: words,
                  progress: progress,
                  index: index,
                );
              }, childCount: activeCategories.length),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

/// A compact stats bar showing total words, categories, and learned count.
class _VocabStatsBar extends StatelessWidget {
  final int totalWords;
  final int totalCategories;
  final int learnedCount;

  const _VocabStatsBar({
    required this.totalWords,
    required this.totalCategories,
    required this.learnedCount,
  });

  @override
  Widget build(BuildContext context) {
    return FrenchCard(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.translate_rounded,
            value: '$totalWords',
            label: 'Words',
            color: context.navyAdaptive,
          ),
          _statDivider(context),
          _StatItem(
            icon: Icons.category_rounded,
            value: '$totalCategories',
            label: 'Topics',
            color: AppColors.gold,
          ),
          _statDivider(context),
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            value: '$learnedCount',
            label: 'Learned',
            color: AppColors.success,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06);
  }

  Widget _statDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: context.dividerColor,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: context.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card shown when there are flashcards due for spaced repetition review.
class _ReviewDueCard extends StatelessWidget {
  final int dueCount;

  const _ReviewDueCard({required this.dueCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/words/review'),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.red.withValues(alpha: 0.12),
                  AppColors.gold.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.replay_rounded,
                        size: 22,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review Due',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$dueCount word${dueCount == 1 ? '' : 's'} ready for review',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Review',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single category card in the grid showing icon, name, word count,
/// and a compact level breakdown.
class _CategoryCard extends StatelessWidget {
  final _CategoryInfo info;
  final List<VocabularyWord> words;
  final UserProgress progress;
  final int index;

  const _CategoryCard({
    required this.info,
    required this.words,
    required this.progress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Level breakdown.
    final levelCounts = <String, int>{};
    for (final w in words) {
      levelCounts[w.level] = (levelCounts[w.level] ?? 0) + 1;
    }

    // Determine how many words in this category the user has studied.
    final studiedCount = words.where((w) {
      final card = progress.flashcards['vocab_${w.french}'];
      return card != null && card.repetitions > 0;
    }).length;
    final isComplete = studiedCount == words.length && words.isNotEmpty;
    final hasStarted = studiedCount > 0;

    final accentColor = isComplete ? AppColors.success : context.navyAdaptive;

    return FrenchCard(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(16),
          onTap: () => context.push('/words/${info.key}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + quiz / completion indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(info.icon, size: 22, color: accentColor),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasStarted && words.length >= 4)
                        GestureDetector(
                          onTap: () =>
                              context.push('/words/quiz/${info.key}'),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.quiz_rounded,
                                size: 16,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),
                      if (isComplete) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category name
              Text(
                info.label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Word count
              Text(
                '${words.length} word${words.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
              const Spacer(),

              // Progress bar (if started)
              if (hasStarted) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: words.isNotEmpty ? studiedCount / words.length : 0,
                    minHeight: 4,
                    backgroundColor: context.progressBgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? AppColors.success : AppColors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Level breakdown chips
              _LevelBreakdown(levelCounts: levelCounts),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (60 * (index < 10 ? index : 10)).ms, duration: 400.ms)
        .slideY(begin: 0.08);
  }
}

/// Compact row of colored level badges (A1, A2, B1, B2).
class _LevelBreakdown extends StatelessWidget {
  final Map<String, int> levelCounts;

  const _LevelBreakdown({required this.levelCounts});

  @override
  Widget build(BuildContext context) {
    const levelOrder = ['A1', 'A2', 'B1', 'B2'];

    final chips = <Widget>[];
    for (final level in levelOrder) {
      final count = levelCounts[level];
      if (count != null && count > 0) {
        chips.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _levelColor(level).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$level:$count',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _levelColor(level),
              ),
            ),
          ),
        );
      }
    }

    return Wrap(spacing: 4, runSpacing: 4, children: chips);
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'A1':
        return AppColors.success;
      case 'A2':
        return AppColors.info;
      case 'B1':
        return AppColors.gold;
      case 'B2':
        return AppColors.red;
      default:
        return AppColors.textLight;
    }
  }
}
