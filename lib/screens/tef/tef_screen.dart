import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../models/tef_test.dart';
import '../../models/progress.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/error_view.dart';

class TefScreen extends ConsumerWidget {
  const TefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(tefTestsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      body: SafeArea(
        child: testsAsync.when(
          data: (tests) {
            final available = <TefTest>[];
            final completed = <TefTest>[];
            for (final test in tests) {
              final best = progress.bestTefResult(test.id);
              if (best != null) {
                completed.add(test);
              } else {
                available.add(test);
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
                          'TEF Practice',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prepare for the TEF exam',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (available.isEmpty && completed.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No practice tests available yet.'),
                    ),
                  )
                else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _TefTestTile(
                        test: available[index],
                        bestResult: null,
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
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: AppColors.success,
                            ),
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
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.12,
                                ),
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
                        (context, index) => _TefTestTile(
                          test: completed[index],
                          bestResult: progress.bestTefResult(
                            completed[index].id,
                          ),
                          index: index,
                        ),
                        childCount: completed.length,
                      ),
                    ),
                  ],
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              ErrorView(onRetry: () => ref.invalidate(tefTestsProvider)),
        ),
      ),
    );
  }
}

class _TefTestTile extends StatelessWidget {
  final TefTest test;
  final TefTestResult? bestResult;
  final int index;

  const _TefTestTile({
    required this.test,
    this.bestResult,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = bestResult != null;

    return FrenchCard(
          onTap: () => context.push('/tef/${test.id}'),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                test.title,
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
                          test.description,
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
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${test.timeMinutes} min',
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.quiz_outlined,
                    label: '${test.totalQuestions} questions',
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _DifficultyChip(difficulty: test.difficulty),
                  const Spacer(),
                  if (isCompleted)
                    Text(
                      'Best: ${bestResult!.percentage}%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    )
                  else
                    Text(
                      'Start',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (80 * (index < 5 ? index : 5)).ms, duration: 400.ms)
        .slideY(begin: 0.1);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.textLight),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: context.textLight),
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _colorFor(String d) {
    switch (d) {
      case 'A1':
      case 'A2':
        return AppColors.success;
      case 'B1':
        return AppColors.warning;
      case 'B2':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
