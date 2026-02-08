import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

class DataRepository {
  List<Chapter>? _chapters;
  List<Lesson>? _lessons;
  List<SuffixPattern>? _suffixPatterns;
  Map<String, dynamic>? _pronunciation;
  Map<String, dynamic>? _grammarData;
  List<GenderRule>? _feminineRules;
  List<GenderRule>? _masculineRules;
  Map<String, dynamic>? _verbData;
  List<NumberItem>? _numbers;
  List<FalseFriend>? _falseFriends;
  List<LiaisonRule>? _liaisonRules;
  List<Phrase>? _phrases;
  List<QuizQuestion>? _quizQuestions;

  Future<List<Chapter>> getChapters() async {
    if (_chapters != null) return _chapters!;
    final data = await _loadJson('assets/data/chapters.json');
    _chapters = (jsonDecode(data) as List)
        .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
        .toList();
    return _chapters!;
  }

  Future<List<Lesson>> getLessons() async {
    if (_lessons != null) return _lessons!;
    final data = await _loadJson('assets/data/lessons.json');
    _lessons = (jsonDecode(data) as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
    return _lessons!;
  }

  Future<List<SuffixPattern>> getSuffixPatterns() async {
    if (_suffixPatterns != null) return _suffixPatterns!;
    final data = await _loadJson('assets/data/suffix_patterns.json');
    _suffixPatterns = (jsonDecode(data) as List)
        .map((e) => SuffixPattern.fromJson(e as Map<String, dynamic>))
        .toList();
    return _suffixPatterns!;
  }

  Future<Map<String, dynamic>> getPronunciation() async {
    if (_pronunciation != null) return _pronunciation!;
    final data = await _loadJson('assets/data/pronunciation.json');
    _pronunciation = jsonDecode(data) as Map<String, dynamic>;
    return _pronunciation!;
  }

  Future<List<VowelSound>> getVowelSounds() async {
    final pron = await getPronunciation();
    return (pron['vowelSounds'] as List)
        .map((e) => VowelSound.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NasalVowel>> getNasalVowels() async {
    final pron = await getPronunciation();
    return (pron['nasalVowels'] as List)
        .map((e) => NasalVowel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ConsonantRule>> getConsonantRules() async {
    final pron = await getPronunciation();
    return (pron['consonantRules'] as List)
        .map((e) => ConsonantRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CarefulRule>> getCarefulRules() async {
    final pron = await getPronunciation();
    return (pron['carefulRule'] as List)
        .map((e) => CarefulRule.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getGoldenRules() async {
    final pron = await getPronunciation();
    return (pron['goldenRules'] as List).cast<String>();
  }

  Future<List<GenderRule>> getFeminineRules() async {
    if (_feminineRules != null) return _feminineRules!;
    final data = await _loadJson('assets/data/gender_rules.json');
    final json = jsonDecode(data) as Map<String, dynamic>;
    _feminineRules = (json['feminine'] as List)
        .map((e) => GenderRule.fromJson(e as Map<String, dynamic>))
        .toList();
    return _feminineRules!;
  }

  Future<List<GenderRule>> getMasculineRules() async {
    if (_masculineRules != null) return _masculineRules!;
    final data = await _loadJson('assets/data/gender_rules.json');
    final json = jsonDecode(data) as Map<String, dynamic>;
    _masculineRules = (json['masculine'] as List)
        .map((e) => GenderRule.fromJson(e as Map<String, dynamic>))
        .toList();
    return _masculineRules!;
  }

  Future<Map<String, dynamic>> getVerbData() async {
    if (_verbData != null) return _verbData!;
    final data = await _loadJson('assets/data/verbs.json');
    _verbData = jsonDecode(data) as Map<String, dynamic>;
    return _verbData!;
  }

  Future<List<Verb>> getEssentialVerbs() async {
    final vData = await getVerbData();
    return (vData['essentialVerbs'] as List)
        .map((e) => Verb.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VerbConjugationPattern>> getErConjugationPattern() async {
    final vData = await getVerbData();
    return (vData['erConjugationPattern'] as List)
        .map((e) => VerbConjugationPattern.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VandertrampVerb>> getVandertrampVerbs() async {
    final vData = await getVerbData();
    return (vData['vandertrampVerbs'] as List)
        .map((e) => VandertrampVerb.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getGrammarData() async {
    if (_grammarData != null) return _grammarData!;
    final data = await _loadJson('assets/data/grammar.json');
    _grammarData = jsonDecode(data) as Map<String, dynamic>;
    return _grammarData!;
  }

  Future<List<QuestionWord>> getQuestionWords() async {
    final gData = await getGrammarData();
    return (gData['questionWords'] as List)
        .map((e) => QuestionWord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Article>> getArticles() async {
    final gData = await getGrammarData();
    return (gData['articles'] as List)
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Contraction>> getContractions() async {
    final gData = await getGrammarData();
    return (gData['contractions'] as List)
        .map((e) => Contraction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getNegation() async {
    final gData = await getGrammarData();
    return gData['negation'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getQuestionMethods() async {
    final gData = await getGrammarData();
    return (gData['questionMethods'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getFutureTenseExamples() async {
    final vData = await getVerbData();
    return (vData['futureTenseExamples'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPastTenseExamples() async {
    final vData = await getVerbData();
    return (vData['pastTenseExamples'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPastParticipleRules() async {
    final vData = await getVerbData();
    return (vData['pastParticipleRules'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<NumberItem>> getNumbers() async {
    if (_numbers != null) return _numbers!;
    final data = await _loadJson('assets/data/numbers.json');
    _numbers = (jsonDecode(data) as List)
        .map((e) => NumberItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return _numbers!;
  }

  Future<List<FalseFriend>> getFalseFriends() async {
    if (_falseFriends != null) return _falseFriends!;
    final data = await _loadJson('assets/data/false_friends.json');
    _falseFriends = (jsonDecode(data) as List)
        .map((e) => FalseFriend.fromJson(e as Map<String, dynamic>))
        .toList();
    return _falseFriends!;
  }

  Future<List<LiaisonRule>> getLiaisonRules() async {
    if (_liaisonRules != null) return _liaisonRules!;
    final data = await _loadJson('assets/data/liaison_rules.json');
    _liaisonRules = (jsonDecode(data) as List)
        .map((e) => LiaisonRule.fromJson(e as Map<String, dynamic>))
        .toList();
    return _liaisonRules!;
  }

  Future<List<Phrase>> getPhrases() async {
    if (_phrases != null) return _phrases!;
    final data = await _loadJson('assets/data/phrases.json');
    _phrases = (jsonDecode(data) as List)
        .map((e) => Phrase.fromJson(e as Map<String, dynamic>))
        .toList();
    return _phrases!;
  }

  Future<List<Phrase>> getPhrasesByCategory(String category) async {
    final all = await getPhrases();
    return all.where((p) => p.category == category).toList();
  }

  Future<List<QuizQuestion>> getQuizQuestions() async {
    if (_quizQuestions != null) return _quizQuestions!;
    final data = await _loadJson('assets/data/quiz_questions.json');
    _quizQuestions = (jsonDecode(data) as List)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    return _quizQuestions!;
  }

  Future<List<QuizQuestion>> getQuizQuestionsForChapter(int chapterId) async {
    final all = await getQuizQuestions();
    return all.where((q) => q.chapterId == chapterId).toList();
  }

  Future<String> _loadJson(String path) async {
    return rootBundle.loadString(path);
  }
}
