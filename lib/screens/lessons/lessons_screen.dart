import 'dart:math' as math;

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
import '../../providers/theme_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/error_view.dart';

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  bool _todayExpanded = true;

  @override
  Widget build(BuildContext context) {
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
                // -- Header --
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
                                    color: AppColors.gold
                                        .withValues(alpha: 0.15),
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
                        ),
                      ],
                    ),
                  ),
                ),

                // -- Today Section --
                SliverToBoxAdapter(
                  child: _TodaySection(
                    progress: progress,
                    chapters: chapters,
                    inProgress: inProgress,
                    expanded: _todayExpanded,
                    onToggle: () =>
                        setState(() => _todayExpanded = !_todayExpanded),
                  ),
                ),

                // -- In-progress chapter list --
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

// ---------------------------------------------------------------------------
// Today Section
// ---------------------------------------------------------------------------

class _TodaySection extends StatelessWidget {
  final UserProgress progress;
  final List<Chapter> chapters;
  final List<Chapter> inProgress;
  final bool expanded;
  final VoidCallback onToggle;

  const _TodaySection({
    required this.progress,
    required this.chapters,
    required this.inProgress,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Compute daily tasks data
    final today = DateTime.now().toIso8601String().split('T').first;

    // 1) Words due for review
    final dueCards = progress.flashcards.entries.where((entry) {
      if (!entry.key.startsWith('vocab_')) return false;
      return entry.value.nextReviewDate.compareTo(today) <= 0;
    }).toList();
    final dueCount = dueCards.length;

    // 2) Next unfinished chapter
    Chapter? nextChapter;
    for (final chapter in chapters) {
      final cp = progress.chapters[chapter.id];
      if (cp == null || cp.completionPercent < 100) {
        nextChapter = chapter;
        break;
      }
    }

    // 3) Quiz suggestion: chapter with low score (<80%) or never quizzed
    Chapter? quizChapter;
    for (final chapter in chapters) {
      final cp = progress.chapters[chapter.id];
      if (cp == null || cp.quizAttempts == 0 || cp.quizBestScore < 80) {
        quizChapter = chapter;
        break;
      }
    }

    // 4) Daily progress: count how many tasks are done
    int totalTasks = 0;
    int completedTasks = 0;

    // Streak task: studied today?
    totalTasks++;
    final studiedToday = progress.lastStudyDate == today;
    if (studiedToday) completedTasks++;

    // Review task
    if (dueCount > 0 || progress.flashcards.isNotEmpty) {
      totalTasks++;
      if (dueCount == 0 && progress.flashcards.isNotEmpty) completedTasks++;
    }

    // Continue learning task
    if (nextChapter != null) {
      totalTasks++;
      // Not done since there's still an unfinished chapter
    } else if (chapters.isNotEmpty) {
      // All chapters complete
      totalTasks++;
      completedTasks++;
    }

    // Quiz task
    if (quizChapter != null) {
      totalTasks++;
      // Not done since there's a chapter needing quiz improvement
    } else if (chapters.isNotEmpty) {
      totalTasks++;
      completedTasks++;
    }

    // Streak motivational message
    final streakMessage = _getStreakMessage(progress.currentStreak, studiedToday);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          // Collapsible header
          _TodayHeader(
            expanded: expanded,
            onToggle: onToggle,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06),
          // Collapsible content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  // Daily Streak Card
                  _DailyStreakCard(
                    streak: progress.currentStreak,
                    studiedToday: studiedToday,
                    message: streakMessage,
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.06),
                  const SizedBox(height: 8),
                  // Task rows
                  Row(
                    children: [
                      // Words Due
                      Expanded(
                        child: _TaskMiniCard(
                          icon: Icons.replay_rounded,
                          iconColor: AppColors.red,
                          title: 'Review Words',
                          subtitle: dueCount > 0
                              ? '$dueCount card${dueCount == 1 ? '' : 's'} due'
                              : 'All caught up!',
                          isDone: dueCount == 0 && progress.flashcards.isNotEmpty,
                          onTap: dueCount > 0
                              ? () => context.push('/words/review')
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quiz Suggestion
                      Expanded(
                        child: _TaskMiniCard(
                          icon: Icons.quiz_rounded,
                          iconColor: AppColors.info,
                          title: 'Take a Quiz',
                          subtitle: quizChapter != null
                              ? quizChapter.title
                              : 'All quizzed!',
                          isDone: quizChapter == null && chapters.isNotEmpty,
                          onTap: quizChapter != null
                              ? () => context.push('/quiz/${quizChapter!.id}')
                              : null,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.06),
                  const SizedBox(height: 8),
                  // Continue Learning
                  if (nextChapter != null)
                    _ContinueLearningCard(
                      chapter: nextChapter,
                      chapterProgress: progress.chapters[nextChapter.id],
                    ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.06),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
          const SizedBox(height: 8),
          // Divider
          Container(
            height: 1,
            color: context.dividerColor,
          ),
        ],
      ),
    );
  }

  String _getStreakMessage(int streak, bool studiedToday) {
    if (!studiedToday) {
      if (streak > 0) {
        return "Don't break your $streak-day streak!";
      }
      return 'Start your streak today!';
    }
    if (streak >= 30) return 'Incredible dedication!';
    if (streak >= 14) return 'Two weeks strong!';
    if (streak >= 7) return 'A full week! Magnifique!';
    if (streak >= 3) return 'Building momentum!';
    return 'Great start, keep going!';
  }
}

// ---------------------------------------------------------------------------
// Today Header with progress ring
// ---------------------------------------------------------------------------

class _TodayHeader extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final int completedTasks;
  final int totalTasks;

  const _TodayHeader({
    required this.expanded,
    required this.onToggle,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Daily Progress Ring
            SizedBox(
              width: 36,
              height: 36,
              child: CustomPaint(
                painter: _ProgressRingPainter(
                  progress: totalTasks > 0 ? completedTasks / totalTasks : 0,
                  trackColor: context.progressBgColor,
                  fillColor: completedTasks == totalTasks
                      ? AppColors.success
                      : AppColors.gold,
                ),
                child: Center(
                  child: Text(
                    '$completedTasks/$totalTasks',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    completedTasks == totalTasks
                        ? 'All tasks complete!'
                        : '${totalTasks - completedTasks} task${(totalTasks - completedTasks) == 1 ? '' : 's'} remaining',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.0 : -0.25,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.textLight,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress Ring Painter
// ---------------------------------------------------------------------------

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 3;
    const strokeWidth = 4.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}

// ---------------------------------------------------------------------------
// Daily Streak Card
// ---------------------------------------------------------------------------

class _DailyStreakCard extends StatelessWidget {
  final int streak;
  final bool studiedToday;
  final String message;

  const _DailyStreakCard({
    required this.streak,
    required this.studiedToday,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: context.isDark ? 0.15 : 0.10),
            AppColors.gold.withValues(alpha: context.isDark ? 0.08 : 0.04),
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
              color: AppColors.gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 24,
                color: studiedToday ? AppColors.gold : AppColors.goldDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$streak day${streak == 1 ? '' : 's'} streak',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    if (studiedToday) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message,
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
// Task Mini Card (used for Review Words and Quiz Suggestion in a row)
// ---------------------------------------------------------------------------

class _TaskMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDone;
  final VoidCallback? onTap;

  const _TaskMiniCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDone ? AppColors.success : iconColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: context.isDark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDone ? Icons.check_circle_rounded : icon,
                      size: 20,
                      color: effectiveColor,
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: context.textLight,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Continue Learning Card
// ---------------------------------------------------------------------------

class _ContinueLearningCard extends StatelessWidget {
  final Chapter chapter;
  final ChapterProgress? chapterProgress;

  const _ContinueLearningCard({
    required this.chapter,
    this.chapterProgress,
  });

  @override
  Widget build(BuildContext context) {
    final pct = chapterProgress?.completionPercent ?? 0.0;
    final hasStarted = pct > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/lesson/${chapter.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.navyAdaptive.withValues(alpha: context.isDark ? 0.15 : 0.08),
                context.navyAdaptive.withValues(alpha: context.isDark ? 0.08 : 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.navyAdaptive.withValues(alpha: 0.18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.navyAdaptive.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      chapterIconFromString(chapter.icon),
                      size: 20,
                      color: context.navyAdaptive,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasStarted ? 'Continue Learning' : 'Start Learning',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: context.navyAdaptive,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chapter.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasStarted) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 4,
                            backgroundColor: context.progressBgColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.navyAdaptive.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: context.navyAdaptive,
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

// ---------------------------------------------------------------------------
// Lesson Tile (unchanged from original)
// ---------------------------------------------------------------------------

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
                      : context.navyAdaptive.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    chapterIconFromString(chapter.icon),
                    size: 24,
                    color: isCompleted ? AppColors.success : context.navyAdaptive,
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
