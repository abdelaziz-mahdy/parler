import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/adaptive_colors.dart';
import '../core/constants/app_colors.dart';
import '../models/models.dart';
import '../providers/data_provider.dart';
import 'french_card.dart';

/// Renders the actual course material for a lesson section based on its dataSource.
/// Parses the dataSource string (e.g. "pronunciation.json:vowelSounds") and
/// loads + renders the corresponding data from JSON via Riverpod providers.
class DataSourceContent extends ConsumerWidget {
  final String dataSource;
  final String sectionId;

  const DataSourceContent({
    super.key,
    required this.dataSource,
    required this.sectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colonIdx = dataSource.indexOf(':');
    final file = colonIdx >= 0 ? dataSource.substring(0, colonIdx) : dataSource;
    final key = colonIdx >= 0 ? dataSource.substring(colonIdx + 1) : null;

    switch (file) {
      case 'suffix_patterns.json':
        return _wrap(ref.watch(suffixPatternsProvider), _suffixView);
      case 'pronunciation.json':
        return _pronunciationView(ref, key!);
      case 'gender_rules.json':
        return _genderView(ref, key!);
      case 'verbs.json':
        return _verbsView(ref, key!);
      case 'grammar.json':
        return _grammarView(context, ref, key!);
      case 'numbers.json':
        return _wrap(ref.watch(numbersProvider),
            (numbers) => _numbersView(context, numbers));
      case 'false_friends.json':
        return _wrap(ref.watch(falseFriendsProvider),
            (friends) => _falseFriendsView(context, friends));
      case 'liaison_rules.json':
        return _wrap(ref.watch(liaisonRulesProvider),
            (rules) => _liaisonView(context, rules, key!));
      case 'phrases.json':
        return _wrap(ref.watch(phrasesProvider),
            (phrases) => _phrasesView(context, phrases, key!));
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Async helper ───────────────────────────────────────────
  Widget _wrap<T>(AsyncValue<T> value, Widget Function(T) builder) {
    return value.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child:
              SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: builder,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SUFFIX PATTERNS
  // ═══════════════════════════════════════════════════════════════
  Widget _suffixView(List<SuffixPattern> patterns) {
    return Column(
      children: [
        for (final p in patterns) _suffixCard(p),
      ],
    );
  }

  Widget _suffixCard(SuffixPattern p) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FrenchCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _badge(p.englishEnding, AppColors.navy),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward_rounded,
                        size: 16, color: context.textLight),
                  ),
                  _badge(p.frenchEnding, AppColors.red),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: p.examples.map(_exampleChip).toList(),
              ),
              const SizedBox(height: 6),
              Text(p.notes,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  PRONUNCIATION
  // ═══════════════════════════════════════════════════════════════
  Widget _pronunciationView(WidgetRef ref, String key) {
    switch (key) {
      case 'goldenRules':
        return _wrap(ref.watch(goldenRulesProvider), (rules) {
          return Column(
            children: [
              for (int i = 0; i < rules.length; i++)
                _goldenRuleCard(i + 1, rules[i]),
            ],
          );
        });
      case 'vowelSounds':
        return _wrap(ref.watch(vowelSoundsProvider), (sounds) {
          return Column(
              children: sounds.map(_vowelSoundCard).toList());
        });
      case 'nasalVowels':
        return _wrap(ref.watch(nasalVowelsProvider), (vowels) {
          return Column(
              children: vowels.map(_nasalVowelCard).toList());
        });
      case 'consonantRules':
        return _wrap(ref.watch(consonantRulesProvider), (rules) {
          return Column(
              children: rules.map(_consonantRuleCard).toList());
        });
      case 'carefulRule':
        return _wrap(ref.watch(carefulRulesProvider), (rules) {
          return Column(children: [
            _sectionLabel(
                'These final consonants ARE pronounced:'),
            ...rules.map(_carefulRuleCard),
          ]);
        });
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _goldenRuleCard(int num, String rule) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FrenchCard(
          margin: EdgeInsets.zero,
          color: AppColors.navy.withValues(alpha: 0.04),
          border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: AppColors.navy, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('$num',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(rule,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: context.textPrimary,
                        height: 1.5)),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _vowelSoundCard(VowelSound s) {
    return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FrenchCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _badge(s.letters, AppColors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(s.sound,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: s.examples
                  .map((e) => _exampleChip(e))
                  .toList(),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(s.hint,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.goldDark,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    });
  }

  Widget _nasalVowelCard(NasalVowel v) {
    return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FrenchCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _badge(v.spelling, AppColors.navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(v.sound,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: v.examples.map(_exampleChip).toList(),
            ),
            const SizedBox(height: 6),
            Text(v.howToSay,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.textSecondary,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
    });
  }

  Widget _consonantRuleCard(ConsonantRule r) {
    return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FrenchCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _badge(r.letter, AppColors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(r.rule,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: context.textPrimary,
                          height: 1.4)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: r.examples.map(_exampleChip).toList(),
            ),
            if (r.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(r.notes,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
    });
  }

  Widget _carefulRuleCard(CarefulRule r) {
    return Builder(builder: (context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FrenchCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        color: AppColors.red.withValues(alpha: 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badge(r.letter, AppColors.red),
            const SizedBox(height: 8),
            ...r.examples
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('  \u2022  $e',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: context.textPrimary)),
                    )),
          ],
        ),
      ),
    );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  GENDER RULES
  // ═══════════════════════════════════════════════════════════════
  Widget _genderView(WidgetRef ref, String key) {
    final isFeminine = key == 'feminine';
    final provider =
        isFeminine ? feminineRulesProvider : masculineRulesProvider;
    final color = isFeminine ? AppColors.red : AppColors.navy;

    return _wrap(ref.watch(provider), (rules) {
      return Column(
        children: rules
            .map((r) => _genderRuleCard(r, color))
            .toList(),
      );
    });
  }

  Widget _genderRuleCard(GenderRule r, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FrenchCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        border:
            Border.all(color: accent.withValues(alpha: 0.2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _badge(r.ending, accent),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(r.accuracy,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: r.examples.map(_exampleChip).toList(),
            ),
            if (r.exceptions != null) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(r.exceptions!,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.warning)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  VERBS
  // ═══════════════════════════════════════════════════════════════
  Widget _verbsView(WidgetRef ref, String key) {
    switch (key) {
      case 'essentialVerbs':
        return _wrap(ref.watch(essentialVerbsProvider), _essentialVerbsView);
      case 'erConjugationPattern':
        return _wrap(ref.watch(erConjugationProvider), _conjugationView);
      case 'futureTenseExamples':
        return _wrap(ref.watch(futureTenseProvider), _frenchEnglishPairsView);
      case 'vandertrampVerbs':
        return _wrap(
            ref.watch(vandertrampVerbsProvider), _vandertrampView);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _essentialVerbsView(List<Verb> verbs) {
    return Builder(builder: (context) => Column(
      children: verbs.map((v) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.infinitive,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy)),
                      Text(v.meaning,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: context.textSecondary)),
                    ],
                  ),
                ),
                _badge(v.group, v.group == 'er'
                    ? AppColors.success
                    : v.group == 'irregular'
                        ? AppColors.red
                        : AppColors.navy),
                if (v.pastParticiple != null) ...[
                  const SizedBox(width: 8),
                  Text(v.pastParticiple!,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: context.textLight)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _conjugationView(List<VerbConjugationPattern> patterns) {
    return Builder(builder: (context) => FrenchCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Subject',
                        style: _tableHeader())),
                Expanded(
                    flex: 2,
                    child:
                        Text('Ending', style: _tableHeader())),
                Expanded(
                    flex: 3,
                    child:
                        Text('Sound', style: _tableHeader())),
              ],
            ),
          ),
          ...patterns.map((p) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: context.dividerColor,
                          width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(p.subject,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy))),
                    Expanded(
                        flex: 2,
                        child: Text(p.ending,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.red,
                                fontWeight: FontWeight.w600))),
                    Expanded(
                        flex: 3,
                        child: Text(p.sound,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: context.textSecondary))),
                  ],
                ),
              )),
        ],
      ),
    ));
  }

  Widget _vandertrampView(List<VandertrampVerb> verbs) {
    return Builder(builder: (context) => FrenchCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Verb', style: _tableHeader())),
                Expanded(
                    flex: 3,
                    child:
                        Text('Meaning', style: _tableHeader())),
                Expanded(
                    flex: 3,
                    child: Text('Past Participle',
                        style: _tableHeader())),
              ],
            ),
          ),
          ...verbs.map((v) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: context.dividerColor,
                          width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(v.verb,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy))),
                    Expanded(
                        flex: 3,
                        child: Text(v.meaning,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: context.textSecondary))),
                    Expanded(
                        flex: 3,
                        child: Text(v.pastParticiple,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.red,
                                fontWeight: FontWeight.w500))),
                  ],
                ),
              )),
        ],
      ),
    ));
  }

  Widget _frenchEnglishPairsView(List<Map<String, dynamic>> pairs) {
    return Builder(builder: (context) => Column(
      children: pairs.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(p['french'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p['english'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: context.textSecondary)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  // ═══════════════════════════════════════════════════════════════
  //  GRAMMAR
  // ═══════════════════════════════════════════════════════════════
  Widget _grammarView(BuildContext context, WidgetRef ref, String key) {
    switch (key) {
      case 'negation':
        return _wrap(ref.watch(negationProvider), _negationView);
      case 'questionMethods':
        return _wrap(
            ref.watch(questionMethodsProvider), _questionMethodsView);
      case 'questionWords':
        return _wrap(
            ref.watch(questionWordsProvider), _questionWordsView);
      case 'articles':
        return _wrap(ref.watch(articlesProvider),
            (articles) => _articlesView(context, articles));
      case 'contractions':
        return _wrap(ref.watch(contractionsProvider),
            (contractions) => _contractionsView(context, contractions));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _negationView(Map<String, dynamic> data) {
    final rule = data['rule'] as String;
    final examples = data['examples'] as List<dynamic>;
    final shortcut = data['spokenShortcut'] as String;

    return Builder(builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrenchCard(
          margin: EdgeInsets.zero,
          color: AppColors.navy.withValues(alpha: 0.04),
          border:
              Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
          child: Row(
            children: [
              const Icon(Icons.rule_rounded,
                  color: AppColors.navy, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(rule,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...examples.map((ex) {
          final e = ex as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FrenchCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e['positive'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: context.textLight,
                          decoration: TextDecoration.lineThrough)),
                  const SizedBox(height: 4),
                  Text(e['negative'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy)),
                  Text(e['english'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.textSecondary)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        FrenchCard(
          margin: EdgeInsets.zero,
          color: AppColors.gold.withValues(alpha: 0.08),
          border:
              Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.goldDark, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(shortcut,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.textPrimary,
                        height: 1.4)),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _questionMethodsView(List<Map<String, dynamic>> methods) {
    const levelColors = {
      'easiest/casual': AppColors.success,
      'medium': AppColors.warning,
      'formal': AppColors.red,
    };

    return Builder(builder: (context) => Column(
      children: methods.map((m) {
        final level = m['level'] as String;
        final color = levelColors[level] ?? AppColors.navy;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badge(m['method'] as String, color),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(level,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(m['example'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy)),
                Text(m['english'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.textSecondary)),
                if (m['notes'] != null) ...[
                  const SizedBox(height: 4),
                  Text(m['notes'] as String,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.textLight,
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _questionWordsView(List<QuestionWord> words) {
    return Builder(builder: (context) => Column(
      children: words.map((w) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(w.french,
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                    const SizedBox(width: 8),
                    Text('[${w.pronunciation}]',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: context.textLight,
                            fontStyle: FontStyle.italic)),
                    const Spacer(),
                    Text(w.english,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: context.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(w.example,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.red,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  Widget _articlesView(BuildContext context, List<Article> articles) {
    return FrenchCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Type', style: _tableHeader())),
                Expanded(
                    flex: 3,
                    child: Text('Masculine', style: _tableHeader())),
                Expanded(
                    flex: 3,
                    child: Text('Feminine', style: _tableHeader())),
                Expanded(
                    flex: 3,
                    child: Text('Plural', style: _tableHeader())),
              ],
            ),
          ),
          ...articles.map((a) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: context.dividerColor, width: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(a.type,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.textLight))),
                        Expanded(
                            flex: 3,
                            child: Text(a.masculine,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.navy))),
                        Expanded(
                            flex: 3,
                            child: Text(a.feminine,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.red))),
                        Expanded(
                            flex: 3,
                            child: Text(a.plural,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: context.textPrimary))),
                      ],
                    ),
                    if (a.beforeVowel != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Expanded(flex: 2, child: SizedBox()),
                          Expanded(
                            flex: 9,
                            child: Text(
                                'Before vowel: ${a.beforeVowel}',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.goldDark,
                                    fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _contractionsView(BuildContext context, List<Contraction> contractions) {
    return Column(
      children: contractions.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.combination,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: context.textLight,
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        size: 14, color: context.textLight),
                    const SizedBox(width: 8),
                    Text(c.contraction,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.red)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.example,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.navy)),
                Text(c.notes,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: context.textSecondary,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  NUMBERS
  // ═══════════════════════════════════════════════════════════════
  Widget _numbersView(BuildContext context, List<NumberItem> numbers) {
    // Filter based on section: 6.1 = 0-69, 6.2 = 70+
    final filtered = sectionId == '6.1'
        ? numbers.where((n) => n.value <= 69).toList()
        : sectionId == '6.2'
            ? numbers.where((n) => n.value >= 70).toList()
            : numbers;

    return FrenchCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const SizedBox(
                    width: 40,
                    child: Text('#',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy))),
                Expanded(
                    flex: 3,
                    child: Text('French', style: _tableHeader())),
                if (filtered.any((n) => n.formula != null))
                  Expanded(
                      flex: 3,
                      child:
                          Text('Formula', style: _tableHeader())),
              ],
            ),
          ),
          ...filtered.map((n) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: context.dividerColor, width: 0.5)),
                  color: n.formula != null
                      ? AppColors.gold.withValues(alpha: 0.04)
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text('${n.value}',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(n.french,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              color: context.textPrimary)),
                    ),
                    if (filtered.any((n) => n.formula != null))
                      Expanded(
                        flex: 3,
                        child: Text(n.formula ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: context.textLight,
                                fontStyle: FontStyle.italic)),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  FALSE FRIENDS
  // ═══════════════════════════════════════════════════════════════
  Widget _falseFriendsView(BuildContext context, List<FalseFriend> friends) {
    return Column(
      children: friends.map((f) {
        final dangerColor = _dangerColor(f.dangerLevel);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(14),
            border: Border.all(
                color: dangerColor.withValues(alpha: 0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: dangerColor),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: dangerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(f.dangerLevel,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: dangerColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: f.frenchWord,
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy)),
                      TextSpan(
                          text: '  \u2260  ',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.red)),
                      TextSpan(
                          text: f.looksLike,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: context.textLight,
                              decoration:
                                  TextDecoration.lineThrough)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Actually means: ${f.actualMeaning}',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(f.correctEnglish,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _dangerColor(String level) {
    switch (level) {
      case 'VERY HIGH':
        return AppColors.redDark;
      case 'HIGH':
        return AppColors.red;
      case 'MEDIUM':
        return AppColors.warning;
      case 'FUNNY':
        return AppColors.gold;
      default:
        return AppColors.info;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  LIAISON RULES
  // ═══════════════════════════════════════════════════════════════
  Widget _liaisonView(BuildContext context, List<LiaisonRule> rules, String key) {
    final filtered = rules.where((r) => r.type == key).toList();
    return Column(
      children: filtered.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.description,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy)),
                const SizedBox(height: 8),
                ...r.examples.map((ex) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(ex.written,
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: context.textPrimary)),
                          ),
                          Icon(Icons.volume_up_rounded,
                              size: 14, color: context.textLight),
                          const SizedBox(width: 4),
                          Text(ex.pronunciation,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.red,
                                  fontStyle: FontStyle.italic)),
                          if (ex.rule != null) ...[
                            const SizedBox(width: 8),
                            _badge(ex.rule!, AppColors.gold),
                          ],
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PHRASES
  // ═══════════════════════════════════════════════════════════════
  Widget _phrasesView(BuildContext context, List<Phrase> allPhrases, String category) {
    final phrases =
        allPhrases.where((p) => p.category == category).toList();
    return Column(
      children: phrases.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FrenchCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.french,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(p.english,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.textSecondary)),
                if (p.usage != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 13, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(p.usage!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.goldDark,
                                fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════
  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }

  Widget _exampleChip(String text) {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: context.creamColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 12, color: context.textPrimary)),
      );
    });
  }

  Widget _sectionLabel(String text) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textSecondary)),
      );
    });
  }

  TextStyle _tableHeader() {
    return GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.navy);
  }
}
