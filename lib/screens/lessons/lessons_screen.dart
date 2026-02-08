import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/icon_map.dart';
import '../../models/chapter.dart';
import '../../models/progress.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/error_view.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final progress = ref.watch(progressProvider);

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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lessons',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Master French step by step',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _LessonTile(
                      chapter: inProgress[index],
                      progress: progress.chapters[inProgress[index].id],
                      index: index,
                    ),
                    childCount: inProgress.length,
                  ),
                ),
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
                      (context, index) => _LessonTile(
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

class _LessonTile extends StatelessWidget {
  final Chapter chapter;
  final ChapterProgress? progress;
  final int index;

  const _LessonTile({
    required this.chapter,
    this.progress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final pct = progress?.completionPercent ?? 0.0;
    final isCompleted = pct >= 100;

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
                      : AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    chapterIconFromString(chapter.icon),
                    size: 24,
                    color: isCompleted ? AppColors.success : AppColors.navy,
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
    )
        .animate()
        .fadeIn(
          delay: (80 * (index < 5 ? index : 5)).ms,
          duration: 400.ms,
        )
        .slideY(begin: 0.1);
  }
}
