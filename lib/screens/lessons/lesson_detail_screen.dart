import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chapter.dart';
import '../../providers/data_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/data_source_content.dart';
import '../../widgets/error_view.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final int chapterId;
  const LessonDetailScreen({super.key, required this.chapterId});

  @override
  ConsumerState<LessonDetailScreen> createState() =>
      _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  int _currentSection = 0;

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider);

    return chaptersAsync.when(
      data: (chapters) {
        final chapter = chapters.firstWhere(
          (c) => c.id == widget.chapterId,
          orElse: () => chapters.first,
        );
        final sections = chapter.sections;
        final section =
            sections.isNotEmpty ? sections[_currentSection] : null;
        final isLast = _currentSection >= sections.length - 1;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textPrimary,
                        tooltip: 'Back',
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              chapter.title,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${_currentSection + 1} of ${sections.length}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: sections.isNotEmpty
                          ? (_currentSection + 1) / sections.length
                          : 0,
                      minHeight: 4,
                      backgroundColor: AppColors.progressBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.red,
                      ),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: section != null
                      ? _SectionContent(
                          key: ValueKey(section.id),
                          section: section,
                        )
                      : const Center(child: Text('No content')),
                ),
                // Bottom nav
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentSection > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _currentSection--),
                            child: const Text('Previous'),
                          ),
                        ),
                      if (_currentSection > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLast) {
                              ref
                                  .read(progressProvider.notifier)
                                  .completeLesson(widget.chapterId);
                              _showCompletionDialog(context, chapter);
                            } else {
                              setState(() => _currentSection++);
                            }
                          },
                          child: Text(isLast ? 'Complete' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: ErrorView(
          onRetry: () => ref.invalidate(chaptersProvider),
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, Chapter chapter) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 36,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 20),
              Text(
                'Lesson Complete!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You finished "${chapter.title}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+10 XP',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.pop();
                      },
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.pop();
                        context.push(
                          '/quiz/${widget.chapterId}',
                        );
                      },
                      child: const Text('Take Quiz'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  final Section section;
  const _SectionContent({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        Text(
          section.title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        if (section.content.isNotEmpty)
          Text(
            section.content,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
        const SizedBox(height: 16),
        // Render the actual course material from the data source
        if (section.dataSource != null) ...[
          DataSourceContent(
            dataSource: section.dataSource!,
            sectionId: section.id,
          ),
          const SizedBox(height: 16),
        ],
        ...section.blocks.asMap().entries.map((entry) {
          final i = entry.key;
          final block = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBlock(block),
          ).animate().fadeIn(delay: (150 + i * 80).ms, duration: 350.ms);
        }),
      ],
    );
  }

  Widget _buildBlock(ContentBlock block) {
    switch (block.type) {
      case 'tip':
        return _TipBlock(block: block);
      case 'rule':
        return _RuleBlock(block: block);
      case 'table':
        return _TableBlock(block: block);
      case 'example':
        return _ExampleBlock(block: block);
      default:
        return _TextBlock(block: block);
    }
  }
}

class _TipBlock extends StatelessWidget {
  final ContentBlock block;
  const _TipBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return FrenchCard(
      margin: EdgeInsets.zero,
      color: AppColors.gold.withValues(alpha: 0.08),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                block.title ?? 'Tip',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
          if (block.body != null) ...[
            const SizedBox(height: 8),
            Text(
              block.body!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
          if (block.bulletPoints != null)
            ...block.bulletPoints!.map(
              (bp) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('  \u2022  ',
                        style: TextStyle(color: AppColors.goldDark)),
                    Expanded(
                      child: Text(
                        bp,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RuleBlock extends StatelessWidget {
  final ContentBlock block;
  const _RuleBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return FrenchCard(
      margin: EdgeInsets.zero,
      color: AppColors.red.withValues(alpha: 0.05),
      border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule_rounded,
                  color: AppColors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.title ?? 'Rule',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          if (block.body != null) ...[
            const SizedBox(height: 8),
            Text(
              block.body!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableBlock extends StatelessWidget {
  final ContentBlock block;
  const _TableBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final headers = block.tableHeaders ?? [];
    final rows = block.tableRows ?? [];

    return FrenchCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                block.title!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(AppColors.navy.withValues(alpha: 0.05)),
              columnSpacing: 20,
              horizontalMargin: 16,
              headingTextStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
              dataTextStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              columns: headers
                  .map((h) => DataColumn(label: Text(h)))
                  .toList(),
              rows: rows.map((row) {
                return DataRow(
                  cells: headers
                      .map((h) =>
                          DataCell(Text(row[h] ?? '')))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final ContentBlock block;
  const _ExampleBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return FrenchCard(
      margin: EdgeInsets.zero,
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null) ...[
            Text(
              block.title!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (block.body != null)
            Text(
              block.body!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          if (block.bulletPoints != null)
            ...block.bulletPoints!.map(
              (bp) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '  \u2022  $bp',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final ContentBlock block;
  const _TextBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block.title != null) ...[
          Text(
            block.title!,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        if (block.body != null)
          Text(
            block.body!,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
      ],
    );
  }
}
