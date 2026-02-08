import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/icon_map.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/stat_badge.dart';
import '../../widgets/progress_ring.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final chaptersAsync = ref.watch(chaptersProvider);

    final totalChapters = chaptersAsync.when(
      data: (c) => c.length,
      loading: () => 0,
      error: (_, _) => 0,
    );

    final completedChapters = progress.chapters.values
        .where((c) => c.completionPercent >= 100)
        .length;

    final overallProgress =
        totalChapters > 0 ? completedChapters / totalChapters : 0.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            // Header
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, AppColors.navyLight],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'P',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'French Learner',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learning in progress',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            // Overall progress
            FrenchCard(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  ProgressRing(
                    progress: overallProgress,
                    size: 64,
                    strokeWidth: 5,
                    color: AppColors.red,
                    child: Text(
                      '${(overallProgress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedChapters of $totalChapters chapters complete',
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
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: 20),

            // Stats grid
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
              ],
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatBadge(
                    value: '$completedChapters',
                    label: 'Completed',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatBadge(
                    value: '${progress.flashcards.length}',
                    label: 'Cards Reviewed',
                    icon: Icons.style_rounded,
                    color: AppColors.info,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // Chapter progress list
            Text(
              'Chapter Progress',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            chaptersAsync.when(
              data: (chapters) => Column(
                children: chapters.asMap().entries.map((entry) {
                  final i = entry.key;
                  final chapter = entry.value;
                  final cp = progress.chapters[chapter.id];
                  final pct = cp?.completionPercent ?? 0.0;
                  final best = cp?.quizBestScore ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FrenchCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            chapterIconFromString(chapter.icon),
                            size: 20,
                            color: pct >= 100
                                ? AppColors.success
                                : AppColors.navy,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct / 100,
                                    minHeight: 4,
                                    backgroundColor:
                                        AppColors.progressBg,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      pct >= 100
                                          ? AppColors.success
                                          : AppColors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${pct.toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: pct >= 100
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (best > 0)
                                Text(
                                  'Quiz: $best%',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: (400 + i * 60).ms,
                        duration: 300.ms,
                      );
                }).toList(),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => ErrorView(
                onRetry: () => ref.invalidate(chaptersProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
