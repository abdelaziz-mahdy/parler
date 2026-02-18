import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/icon_map.dart';
import '../../core/constants/responsive.dart';
import '../../models/chapter.dart';
import '../../models/progress.dart';
import '../../models/vocabulary_word.dart';
import '../../providers/data_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/french_card.dart';

enum _LearnSection { chapters, wordBank, tef }

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: chaptersAsync.when(
          data: (chapters) => _LearnContent(
            chapters: chapters,
            progress: progress,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            onRetry: () => ref.invalidate(chaptersProvider),
          ),
        ),
      ),
    );
  }
}

class _LearnContent extends ConsumerStatefulWidget {
  final List<Chapter> chapters;
  final UserProgress progress;

  const _LearnContent({
    required this.chapters,
    required this.progress,
  });

  @override
  ConsumerState<_LearnContent> createState() => _LearnContentState();
}

class _LearnContentState extends ConsumerState<_LearnContent> {
  _LearnSection _selectedSection = _LearnSection.chapters;

  @override
  Widget build(BuildContext context) {
    final hPad = context.horizontalPadding;

    // Find first incomplete chapter for "Recommended" badge
    int? recommendedId;
    for (final chapter in widget.chapters) {
      final cp = widget.progress.chapters[chapter.id];
      if (cp == null || cp.completionPercent < 100) {
        recommendedId = chapter.id;
        break;
      }
    }

    return ContentConstraint(
      child: CustomScrollView(
        slivers: [
          // -- Header --
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your French learning journey',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(themeModeProvider.notifier).toggle(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? AppColors.darkCard
                            : AppColors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        context.isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: 20,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -- Section Filter Chips --
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Chapters',
                    icon: Icons.menu_book_rounded,
                    isSelected: _selectedSection == _LearnSection.chapters,
                    onTap: () => setState(() => _selectedSection = _LearnSection.chapters),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Word Bank',
                    icon: Icons.translate_rounded,
                    isSelected: _selectedSection == _LearnSection.wordBank,
                    onTap: () => setState(() => _selectedSection = _LearnSection.wordBank),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'TEF Prep',
                    icon: Icons.school_rounded,
                    isSelected: _selectedSection == _LearnSection.tef,
                    onTap: () => setState(() => _selectedSection = _LearnSection.tef),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          // -- Filtered content --
          if (_selectedSection == _LearnSection.chapters) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                child: _SectionHeader(
                  title: 'Chapters',
                  icon: Icons.menu_book_rounded,
                  count: widget.chapters.length,
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = widget.chapters[index];
                  final cp = widget.progress.chapters[chapter.id];
                  final isCompleted =
                      cp != null && cp.completionPercent >= 100;
                  final isRecommended = chapter.id == recommendedId;

                  return _ChapterTile(
                    chapter: chapter,
                    chapterProgress: cp,
                    isCompleted: isCompleted,
                    isRecommended: isRecommended,
                  );
                },
                childCount: widget.chapters.length,
              ),
            ),
          ],

          if (_selectedSection == _LearnSection.wordBank) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                child: _SectionHeader(
                  title: 'Word Bank',
                  icon: Icons.translate_rounded,
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),
            _WordBankGrid(),
          ],

          if (_selectedSection == _LearnSection.tef) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                child: _SectionHeader(
                  title: 'TEF Prep',
                  icon: Icons.school_rounded,
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),
            _TefTestList(),
          ],

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter Chip
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.red
              : context.isDark
                  ? AppColors.darkCard
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.red
                : context.dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.white : context.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.navyAdaptive),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: context.navyAdaptive.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.navyAdaptive,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter Tile (no stagger delay)
