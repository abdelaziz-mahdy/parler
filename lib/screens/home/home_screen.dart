import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/icon_map.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/chapter.dart';
import '../../models/progress.dart';
import '../../widgets/french_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/error_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final chaptersAsync = ref.watch(chaptersProvider);

    return Scaffold(
      body: SafeArea(
        child: chaptersAsync.when(
          data: (chapters) {
            final inProgress = <Chapter>[];
            final completed = <Chapter>[];
            for (final chapter in chapters) {
              final cp = progress.chapters[chapter.id];
              if (cp != null && cp.completionPercent >= 100) {
                completed.add(chapter);
              } else {
                inProgress.add(chapter);
              }
            }

            return CustomScrollView(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.greeting,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.greetingSubtitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => ref
                                      .read(themeModeProvider.notifier)
                                      .toggle(),
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
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.15),
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
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.continueLesson,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                // In-progress chapters
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ChapterTile(
                      chapter: inProgress[index],
                      progress: progress.chapters[inProgress[index].id],
                      index: index,
                    ),
                    childCount: inProgress.length,
                  ),
                ),
                // Completed section
                if (completed.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 20, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text(
                            'Completed',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${completed.length}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ChapterTile(
                        chapter: completed[index],
                        progress: progress.chapters[completed[index].id],
                        index: index,
                      ),
                      childCount: completed.length,
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorView(
            onRetry: () => ref.invalidate(chaptersProvider),
          ),
        ),
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final ChapterProgress? progress;
  final int index;

  const _ChapterTile({
    required this.chapter,
    this.progress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final pct = progress?.completionPercent ?? 0.0;
    return FrenchCard(
      onTap: () => context.push('/lesson/${chapter.id}'),
      child: Row(
        children: [
          ProgressRing(
            progress: pct / 100,
            size: 52,
            strokeWidth: 4,
            color: pct >= 100 ? AppColors.success : AppColors.red,
            child: Icon(
              chapterIconFromString(chapter.icon),
              size: 22,
              color: pct >= 100 ? AppColors.success : AppColors.navy,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chapter.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.textLight,
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
  }
}
