import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/phrase.dart';
import '../../providers/data_provider.dart';
import '../../widgets/french_card.dart';
import '../../widgets/error_view.dart';

class WordBankScreen extends ConsumerStatefulWidget {
  const WordBankScreen({super.key});

  @override
  ConsumerState<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends ConsumerState<WordBankScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word Bank',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patterns, phrases & false friends',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search words...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textLight),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.red,
              unselectedLabelColor: AppColors.textLight,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              indicatorColor: AppColors.red,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Patterns'),
                Tab(text: 'Phrases'),
                Tab(text: 'False Friends'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PatternsTab(searchQuery: _searchQuery),
                  _PhrasesTab(searchQuery: _searchQuery),
                  _FalseFriendsTab(searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternsTab extends ConsumerWidget {
  final String searchQuery;
  const _PatternsTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternsAsync = ref.watch(suffixPatternsProvider);

    return patternsAsync.when(
      data: (patterns) {
        final filtered = searchQuery.isEmpty
            ? patterns
            : patterns
                .where((p) =>
                    p.englishEnding
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    p.frenchEnding
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    p.examples.any((e) =>
                        e.toLowerCase().contains(searchQuery.toLowerCase())))
                .toList();

        if (filtered.isEmpty) {
          return _EmptySearchResult(query: searchQuery);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final p = filtered[index];
            return FrenchCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.englishEnding,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 16, color: AppColors.textLight),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.frenchEnding,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: p.examples
                        .map((ex) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ex,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.notes,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (50 * index).ms, duration: 300.ms);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        onRetry: () => ref.invalidate(suffixPatternsProvider),
      ),
    );
  }
}

class _PhrasesTab extends ConsumerWidget {
  final String searchQuery;
  const _PhrasesTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrasesAsync = ref.watch(phrasesProvider);

    return phrasesAsync.when(
      data: (phrases) {
        final filtered = searchQuery.isEmpty
            ? phrases
            : phrases
                .where((p) =>
                    p.french
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    p.english
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return _EmptySearchResult(query: searchQuery);
        }

        final grouped = <String, List<Phrase>>{};
        for (final p in filtered) {
          grouped.putIfAbsent(p.category, () => []).add(p);
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    _categoryLabel(entry.key),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                ...entry.value.map((phrase) => FrenchCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phrase.french,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phrase.english,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (phrase.usage != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              phrase.usage!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        onRetry: () => ref.invalidate(phrasesProvider),
      ),
    );
  }

  String _categoryLabel(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ')
        .toUpperCase();
  }
}

class _FalseFriendsTab extends ConsumerWidget {
  final String searchQuery;
  const _FalseFriendsTab({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ffAsync = ref.watch(falseFriendsProvider);

    return ffAsync.when(
      data: (falseFriends) {
        final filtered = searchQuery.isEmpty
            ? falseFriends
            : falseFriends
                .where((f) =>
                    f.frenchWord
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    f.looksLike
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    f.actualMeaning
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return _EmptySearchResult(query: searchQuery);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final f = filtered[index];
            return FrenchCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          f.frenchWord,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _dangerColor(f.dangerLevel)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          f.dangerLevel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _dangerColor(f.dangerLevel),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.close_rounded,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'Looks like: ${f.looksLike}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Actually means: ${f.actualMeaning}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use "${f.correctEnglish}" in English',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (50 * index).ms, duration: 300.ms);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        onRetry: () => ref.invalidate(falseFriendsProvider),
      ),
    );
  }

  Color _dangerColor(String level) {
    switch (level) {
      case 'VERY HIGH':
        return AppColors.error;
      case 'HIGH':
        return AppColors.red;
      case 'MEDIUM':
        return AppColors.warning;
      case 'FUNNY':
        return AppColors.info;
      default:
        return AppColors.textLight;
    }
  }
}

class _EmptySearchResult extends StatelessWidget {
  final String query;
  const _EmptySearchResult({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 48, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'No items yet'
                  : 'No results for "$query"',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