// ---------------------------------------------------------------------------

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final ChapterProgress? chapterProgress;
  final bool isCompleted;
  final bool isRecommended;

  const _ChapterTile({
    required this.chapter,
    this.chapterProgress,
    required this.isCompleted,
    required this.isRecommended,
  });

  @override
  Widget build(BuildContext context) {
    final pct = chapterProgress?.completionPercent ?? 0.0;

    return FrenchCard(
      onTap: () => context.push('/lesson/${chapter.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : context.navyAdaptive.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    chapterIconFromString(chapter.icon),
                    size: 24,
                    color: isCompleted
                        ? AppColors.success
                        : context.navyAdaptive,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 20,
                          ),
                        if (isRecommended && !isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Recommended',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chapter.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: context.progressBgColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.success : AppColors.red,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${chapter.sections.length} sections',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: context.textLight,
                ),
              ),
              Text(
                '${pct.toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? AppColors.success
                      : context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Word Bank Grid (inline categories)
// ---------------------------------------------------------------------------

const _vocabCategories = <({String key, String label, IconData icon})>[
  (key: 'greetings', label: 'Greetings', icon: Icons.waving_hand_rounded),
  (key: 'family', label: 'Family', icon: Icons.family_restroom_rounded),
  (key: 'food', label: 'Food', icon: Icons.restaurant_rounded),
  (key: 'home', label: 'Home', icon: Icons.home_rounded),
  (key: 'daily_routine', label: 'Daily Routine', icon: Icons.schedule_rounded),
  (key: 'work', label: 'Work', icon: Icons.work_rounded),
  (key: 'emotions', label: 'Emotions', icon: Icons.mood_rounded),
  (key: 'colors', label: 'Colors', icon: Icons.palette_rounded),
  (key: 'time', label: 'Time', icon: Icons.access_time_rounded),
  (key: 'weather', label: 'Weather', icon: Icons.cloud_rounded),
  (key: 'shopping', label: 'Shopping', icon: Icons.shopping_bag_rounded),
  (key: 'city', label: 'City', icon: Icons.location_city_rounded),
  (key: 'travel', label: 'Travel', icon: Icons.flight_rounded),
  (key: 'health', label: 'Health', icon: Icons.health_and_safety_rounded),
  (key: 'education', label: 'Education', icon: Icons.school_rounded),
  (key: 'nature', label: 'Nature', icon: Icons.park_rounded),
  (key: 'clothing', label: 'Clothing', icon: Icons.checkroom_rounded),
  (key: 'body', label: 'Body', icon: Icons.accessibility_new_rounded),
  (key: 'numbers_misc', label: 'Numbers', icon: Icons.tag_rounded),
  (key: 'hobbies', label: 'Hobbies', icon: Icons.sports_tennis_rounded),
  (key: 'technology', label: 'Technology', icon: Icons.devices_rounded),
  (key: 'transportation', label: 'Transport', icon: Icons.directions_bus_rounded),
  (key: 'finance', label: 'Finance', icon: Icons.account_balance_rounded),
  (key: 'media', label: 'Media', icon: Icons.newspaper_rounded),
  (key: 'environment', label: 'Environment', icon: Icons.eco_rounded),
  (key: 'society', label: 'Society', icon: Icons.groups_rounded),
];

class _WordBankGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabAsync = ref.watch(vocabularyProvider);
    final studiedIds = ref.watch(studiedCardIdsProvider).whenOrNull(data: (ids) => ids) ?? <String>{};

    return vocabAsync.when(
      data: (allWords) {
        final wordsPerCategory = <String, List<VocabularyWord>>{};
        for (final word in allWords) {
          wordsPerCategory.putIfAbsent(word.category, () => []).add(word);
        }

        final activeCategories = _vocabCategories
            .where((c) => wordsPerCategory.containsKey(c.key))
            .toList();

        final hPad = context.horizontalPadding;
        final columns = context.gridColumns;

        return SliverPadding(
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
              final studiedCount = words.where((w) => studiedIds.contains(w.id)).length;
              final isComplete = studiedCount == words.length && words.isNotEmpty;

              return _VocabCategoryCard(
                categoryKey: cat.key,
                label: cat.label,
                icon: cat.icon,
                wordCount: words.length,
                studiedCount: studiedCount,
                isComplete: isComplete,
              );
            }, childCount: activeCategories.length),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: ErrorView(onRetry: () => ref.invalidate(vocabularyProvider)),
      ),
    );
  }
}

class _VocabCategoryCard extends StatelessWidget {
  final String categoryKey;
  final String label;
  final IconData icon;
  final int wordCount;
  final int studiedCount;
  final bool isComplete;

  const _VocabCategoryCard({
    required this.categoryKey,
    required this.label,
    required this.icon,
    required this.wordCount,
    required this.studiedCount,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isComplete ? AppColors.success : context.navyAdaptive;
    final hasStarted = studiedCount > 0;

    return FrenchCard(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/words/$categoryKey'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: Icon(icon, size: 22, color: accentColor),
                ),
              ),
              if (isComplete)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$wordCount words',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
          const Spacer(),
          if (hasStarted) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: wordCount > 0 ? studiedCount / wordCount : 0,
                minHeight: 4,
                backgroundColor: context.progressBgColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? AppColors.success : AppColors.red,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TEF Test List (inline tests)
// ---------------------------------------------------------------------------

class _TefTestList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tefAsync = ref.watch(tefTestsProvider);
    final progress = ref.watch(progressProvider);

    return tefAsync.when(
      data: (tests) {
        if (tests.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No practice tests available yet.'),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final test = tests[index];
              final bestResult = progress.bestTefResult(test.id);
              final isCompleted = bestResult != null;

              return FrenchCard(
                onTap: () => context.push('/tef/${test.id}'),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : context.navyAdaptive.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 24,
                          color: isCompleted
                              ? AppColors.success
                              : context.navyAdaptive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            test.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: context.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          if (bestResult != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Best: ${bestResult.score}/${bestResult.totalQuestions}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isCompleted)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: context.textLight,
                      ),
                  ],
                ),
              );
            },
            childCount: tests.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: ErrorView(onRetry: () => ref.invalidate(tefTestsProvider)),
      ),
    );
  }
}
