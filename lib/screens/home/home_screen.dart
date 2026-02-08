import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/icon_map.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/stat_badge.dart';
import '../../widgets/error_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final chaptersAsync = ref.watch(chaptersProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.greeting,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.greetingSubtitle,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.gold,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${progress.currentStreak}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 24),
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: StatBadge(
                            value: '${progress.currentStreak}',
                            label: 'Day Streak',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBadge(
                            value: '${progress.totalXp}',
                            label: 'Total XP',
                            icon: Icons.star_rounded,
                            color: AppColors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatBadge(
                            value: '${progress.chapters.length}',
                            label: 'Chapters',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.2),
                    const SizedBox(height: 28),
                    if (progress.totalXp == 0 && progress.chapters.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FrenchCard(
                          margin: EdgeInsets.zero,
                          color: AppColors.cream,
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flag_rounded,
                                  color: AppColors.red,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start your first lesson!',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Pick a chapter below to begin.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Text(
                      AppStrings.continueLesson,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            chaptersAsync.when(
              data: (chapters) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    final chapterProgress =
                        progress.chapters[chapter.id];
                    final pct =
                        chapterProgress?.completionPercent ?? 0.0;
                    return FrenchCard(
                      onTap: () => context.push('/lesson/${chapter.id}'),
                      child: Row(
                        children: [
                          ProgressRing(
                            progress: pct / 100,
                            size: 52,
                            strokeWidth: 4,
                            color: pct >= 100
                                ? AppColors.success
                                : AppColors.red,
                            child: Icon(
                              chapterIconFromString(chapter.icon),
                              size: 22,
                              color: pct >= 100
                                  ? AppColors.success
                                  : AppColors.navy,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chapter.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textLight,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: (100 * (index < 5 ? index : 5)).ms,
                          duration: 400.ms,
                        )
                        .slideX(begin: 0.1);
                  },
                  childCount: chapters.length,
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverErrorView(
                onRetry: () => ref.invalidate(chaptersProvider),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
