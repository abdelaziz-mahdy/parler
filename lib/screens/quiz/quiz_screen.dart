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

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: chaptersAsync.when(
          data: (chapters) {
            final available = <Chapter>[];
            final completed = <Chapter>[];
            for (final chapter in chapters) {
              final cp = progress.chapters[chapter.id];
              if (cp != null && cp.quizAttempts > 0) {
                completed.add(chapter);
              } else {
                available.add(chapter);
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
                          'Quizzes',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Test your knowledge',
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
                    (context, index) => _QuizTile(
                      chapter: available[index],
                      progress: progress.chapters[available[index].id],
                      index: index,
                    ),
                    childCount: available.length,
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
                      (context, index) => _QuizTile(
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

class _QuizTile extends StatelessWidget {
  final Chapter chapter;
  final ChapterProgress? progress;
  final int index;

  const _QuizTile({
    required this.chapter,
    this.progress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final best = progress?.quizBestScore ?? 0;
    final attempts = progress?.quizAttempts ?? 0;
    final hasAttempted = attempts > 0;

    return FrenchCard(
      onTap: () => context.push('/quiz/${chapter.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasAttempted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                chapterIconFromString(chapter.icon),
                size: 24,
                color: hasAttempted ? AppColors.success : AppColors.red,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    if (hasAttempted)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (hasAttempted)
                  Text(
                    'Best: $best% \u2022 $attempts attempt${attempts == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Not attempted yet',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textLight,
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
              color: hasAttempted ? AppColors.success : AppColors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasAttempted ? 'Retry' : 'Start',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
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
