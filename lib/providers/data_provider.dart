import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/data_repository.dart';
import '../services/tts_service.dart';

// --- DataRepository singleton ---
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  ref.keepAlive();
  return DataRepository();
});

// --- Chapters ---
final chaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getChapters();
});

// --- Lessons ---
final lessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getLessons();
});

// --- Quiz Questions ---
final quizQuestionsProvider = FutureProvider<List<QuizQuestion>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getQuizQuestions();
});

final chapterQuestionsProvider =
    Provider.family<List<QuizQuestion>, int>((ref, chapterId) {
  final questionsAsync = ref.watch(quizQuestionsProvider);
  return questionsAsync.when(
    data: (questions) =>
        questions.where((q) => q.chapterId == chapterId).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

// --- Suffix Patterns ---
final suffixPatternsProvider =
    FutureProvider<List<SuffixPattern>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getSuffixPatterns();
});

// --- Pronunciation Data ---
final vowelSoundsProvider = FutureProvider<List<VowelSound>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getVowelSounds();
});

final nasalVowelsProvider = FutureProvider<List<NasalVowel>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getNasalVowels();
});

final consonantRulesProvider =
    FutureProvider<List<ConsonantRule>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getConsonantRules();
});

// --- Gender Rules ---
final feminineRulesProvider =
    FutureProvider<List<GenderRule>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getFeminineRules();
});

final masculineRulesProvider =
    FutureProvider<List<GenderRule>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getMasculineRules();
});

// --- Verbs ---
final essentialVerbsProvider = FutureProvider<List<Verb>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getEssentialVerbs();
});

final vandertrampVerbsProvider =
    FutureProvider<List<VandertrampVerb>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getVandertrampVerbs();
});

// --- Grammar ---
final questionWordsProvider =
    FutureProvider<List<QuestionWord>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getQuestionWords();
});

final contractionsProvider =
    FutureProvider<List<Contraction>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getContractions();
});

// --- Numbers ---
final numbersProvider = FutureProvider<List<NumberItem>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getNumbers();
});

// --- False Friends ---
final falseFriendsProvider =
    FutureProvider<List<FalseFriend>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getFalseFriends();
});

// --- Liaison Rules ---
final liaisonRulesProvider =
    FutureProvider<List<LiaisonRule>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getLiaisonRules();
});

// --- CarefulRule ---
final carefulRulesProvider = FutureProvider<List<CarefulRule>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getCarefulRules();
});

// --- Golden Rules ---
final goldenRulesProvider = FutureProvider<List<String>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getGoldenRules();
});

// --- Grammar: Negation ---
final negationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getNegation();
});

// --- Grammar: Question Methods ---
final questionMethodsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getQuestionMethods();
});

// --- Grammar: Articles ---
final articlesProvider = FutureProvider<List<Article>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getArticles();
});

// --- Verb: -er Conjugation Pattern ---
final erConjugationProvider =
    FutureProvider<List<VerbConjugationPattern>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getErConjugationPattern();
});

// --- Verb: Future Tense Examples ---
final futureTenseProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getFutureTenseExamples();
});

// --- Verb: Past Tense Examples ---
final pastTenseProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getPastTenseExamples();
});

// --- Verb: Past Participle Rules ---
final pastParticipleRulesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getPastParticipleRules();
});

// --- Phrases ---
final phrasesProvider = FutureProvider<List<Phrase>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getPhrases();
});

final phrasesByCategoryProvider =
    Provider.family<List<Phrase>, String>((ref, category) {
  final phrasesAsync = ref.watch(phrasesProvider);
  return phrasesAsync.when(
    data: (phrases) =>
        phrases.where((p) => p.category == category).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

// --- Vocabulary ---
final vocabularyProvider =
    FutureProvider<List<VocabularyWord>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getVocabulary();
});

final vocabularyByLevelProvider =
    Provider.family<List<VocabularyWord>, String>((ref, level) {
  final vocabAsync = ref.watch(vocabularyProvider);
  return vocabAsync.when(
    data: (words) => words.where((w) => w.level == level).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

final vocabularyByCategoryProvider =
    Provider.family<List<VocabularyWord>, String>((ref, category) {
  final vocabAsync = ref.watch(vocabularyProvider);
  return vocabAsync.when(
    data: (words) => words.where((w) => w.category == category).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

// --- TEF Tests ---
final tefTestsProvider = FutureProvider<List<TefTest>>((ref) async {
  ref.keepAlive();
  return ref.watch(dataRepositoryProvider).getTefTests();
});

// --- TTS Service ---
final ttsServiceProvider = Provider<TtsService>((ref) {
  ref.keepAlive();
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});
