import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/icon_map.dart';
import '../../providers/data_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/tts_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/french_card.dart';
import '../../widgets/stat_badge.dart';

class NewProfileScreen extends ConsumerStatefulWidget {
  const NewProfileScreen({super.key});

  @override
  ConsumerState<NewProfileScreen> createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends ConsumerState<NewProfileScreen> {
  late String _sessionLength;
  late TtsSpeed _ttsSpeed;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _sessionLength = prefs.getString('session_length') ?? 'regular';
    final savedSpeed = prefs.getString('tts_speed');
    _ttsSpeed = savedSpeed == 'slow' ? TtsSpeed.slow : TtsSpeed.normal;
  }

  Future<void> _setSessionLength(String value) async {
    setState(() => _sessionLength = value);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('session_length', value);
  }

  Future<void> _setTtsSpeed(TtsSpeed speed) async {
    setState(() => _ttsSpeed = speed);
    final tts = ref.read(ttsServiceProvider);
    await tts.setSpeed(speed);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('tts_speed', speed == TtsSpeed.slow ? 'slow' : 'normal');
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final chaptersAsync = ref.watch(chaptersProvider);
    final masteredCount = ref.watch(masteredCountProvider);
    final totalStudied = ref.watch(totalStudiedProvider);
    final chapterProgressStream = ref.watch(chapterProgressStreamProvider);
    final themeMode = ref.watch(themeModeProvider);

    final completedChapters = chaptersAsync.when(
      data: (chapters) {
        final dbProgress = chapterProgressStream.value ?? [];
        return dbProgress.where((cp) {
          return cp.masteryPercent >= 100;
        }).length;
      },
      loading: () => 0,
      error: (_, _) => 0,
    );

    final isDark = context.isDark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            // Header
            Text(
              'Profile',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Stats dashboard — 2x2 grid
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
                    value: masteredCount.when(
                      data: (v) => '$v',
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    label: 'Mastered',
                    icon: Icons.star_rounded,
                    color: AppColors.info,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: StatBadge(
                    value: '$completedChapters',
                    label: 'Chapters Done',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatBadge(
                    value: totalStudied.when(
                      data: (v) => '$v',
                      loading: () => '...',
                      error: (_, _) => '0',
                    ),
                    label: 'Total Reviews',
                    icon: Icons.refresh_rounded,
                    color: const Color(0xFF9B59B6),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            // Chapter mastery bars
            Text(
              'Chapter Progress',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            chaptersAsync.when(
              data: (chapters) {
                final dbProgress = chapterProgressStream.value ?? [];
                final progressMap = <String, double>{};
                for (final cp in dbProgress) {
                  progressMap[cp.chapterId] = cp.masteryPercent.toDouble();
                }

                return Column(
                  children: chapters.asMap().entries.map((entry) {
                    final chapter = entry.value;
                    final pct = progressMap[chapter.id.toString()] ??
                        (progress.chapters[chapter.id]?.completionPercent ?? 0.0);

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
                                  : context.navyAdaptive,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chapter.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: (pct / 100).clamp(0.0, 1.0),
                                      minHeight: 4,
                                      backgroundColor: context.progressBgColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(
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
                            Text(
                              '${pct.toInt()}%',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: pct >= 100
                                    ? AppColors.success
                                    : context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
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

            const SizedBox(height: 28),

            // Settings section
            Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            // Session Length
            FrenchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Length',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'casual', label: Text('Casual')),
                        ButtonSegment(value: 'regular', label: Text('Regular')),
                        ButtonSegment(value: 'intense', label: Text('Intense')),
                      ],
                      selected: {_sessionLength},
                      onSelectionChanged: (v) => _setSessionLength(v.first),
                      style: SegmentedButton.styleFrom(
                        selectedForegroundColor: AppColors.white,
                        selectedBackgroundColor: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            // TTS Speed
            FrenchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.volume_up_rounded, size: 20, color: context.navyAdaptive),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TTS Speed',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  SegmentedButton<TtsSpeed>(
                    segments: const [
                      ButtonSegment(value: TtsSpeed.slow, label: Text('Slow')),
                      ButtonSegment(value: TtsSpeed.normal, label: Text('Normal')),
                    ],
                    selected: {_ttsSpeed},
                    onSelectionChanged: (v) => _setTtsSpeed(v.first),
                    style: SegmentedButton.styleFrom(
                      selectedForegroundColor: AppColors.white,
                      selectedBackgroundColor: AppColors.red,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            // Dark Mode
            FrenchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 20,
                    color: context.navyAdaptive,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dark Mode',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                    activeThumbColor: AppColors.red,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            // Streak Freezes
            FrenchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.ac_unit_rounded, size: 20, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streak Freezes',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Earn 1 every 7-day streak (max 2)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${progress.streakFreezes}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
