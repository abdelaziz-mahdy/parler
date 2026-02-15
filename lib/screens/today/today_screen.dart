import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/icon_map.dart';
import '../../core/constants/responsive.dart';
import '../../database/app_database.dart';
import '../../models/chapter.dart';
import '../../models/vocabulary_word.dart';
import '../../providers/data_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/progress_ring.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final dueCardsAsync = ref.watch(dueCardsProvider);
    final masteredAsync = ref.watch(masteredCountProvider);
    final vocabAsync = ref.watch(vocabularyProvider);
    final chapterProgressAsync = ref.watch(chapterProgressStreamProvider);

    final hPad = context.horizontalPadding;

    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          child: CustomScrollView(
            slivers: [
              // -- Header --
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 8),
                  child: Text(
                    'Today',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),
              ),

              // -- Streak Banner --
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
                  child: _StreakBanner(
                    streak: progress.currentStreak,
                    freezes: progress.streakFreezes,
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.06),
              ),

              // -- Start Session Button --
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: _StartSessionButton(
                    onTap: () => context.push('/session'),
                  ),
                ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.06),
              ),

              // -- Session Preview --
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
                  child: _SessionPreview(
                    dueCardsAsync: dueCardsAsync,
                    vocabAsync: vocabAsync,
                    progress: progress,
                  ),
                ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.06),
              ),

              // -- Words Mastered Counter --
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
                  child: _MasteredCard(
                    masteredAsync: masteredAsync,
                    vocabAsync: vocabAsync,
                  ),
                ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(begin: 0.06),
              ),

              // -- Chapter Roadmap --
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 4),
                  child: Text(
                    'Your Journey',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ),
              SliverToBoxAdapter(
                child: chaptersAsync.when(
                  data: (chapters) => _ChapterRoadmap(
                    chapters: chapters,
                    chapterProgressAsync: chapterProgressAsync,
                    legacyProgress: progress,
                  ),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => ErrorView(
                    onRetry: () => ref.invalidate(chaptersProvider),
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Streak Banner
// ---------------------------------------------------------------------------

class _StreakBanner extends StatelessWidget {
  final int streak;
  final int freezes;

  const _StreakBanner({required this.streak, required this.freezes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: context.isDark ? 0.18 : 0.12),
            AppColors.goldLight.withValues(alpha: context.isDark ? 0.10 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 26,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day${streak == 1 ? '' : 's'} streak',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _streakMotivation(streak),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (freezes > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: context.isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.ac_unit_rounded,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$freezes',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _streakMotivation(int streak) {
    if (streak >= 30) return 'Incredible dedication!';
    if (streak >= 14) return 'Two weeks strong!';
    if (streak >= 7) return 'A full week! Magnifique!';
    if (streak >= 3) return 'Building momentum!';
    if (streak >= 1) return 'Keep it going!';
    return 'Start your streak today!';
  }
}

// ---------------------------------------------------------------------------
// Start Session Button
// ---------------------------------------------------------------------------

class _StartSessionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StartSessionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.red,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                "Start Today's Session",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(onComplete: (c) => c.repeat(reverse: true))
        .shimmer(
          delay: 2000.ms,
          duration: 1500.ms,
          color: AppColors.white.withValues(alpha: 0.15),
        );
  }
}

// ---------------------------------------------------------------------------
// Session Preview
// ---------------------------------------------------------------------------

class _SessionPreview extends StatelessWidget {
  final AsyncValue<List<CardState>> dueCardsAsync;
  final AsyncValue<List<VocabularyWord>> vocabAsync;
  final dynamic progress;

  const _SessionPreview({
    required this.dueCardsAsync,
    required this.vocabAsync,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final dueCount = dueCardsAsync.whenOrNull(data: (cards) => cards.length) ?? 0;

    int newWordCount = 0;
    if (vocabAsync case AsyncData<List<VocabularyWord>>(:final value)) {
      newWordCount = value.where((w) {
        final card = progress.flashcards['vocab_${w.french}'];
        return card == null || card.repetitions == 0;
      }).length;
      if (newWordCount > 15) newWordCount = 15;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PreviewChip(
            icon: Icons.replay_rounded,
            color: AppColors.red,
            label: '$dueCount reviews',
          ),
          Container(
            width: 1,
            height: 28,
            color: context.dividerColor,
          ),
          _PreviewChip(
            icon: Icons.auto_stories_rounded,
            color: AppColors.gold,
            label: '$newWordCount new words',
          ),
          Container(
            width: 1,
            height: 28,
            color: context.dividerColor,
          ),
          _PreviewChip(
            icon: Icons.quiz_rounded,
            color: AppColors.info,
            label: '1 practice',
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _PreviewChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mastered Card
// ---------------------------------------------------------------------------

class _MasteredCard extends StatelessWidget {
  final AsyncValue<int> masteredAsync;
  final AsyncValue<List<VocabularyWord>> vocabAsync;

  const _MasteredCard({
    required this.masteredAsync,
    required this.vocabAsync,
  });

  @override
  Widget build(BuildContext context) {
    final mastered = masteredAsync.whenOrNull(data: (c) => c) ?? 0;
    final total = vocabAsync.whenOrNull(data: (w) => w.length) ?? 1;
    final progress = total > 0 ? mastered / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 56,
            strokeWidth: 5,
            color: AppColors.success,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Words Mastered',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You know $mastered French words',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'out of $total total',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter Roadmap
// ---------------------------------------------------------------------------

class _ChapterRoadmap extends StatelessWidget {
  final List<Chapter> chapters;
  final AsyncValue<List<ChapterProgressesData>> chapterProgressAsync;
  final dynamic legacyProgress;

  const _ChapterRoadmap({
    required this.chapters,
    required this.chapterProgressAsync,
    required this.legacyProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Build a map of chapter progress from Drift stream or fall back to legacy
    final driftProgressMap = <String, double>{};
    if (chapterProgressAsync case AsyncData<List<ChapterProgressesData>>(:final value)) {
      for (final cp in value) {
        driftProgressMap[cp.chapterId] = cp.masteryPercent;
      }
    }

    // Determine current chapter index (first incomplete)
    int currentIndex = chapters.length; // all done by default
    for (int i = 0; i < chapters.length; i++) {
      final chId = chapters[i].id;
      final driftPct = driftProgressMap[chId.toString()];
      final legacyPct = legacyProgress.chapters[chId]?.completionPercent ?? 0.0;
      final pct = driftPct ?? legacyPct;
      if (pct < 100) {
        currentIndex = i;
        break;
      }
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: 12,
        ),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          final chId = chapter.id;
          final driftPct = driftProgressMap[chId.toString()];
          final legacyPct = legacyProgress.chapters[chId]?.completionPercent ?? 0.0;
          final pct = driftPct ?? legacyPct;

          final isCompleted = pct >= 100;
          final isCurrent = index == currentIndex;

          return Padding(
            padding: EdgeInsets.only(right: index < chapters.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => context.push('/lesson/${chapter.id}'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.red
                              : context.isDark
                                  ? AppColors.darkCard
                                  : AppColors.surfaceLight,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.success
                            : isCurrent
                                ? AppColors.red
                                : context.dividerColor,
                        width: isCurrent ? 2.5 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.white,
                              size: 22,
                            )
                          : Icon(
                              chapterIconFromString(chapter.icon),
                              color: isCurrent
                                  ? AppColors.white
                                  : context.textLight,
                              size: 20,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 52,
                    child: Text(
                      'Ch ${index + 1}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent
                            ? AppColors.red
                            : isCompleted
                                ? AppColors.success
                                : context.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.05);
  }
}
