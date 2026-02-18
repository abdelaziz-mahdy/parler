import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/adaptive_colors.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/responsive.dart';
import '../../database/app_database.dart';
import '../../models/vocabulary_word.dart';
import '../../providers/data_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/fsrs.dart';
import '../../services/session_engine.dart';
import '../../services/tts_service.dart';
import '../../widgets/matching_card.dart';
import '../../widgets/quiz_card.dart';
import '../../widgets/speaker_button.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  DailySession? _session;
  bool _loading = true;

  // Current step tracking
  int _phase = 1; // 1, 2, or 3
  int _stepInPhase = 0;
  bool _showingNewWordTeach = true; // For phase 2: teach then quiz
  bool _showingMatching = false;
  int _completedSteps = 0;

  // Stats
  int _correctCount = 0;
  int _reviewedCount = 0;
  int _newWordsCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildSession());
  }

  SessionLength _getSessionLength() {
    final prefs = ref.read(sharedPreferencesProvider);
    final value = prefs.getString('session_length') ?? 'regular';
    return SessionLength.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionLength.regular,
    );
  }

  Future<void> _buildSession() async {
    final vocabAsync = ref.read(vocabularyProvider);
    final allWords = vocabAsync.when(
      data: (words) => words,
      loading: () => <VocabularyWord>[],
      error: (_, _) => <VocabularyWord>[],
    );

    if (allWords.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final dueCardsAsync = ref.read(dueCardsProvider);
    final dueCardStates = dueCardsAsync.when(
      data: (cards) => cards,
      loading: () => <dynamic>[],
      error: (_, _) => <dynamic>[],
    );

    // Map Drift CardState rows to FsrsCardState + VocabularyWord pairs
    final dueEntries = <MapEntry<FsrsCardState, VocabularyWord>>[];
    for (final cardState in dueCardStates) {
      final fsrsCard = FsrsCardState(
        cardId: cardState.cardId,
        stability: cardState.stability,
        difficulty: cardState.difficulty,
        lastReview: cardState.lastReview,
        nextReview: cardState.nextReview,
        reps: cardState.reps,
        lapses: cardState.lapses,
        state: _parseFsrsState(cardState.state),
      );
      final word = allWords.where((w) => w.id == cardState.cardId).firstOrNull;
      if (word != null) {
        dueEntries.add(MapEntry(fsrsCard, word));
      }
    }

    // Find new words (not yet in card state database)
    final cardStateDao = ref.read(cardStateDaoProvider);
    final allCardStates = await cardStateDao.allCards();
    final studiedIds = allCardStates.map((c) => c.cardId).toSet();
    final newWords = allWords.where((w) => !studiedIds.contains(w.id)).toList();

    // Load bonus content (phrases, verbs, false friends) for Phase 3 variety
    final bonusContent = <VocabularyWord>[];
    final phrasesAsync = ref.read(phrasesProvider);
    if (phrasesAsync case AsyncData(:final value)) {
      bonusContent.addAll(value.map(phraseToVocab));
    }
    final verbsAsync = ref.read(essentialVerbsProvider);
    if (verbsAsync case AsyncData(:final value)) {
      bonusContent.addAll(value.map(verbToVocab));
    }
    final ffAsync = ref.read(falseFriendsProvider);
    if (ffAsync case AsyncData(:final value)) {
      bonusContent.addAll(value.map(falseFriendToVocab));
    }

    final engine = SessionEngine(fsrs: ref.read(fsrsProvider));
    final session = engine.build(
      dueCards: dueEntries,
      newWords: newWords,
      allWords: allWords,
      settings: _getSessionLength(),
      currentChapterId: 1,
      bonusContent: bonusContent,
    );

    setState(() {
      _session = session;
      _loading = false;
      _phase = session.phase1Review.isNotEmpty
          ? 1
          : session.phase2NewWords.isNotEmpty
              ? 2
              : 3;
      _stepInPhase = 0;
      _showingNewWordTeach = true;
    });
  }

  FsrsState _parseFsrsState(String state) {
    switch (state) {
      case 'learning':
        return FsrsState.learning;
      case 'review':
        return FsrsState.review;
      case 'relearning':
        return FsrsState.relearning;
      default:
        return FsrsState.newCard;
    }
  }

  String _fsrsStateToString(FsrsState state) {
    switch (state) {
      case FsrsState.newCard:
        return 'new';
      case FsrsState.learning:
        return 'learning';
      case FsrsState.review:
        return 'review';
      case FsrsState.relearning:
        return 'relearning';
    }
  }

  int get _totalSteps {
    if (_session == null) return 0;
    return _session!.totalItems;
  }

  String get _phaseLabel {
    if (_showingMatching) return 'Matching';
    switch (_phase) {
      case 1:
        return 'Review';
      case 2:
        return _showingNewWordTeach ? 'New Words' : 'Practice';
      case 3:
        return 'Mixed Practice';
      default:
        return '';
    }
  }

  Future<void> _onQuizAnswer(
      bool isCorrect, int responseTimeMs, VocabularyWord word) async {
    if (isCorrect) _correctCount++;
    _reviewedCount++;

    final fsrs = ref.read(fsrsProvider);
    final cardStateDao = ref.read(cardStateDaoProvider);
    final reviewLogDao = ref.read(reviewLogDaoProvider);

    // Get current card state or create new
    final existingCard = await cardStateDao.getCard(word.id);
    final currentFsrs = existingCard != null
        ? FsrsCardState(
            cardId: existingCard.cardId,
            stability: existingCard.stability,
            difficulty: existingCard.difficulty,
            lastReview: existingCard.lastReview,
            nextReview: existingCard.nextReview,
            reps: existingCard.reps,
            lapses: existingCard.lapses,
            state: _parseFsrsState(existingCard.state),
          )
        : FsrsCardState(cardId: word.id);

    final rating = isCorrect ? FsrsRating.good : FsrsRating.again;
    final now = DateTime.now();
    final schedule = fsrs.review(currentFsrs, rating, now: now);

    // Write updated card state
    await cardStateDao.upsertCard(CardStatesCompanion(
      cardId: drift.Value(word.id),
      stability: drift.Value(schedule.stability),
      difficulty: drift.Value(schedule.difficulty),
      lastReview: drift.Value(now),
      nextReview: drift.Value(schedule.nextReview),
      reps: drift.Value(schedule.reps),
      lapses: drift.Value(schedule.lapses),
      state: drift.Value(_fsrsStateToString(schedule.state)),
    ));

    // Write review log
    final elapsed = currentFsrs.lastReview != null
        ? now.difference(currentFsrs.lastReview!).inHours / 24.0
        : 0.0;
    await reviewLogDao.insert(ReviewLogsCompanion(
      cardId: drift.Value(word.id),
      timestamp: drift.Value(now),
      rating: drift.Value(rating.value),
      elapsedDays: drift.Value(elapsed),
      responseTimeMs: drift.Value(responseTimeMs),
      stability: drift.Value(schedule.stability),
      difficulty: drift.Value(schedule.difficulty),
    ));

    _advanceStep();
  }

  void _onNewWordDone() {
    _newWordsCount++;
    _completedSteps++;
    setState(() {
      if (_stepInPhase < _session!.phase2NewWords.length - 1) {
        _stepInPhase++;
        _showingNewWordTeach = true;
      } else {
        // Move to mini-quiz
        _stepInPhase = 0;
        _showingNewWordTeach = false;
      }
    });
  }

  void _advanceStep() {
    _completedSteps++;

    setState(() {
      final session = _session!;

      if (_phase == 1) {
        if (_stepInPhase < session.phase1Review.length - 1) {
          _stepInPhase++;
        } else if (session.phase2NewWords.isNotEmpty) {
          _phase = 2;
          _stepInPhase = 0;
          _showingNewWordTeach = true;
        } else if (session.phase3Mixed.isNotEmpty) {
          _phase = 3;
          _stepInPhase = 0;
        } else if (session.matchingChallenge != null) {
          _showingMatching = true;
        } else {
          _navigateToComplete();
        }
      } else if (_phase == 2 && !_showingNewWordTeach) {
        // Mini-quiz phase
        if (_stepInPhase < session.phase2MiniQuiz.length - 1) {
          _stepInPhase++;
        } else if (session.phase3Mixed.isNotEmpty) {
          _phase = 3;
          _stepInPhase = 0;
        } else if (session.matchingChallenge != null) {
          _showingMatching = true;
        } else {
          _navigateToComplete();
        }
      } else if (_phase == 3) {
        if (_stepInPhase < session.phase3Mixed.length - 1) {
          _stepInPhase++;
        } else if (session.matchingChallenge != null) {
          _showingMatching = true;
        } else {
          _navigateToComplete();
        }
      }
    });
  }

  void _navigateToComplete() {
    context.pushReplacement(
      '/session/complete',
      extra: {
        'reviewed': _reviewedCount,
        'newWords': _newWordsCount,
        'correct': _correctCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 16),
              Text(
                'Building your session...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_session == null || _session!.isEmpty) {
      return _buildEmptyState(context);
    }

    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: ContentConstraint(
          maxWidth: 800,
          child: Column(
            children: [
              _buildProgressBar(context),
              Expanded(child: _buildCurrentStep(context, tts)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = _totalSteps > 0 ? _completedSteps / _totalSteps : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _confirmExit(context),
            icon: const Icon(Icons.close_rounded),
            color: context.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _phaseLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: context.progressBgColor,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.navyAdaptive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_completedSteps/$_totalSteps',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.navyAdaptive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, TtsService tts) {
    final session = _session!;

    if (_phase == 1) {
      final question = session.phase1Review[_stepInPhase];
      return QuizCard(
        key: ValueKey('p1_${_stepInPhase}_${question.word.id}'),
        question: question,
        ttsService: tts,
        onComplete: (correct, time) =>
            _onQuizAnswer(correct, time, question.word),
      );
    }

    if (_phase == 2 && _showingNewWordTeach) {
      final word = session.phase2NewWords[_stepInPhase];
      return _buildTeachCard(context, word, tts);
    }

    if (_phase == 2 && !_showingNewWordTeach) {
      final question = session.phase2MiniQuiz[_stepInPhase];
      return QuizCard(
        key: ValueKey('p2q_${_stepInPhase}_${question.word.id}'),
        question: question,
        ttsService: tts,
        onComplete: (correct, time) =>
            _onQuizAnswer(correct, time, question.word),
      );
    }

    if (_showingMatching && session.matchingChallenge != null) {
      return MatchingCard(
        key: const ValueKey('matching'),
        challenge: session.matchingChallenge!,
        tts: tts,
        onComplete: (wrongAttempts) {
          _completedSteps++;
          _navigateToComplete();
        },
      );
    }

    // Phase 3
    final question = session.phase3Mixed[_stepInPhase];
    return QuizCard(
      key: ValueKey('p3_${_stepInPhase}_${question.word.id}'),
      question: question,
      ttsService: tts,
      onComplete: (correct, time) =>
          _onQuizAnswer(correct, time, question.word),
    );
  }

  Widget _buildTeachCard(
      BuildContext context, VocabularyWord word, TtsService tts) {
    // Auto-play TTS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tts.speakAuto(word.french);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'NEW WORD',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.info,
                letterSpacing: 1,
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: 24),
          Text(
            word.frenchWithArticle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
          const SizedBox(height: 8),
          Text(
            word.phonetic,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SpeakerButton(text: word.french, size: 28, color: AppColors.gold),
          const SizedBox(height: 24),
          Divider(color: context.dividerColor),
          const SizedBox(height: 24),
          Text(
            word.english,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          const SizedBox(height: 16),
          // Part of speech tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.navyAdaptive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              word.partOfSpeech,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.navyAdaptive,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Example
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.creamColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 18, color: AppColors.gold),
                    const SizedBox(width: 6),
                    Text(
                      'Example',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.exampleFr,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: context.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SpeakerButton(
                        text: word.exampleFr, size: 18, color: AppColors.gold),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  word.exampleEn,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onNewWordDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Got it',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 64, color: context.textLight),
              const SizedBox(height: 16),
              Text(
                'Nothing to study today',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No cards are due and no new words available.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.textLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    if (_completedSteps == 0) {
      context.pop();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text(
          'Your progress has been saved, but you have not finished '
          'all cards in this session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (leave == true && context.mounted) {
      context.pop();
    }
  }
}
