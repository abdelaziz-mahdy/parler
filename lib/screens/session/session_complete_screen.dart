import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/responsive.dart';
import '../../providers/database_provider.dart';
import '../../providers/progress_provider.dart';

class SessionCompleteScreen extends ConsumerStatefulWidget {
  final int reviewedCount;
  final int newWordsCount;
  final int correctCount;

  const SessionCompleteScreen({
    super.key,
    required this.reviewedCount,
    required this.newWordsCount,
    required this.correctCount,
  });

  @override
  ConsumerState<SessionCompleteScreen> createState() =>
      _SessionCompleteScreenState();
}

class _SessionCompleteScreenState
    extends ConsumerState<SessionCompleteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider.notifier).updateStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final masteredAsync = ref.watch(masteredCountProvider);
    final mastered = masteredAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, _) => 0,
    );

    final accuracy = widget.reviewedCount > 0
        ? (widget.correctCount / widget.reviewedCount * 100).round()
        : 0;

    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 800,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Celebration icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 52,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 28),
                  Text(
                    'Session Complete!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 8),
                  if (accuracy > 0)
                    Text(
                      '$accuracy% accuracy',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: context.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),

                  // Stats card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.refresh_rounded,
                          label: 'Words reviewed',
                          value: '${widget.reviewedCount}',
                          color: context.navyAdaptive,
                        ),
                        _divider(context),
                        _StatRow(
                          icon: Icons.auto_awesome_rounded,
                          label: 'New words learned',
                          value: '${widget.newWordsCount}',
                          color: AppColors.info,
                        ),
                        _divider(context),
                        _StatRow(
                          icon: Icons.check_circle_rounded,
                          label: 'Correct answers',
                          value: '${widget.correctCount}',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
                  const SizedBox(height: 16),

                  // Streak & mastered
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Current streak',
                          value:
                              '${progress.currentStreak} day${progress.currentStreak == 1 ? '' : 's'}',
                          color: AppColors.gold,
                        ),
                        _divider(context),
                        _StatRow(
                          icon: Icons.emoji_events_rounded,
                          label: 'Words mastered',
                          value: '$mastered',
                          color: AppColors.gold,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05),
                  const SizedBox(height: 32),

                  // Done button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/today'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Done for today',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 550.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: context.dividerColor, height: 1),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: context.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}
