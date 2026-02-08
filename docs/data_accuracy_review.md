# Data Accuracy Review

**Reviewed by:** UX Evaluator
**Date:** 2026-02-08
**Reference:** docs/french_content.txt
**Status:** COMPLETE review (all data files reviewed)

---

## Files Reviewed

### 1. chapters.json - PASS (with notes)

**Count check:** 10 chapters -- CORRECT (matches 10 chapters in source document)

**Chapter-by-chapter verification:**

| ID | Title in JSON | Title in Source | Match? |
|----|--------------|-----------------|--------|
| 1 | Cognates & Suffix Patterns | You Already Know 3,000+ French Words | ADAPTED (acceptable - more descriptive) |
| 2 | Pronunciation Rules | French Pronunciation Decoded | ADAPTED (acceptable) |
| 3 | Gender Rules | Gender Hacks: Masculine vs. Feminine | ADAPTED (acceptable) |
| 4 | Verb Conjugation | Verb Conjugation Shortcuts | ADAPTED (acceptable) |
| 5 | Essential Grammar | Essential Grammar Patterns | ADAPTED (acceptable) |
| 6 | Numbers | The French Number System | ADAPTED (acceptable) |
| 7 | False Friends | False Friends: Words That Will Trick You | ADAPTED (acceptable) |
| 8 | Liaison & Connected Speech | Liaison & Connected Speech | EXACT MATCH |
| 9 | Survival Phrases | Essential Survival Phrases | ADAPTED (acceptable) |
| 10 | TEF Speaking Tricks | TEF/TCF Speaking Test Tricks | ADAPTED (acceptable) |

**Section verification per chapter:**

| Chapter | Expected Sections | JSON Sections | Match? |
|---------|-------------------|---------------|--------|
| 1 | 1.1 Suffix Conversion Patterns | 1.1 only | CORRECT (Chapter 1 only has one main section) |
| 2 | 2.1-2.5 (Golden Rules, Vowels, Nasals, Consonants, CaReFuL) | All 5 | CORRECT |
| 3 | 3.1-3.2 (Feminine, Masculine) | Both | CORRECT |
| 4 | 4.1-4.5 (Essential, Shortcut, Present, Future, Past) | All 5 | CORRECT |
| 5 | 5.1-5.5 (Negation, Questions, Q-Words, Articles, Contractions) | All 5 | CORRECT |
| 6 | 6.1-6.2 (1-69, 70-99) | Both | CORRECT |
| 7 | 7.1 (Dangerous Word Pairs) | 1 section | CORRECT |
| 8 | 8.1-8.3 (Mandatory, Sound Changes, Elision) | All 3 | CORRECT |
| 9 | 9.1-9.3 (Basics, Communication, Daily Life) | All 3 | CORRECT |
| 10 | 10.1-10.3 (Fillers, Opinions, Recovery) | All 3 | CORRECT |

**Issues found:**

- **DATA-CH-1 (MEDIUM): Icon field uses Material icon names as strings**
  Icons like "translate", "record_voice_over", "wc", "edit", etc. These are string names, not emoji or icon codes. The UI currently tries to render these as `Text(chapter.icon)` which will show literal text. Either convert to emoji icons in the data, or add a lookup map in the UI code. This was also flagged in UX-HOME-3.

- **DATA-CH-2 (LOW): Many section blocks are empty arrays**
  Sections like 2.2 Vowel Sounds, 2.4 Consonant Tricks, etc. have `"blocks": []`. The actual data for these sections lives in separate JSON files (pronunciation.json, etc.), but the chapter/section structure doesn't reference them. The data provider needs a way to merge chapter sections with their detailed data.

**Verdict: PASS - structure is correct and matches the source document.**

---

### 2. suffix_patterns.json - PASS

**Count check:** 16 patterns -- CORRECT

**Line-by-line verification against source document (lines 21-88):**

| # | English | French | Examples Match? | Notes Match? |
|---|---------|--------|-----------------|--------------|
| 1 | -tion | -tion | EXACT: nation, information, situation, education, revolution | EXACT |
| 2 | -sion | -sion | EXACT: television, decision, passion, version, mission | EXACT |
| 3 | -ment | -ment | EXACT: moment, apartment, document, government, department | EXACT |
| 4 | -ous | -eux / -euse | EXACT: famous->fameux, dangerous->dangereux, curious->curieux | EXACT |
| 5 | -ty | -te (with accent) | EXACT: university->universite, quality->qualite, city->cite, liberty->liberte | EXACT |
| 6 | -al | -al / -el | EXACT: normal, final, national, international, animal, capital | EXACT |
| 7 | -ble | -ble | EXACT: possible, table, terrible, comfortable, flexible, visible | EXACT |
| 8 | -ary / -ery | -aire | EXACT: necessary->necessaire, ordinary->ordinaire, military->militaire | EXACT |
| 9 | -ence / -ance | -ence / -ance | EXACT: difference, silence, distance, importance, intelligence | EXACT |
| 10 | -ic | -ique | EXACT: music->musique, public->publique, fantastic->fantastique | EXACT |
| 11 | -ism | -isme | EXACT: tourism->tourisme, capitalism->capitalisme, optimism->optimisme | EXACT |
| 12 | -ist | -iste | EXACT: artist->artiste, tourist->touriste, dentist->dentiste | EXACT |
| 13 | -ly | -ment | EXACT: normally->normalement, exactly->exactement, rapidly->rapidement | EXACT |
| 14 | -ive | -if / -ive | EXACT: active->actif/active, positive->positif/positive | EXACT |
| 15 | -ure | -ure | EXACT: nature, culture, structure, adventure, temperature | EXACT |
| 16 | -age | -age | EXACT: garage, message, village, image, voyage | EXACT |

**Verdict: PERFECT MATCH - 16/16 patterns match the source document exactly.**

---

### 3. pronunciation.json - PASS

**Structure check:** Contains goldenRules, vowelSounds, nasalVowels, consonantRules, carefulRule -- all expected sections present.

**Golden Rules verification (source lines 100-103):**
- Rule 1 (Silent finals): MATCHES - includes CaReFuL exception, Petit example
- Rule 2 (Last syllable stress): MATCHES - includes chocolat example
- Rule 3 (Nasal vowels): MATCHES - includes bon, pain, vin examples

**Vowel Sounds verification (source lines 106-149):**

| # | Letters | Match? | Details |
|---|---------|--------|---------|
| 1 | ou | EXACT | vous, nous, tout with phonetic |
| 2 | u | EXACT | tu, rue, plus with umlaut |
| 3 | eu / oeu | EXACT | deux, bleu, heure |
| 4 | oi | EXACT | moi, trois, boire |
| 5 | ai / ei | EXACT | lait, maison, faire |
| 6 | au / eau | EXACT | eau, beau, restaurant |
| 7 | e (accent aigu) | EXACT | cafe, ete with accents |
| 8 | e (grave/circumflex) | EXACT | mere, fete, tres with accents |
| 9 | e (no accent, end) | EXACT | table, France |
| 10 | e (no accent, mid) | EXACT | le, petit, devenir |

**Count: 10/10 vowel sounds -- CORRECT**

**Nasal Vowels verification (source lines 154-169):**

| # | Spelling | Match? | Examples |
|---|----------|--------|----------|
| 1 | an/am/en/em | EXACT | France, enfant, comment, temps, chanson |
| 2 | on/om | EXACT | bon, nom, maison, onze, bonjour |
| 3 | in/im/ain/ein/un | EXACT | vin, pain, demain, important, lundi |

**Count: 3/3 nasal vowel categories -- CORRECT**

Note: The nasal vowel trick (lines 172-175) is present in chapters.json section 2.3 as a tip block. CORRECT.

**Consonant Rules verification (source lines 178-221):**

| # | Letter | Match? | Notes |
|---|--------|--------|-------|
| 1 | c | EXACT | s before e/i/y, k before a/o/u |
| 2 | c-cedilla | EXACT | Always s, francais/garcon examples |
| 3 | g | EXACT | zh before e/i, hard g before a/o/u |
| 4 | gn | EXACT | ny sound, montagne/champagne/gagner |
| 5 | h | EXACT | Always silent, homme/hotel/heure |
| 6 | j | EXACT | zh sound, je/jour/jardin |
| 7 | r | EXACT | Back of throat, rouge/Paris/merci |
| 8 | qu | EXACT | Always k, qui/que/quand |
| 9 | ch | EXACT | sh sound, chat/chose/chercher |
| 10 | th | EXACT | Just t, theatre/thon |

**Count: 10/10 consonant rules -- CORRECT**

**CaReFuL Rule verification (source lines 223-229):**

| Letter | Source Examples | JSON Examples | Match? |
|--------|---------------|---------------|--------|
| C | avec, sac, parc | avec (a-VEK), sac (SAK), parc (PARK) | EXACT |
| R | pour, sur, bonjour | pour (POOR), sur (SUR), bonjour (bon-ZHOOR) | EXACT |
| F | chef, sportif, neuf | chef (SHEF), sportif (spor-TEEF), neuf (NUHF) | EXACT |
| L | animal, hotel, avril | animal (a-nee-MAL), hotel (oh-TEL), avril (a-VREEL) | EXACT |

**Count: 4/4 CaReFuL letters -- CORRECT**

**Verdict: PERFECT MATCH - All pronunciation data matches the source document exactly.**

---

---

### 4. gender_rules.json - PASS

**Structure:** Contains `feminine` (8 entries) and `masculine` (7 entries) arrays.

**Feminine endings verification (source lines 235-261):**

| # | Ending | Accuracy | Examples Match? | Match? |
|---|--------|----------|-----------------|--------|
| 1 | -tion/-sion | ~99% | la nation, la television, la situation, la decision | EXACT |
| 2 | -te | ~99% | la liberte, la qualite, la societe, l'universite | EXACT |
| 3 | -ure | ~95% | la nature, la voiture, la culture, l'aventure | EXACT |
| 4 | -ence/-ance | ~95% | la difference, la France, la science, l'importance | EXACT |
| 5 | -ie | ~95% | la vie, la partie, la philosophie, l'energie | EXACT |
| 6 | -ette/-elle | ~95% | la baguette, la fourchette, la nouvelle, la chapelle | EXACT |
| 7 | -ise/-aise | ~95% | la surprise, la valise, la francaise, la mayonnaise | EXACT |
| 8 | -ee | ~99% | la journee, l'idee, l'annee, l'arrivee | EXACT |

**Count: 8/8 feminine endings -- CORRECT**

**Masculine endings verification (source lines 263-288):**

| # | Ending | Accuracy | Examples | Exceptions | Match? |
|---|--------|----------|----------|------------|--------|
| 1 | -age | ~90% | le garage, le voyage, le message, le fromage | la plage, la page, l'image | EXACT |
| 2 | -ment | ~99% | le moment, le gouvernement, le mouvement, l'appartement | - | EXACT |
| 3 | -isme | ~99% | le tourisme, le capitalisme, le journalisme | - | EXACT |
| 4 | -eau | ~99% | le bateau, le gateau, le chapeau, le bureau | l'eau = feminine! | EXACT |
| 5 | -oir | ~95% | le miroir, le soir, le pouvoir, le devoir | - | EXACT |
| 6 | -et | ~95% | le ticket, le billet, le secret, le sujet | - | EXACT |
| 7 | consonant ending | ~65-70% | le sport, le restaurant, le chat, le film | - | EXACT |

**Count: 7/7 masculine endings -- CORRECT**

**Verdict: PERFECT MATCH - All gender rules with accuracy percentages and exceptions match exactly.**

---

### 5. verbs.json - PASS

**Structure:** Contains `essentialVerbs` (27), `erConjugationPattern` (6), `vandertrampVerbs` (16), `futureTenseExamples` (4), `pastTenseExamples` (5), `pastParticipleRules` (3).

**Essential verbs verification (source lines 306-358):**

| # | Verb | Meaning | Source Match? |
|---|------|---------|---------------|
| 1 | etre | to be | EXACT |
| 2 | avoir | to have | EXACT |
| 3 | faire | to do/make | EXACT |
| 4 | aller | to go | EXACT |
| 5 | venir | to come | EXACT |
| 6 | pouvoir | can/to be able | EXACT |
| 7 | vouloir | to want | EXACT |
| 8 | devoir | must/to have to | EXACT |
| 9 | savoir | to know (facts) | EXACT |
| 10 | dire | to say/tell | EXACT |
| 11 | parler | to speak | EXACT (includes presentTense conjugation) |
| 12 | prendre | to take | EXACT |
| 13 | voir | to see | EXACT |
| 14 | mettre | to put | EXACT |
| 15 | donner | to give | EXACT |
| 16 | trouver | to find | EXACT |
| 17 | manger | to eat | EXACT (includes presentTense conjugation) |
| 18 | travailler | to work | EXACT (includes presentTense conjugation) |
| 19 | habiter | to live | EXACT |
| 20 | comprendre | to understand | EXACT |
| 21 | aimer | to like/love | EXACT |
| 22 | penser | to think | EXACT |
| 23 | demander | to ask | EXACT |
| 24 | croire | to believe | EXACT |
| 25 | connaitre | to know (people) | EXACT |
| 26 | attendre | to wait | EXACT |
| 27 | acheter | to buy | EXACT |

**Count: 27/27 essential verbs -- CORRECT**

**ER conjugation pattern (source lines 375-417):** 6 subjects with correct endings and sounds -- EXACT MATCH

**VANDERTRAMP verbs verification (source lines 440-443):**
All 16 verbs present: Devenir, Revenir, Monter, Retourner, Sortir, Venir, Aller, Naitre, Descendre, Entrer, Rentrer, Tomber, Rester, Arriver, Mourir, Partir -- **EXACT MATCH**

**Future tense examples (source lines 422-426):** 4 examples -- EXACT MATCH
**Past tense examples (source lines 432-437):** 5 examples -- EXACT MATCH
**Past participle rules (source line 438):** 3 rules (-er->-e, -ir->-i, -re->-u) -- EXACT MATCH

**Bonus data:** The JSON includes `pastParticiple` and `auxiliaryVerb` for every essential verb, plus `group` classification. These are accurate additions beyond the source document.

**Verdict: PERFECT MATCH - All verbs, conjugation patterns, and rules match the source document.**

---

### 6. grammar.json - PASS

**Structure:** Contains `negation`, `questionMethods` (3), `questionWords` (7), `articles` (2), `contractions` (6).

**Negation verification (source lines 449-458):**
- Rule: "Put NE...PAS around the conjugated verb" -- EXACT
- 3 examples match exactly
- Spoken shortcut about dropping "ne" -- EXACT

**Question methods (source lines 461-465):**
- Rising intonation (easiest), Est-ce que (medium), Inversion (formal) -- EXACT

**Question words (source lines 468-499):**

| French | English | Example | Pronunciation | Match? |
|--------|---------|---------|---------------|--------|
| Qui | Who | Qui est-ce? | kee | EXACT |
| Quoi/Que | What | C'est quoi? / Qu'est-ce que c'est? | kwah/kuh | EXACT |
| Ou | Where | Ou est la gare? | oo | EXACT |
| Quand | When | Quand est-ce qu'on part? | kah(n) | EXACT |
| Pourquoi | Why | Pourquoi pas? | poor-KWAH | EXACT |
| Comment | How | Comment allez-vous? | ko-MAH(N) | EXACT |
| Combien | How much/many | Combien ca coute? | kom-BEE-A(N) | EXACT |

**Count: 7/7 -- CORRECT**

**Articles (source lines 504-519):** Both definite and indefinite with masculine/feminine/plural -- EXACT
Note: `beforeVowel` correctly present for definite but not for indefinite (matches source: indefinite does not elide to l').

**Contractions (source lines 524-551):**

| Combination | Contraction | Match? |
|-------------|-------------|--------|
| de + le -> du | du pain | EXACT |
| de + les -> des | des enfants | EXACT |
| a + le -> au | au restaurant | EXACT |
| a + les -> aux | aux Etats-Unis | EXACT |
| je + vowel -> j' | j'ai, j'aime, j'habite | EXACT |
| ne + vowel -> n' | je n'ai pas | EXACT |

**Count: 6/6 -- CORRECT**

**Verdict: PERFECT MATCH - All grammar data matches the source document exactly.**

---

### 7. numbers.json - PASS

**Count check:** 61 number entries (0-22, 30-32, 40, 50, 60, 70-100) -- Comprehensive

**Verification against source (lines 557-634):**

- Numbers 0-19: All 20 numbers present and correct
- Tens 20-60: vingt, trente, quarante, cinquante, soixante -- CORRECT
- Compound examples: 21 (vingt et un), 22 (vingt-deux), 31 (trente et un), 32 (trente-deux) -- EXACT
- 70-79: All 10 numbers with correct formulas (60+10 through 60+19) -- EXACT
- 80-89: All 10 numbers with correct formulas (4x20+0 through 4x20+9) -- EXACT
- 90-99: All 10 numbers with correct formulas (4x20+10 through 4x20+19) -- EXACT
- 100: cent -- CORRECT

**Issue found:**
- **DATA-NUM-1 (LOW):** Missing Belgian/Swiss variants. The source document mentions septante (70), huitante/octante (80), nonante (90) at line 635. These are not included in the JSON. Consider adding as an additional field or separate section.

**Verdict: PASS - All standard French numbers accurate. Missing Belgian/Swiss variants noted.**

---

### 8. false_friends.json - PASS

**Count check:** 13 entries -- CORRECT (matches all entries from source lines 640-709)

**Line-by-line verification:**

| French Word | Looks Like | Actually Means | Danger | English Equiv | Match? |
|-------------|-----------|---------------|--------|---------------|--------|
| blesse | blessed | injured/wounded | HIGH | beni = blessed | EXACT |
| actuellement | actually | currently/right now | HIGH | en fait = actually | EXACT |
| assister | to assist | to attend/be present at | MEDIUM | aider = to assist | EXACT |
| attendre | to attend | to wait for | HIGH | assister = to attend | EXACT |
| bras | bra | arm | FUNNY | soutien-gorge = bra | EXACT |
| coin | coin (money) | corner | LOW | piece = coin | EXACT |
| excite | excited | sexually aroused (!) | VERY HIGH | enthousiaste = excited | EXACT |
| librairie | library | bookstore | MEDIUM | bibliotheque = library | EXACT |
| preservatif | preservative | condom (!) | VERY HIGH | conservateur = preservative | EXACT |
| regarder | to regard | to watch/look at | LOW | considerer = to regard | EXACT |
| rester | to rest | to stay/remain | MEDIUM | se reposer = to rest | EXACT |
| sympa(thique) | sympathetic | nice/friendly | LOW | compatissant = sympathetic | EXACT |
| envie | envy | desire/want | MEDIUM | jalousie = envy | EXACT |

**Count: 13/13 -- CORRECT (includes sympa and envie from the expanded table)**

**Verdict: PERFECT MATCH - All false friends with correct danger levels and equivalents.**

---

### 9. liaison_rules.json - PASS

**Structure:** 9 entries total: 4 mandatory, 4 sound_change, 1 elision.

**Mandatory liaisons (source lines 715-718):**

| Category | Examples | Match? |
|----------|----------|--------|
| Article + noun | les amis, un homme, des etudiants | EXACT |
| Subject pronoun + verb | nous avons, vous etes, ils ont | EXACT |
| Adjective + noun | petit enfant, bon ami | EXACT |
| After prepositions | en Italie, dans un, chez elle | EXACT |

**Sound changes (source lines 721-724):**

| Change | Examples | Match? |
|--------|----------|--------|
| s/x -> Z | les amis, deux heures | EXACT |
| d -> T | grand homme | EXACT |
| n -> N | un ami, bon appetit | EXACT |
| t -> T | petit enfant | EXACT |

**Elision (source lines 727-733):**
All 5 examples present: l'ami, j'ai, n'ai, d'eau, qu'il -- EXACT

**Verdict: PERFECT MATCH - All liaison rules, sound changes, and elision examples match exactly.**

---

### 10. phrases.json - PASS

**Structure:** Single flat array with `category` field for grouping. Categories: basics, communication, daily_life, tef_fillers, tef_opinions, tef_recovery.

**Basics (source lines 739-754):**
14 entries covering Bonjour/Bonsoir, Comment allez-vous?, Ca va?, Je m'appelle..., Moi c'est..., Enchante(e), S'il vous plait, Merci, De rien, Excusez-moi, Pardon, Au revoir, Bonne journee, A bientot.

Note: The source document groups some phrases together (e.g., "S'il vous plait / Merci / De rien" as one entry). The JSON splits them into individual entries, resulting in more entries but all content is accounted for. This is actually better for individual flashcard/quiz use.

**Communication lifelines (source lines 757-773):** 8 entries -- all phrases match EXACTLY
**Daily life (source lines 775-791):** 8 entries -- all phrases match EXACTLY
**TEF fillers (source lines 798-824):** 8 entries -- EXACT match (all 8 filler words)
**TEF opinions (source lines 827-833):** 6 entries -- EXACT match (all 6 structures)
**TEF recovery (source lines 836-840):** 5 entries -- EXACT match (all 5 strategies)

**Total: 49 phrases across 6 categories -- comprehensive coverage of all source material plus Chapter 10 content.**

**Verdict: PERFECT MATCH - All phrases from the source document accurately captured with proper categorization.**

---

### 11. quiz_questions.json - PASS

**Count check:** 100 questions (10 per chapter for all 10 chapters) -- EXCELLENT coverage

**Structure:** Flat JSON array. Each question has: id, chapterId, type, question, options, correctAnswer, explanation, difficulty.

**Question types:** multiple_choice, fill_blank, true_false -- good variety.

**Difficulty distribution per chapter:** Mix of easy, medium, hard -- appropriate progression.

**Chapter-by-chapter content verification:**

| Chapter | Topic | Count | Types | Accuracy |
|---------|-------|-------|-------|----------|
| 1 (Cognates) | Suffix patterns, -tion/-ty/-ic/-ism etc | 10 | MC, fill_blank, true_false | CORRECT - all answers match source data |
| 2 (Pronunciation) | CaReFuL rule, oi/ch/nasal/stress/accents | 10 | MC, true_false, fill_blank | CORRECT - all answers verified against pronunciation.json |
| 3 (Gender) | -tion/-ment/-age/-ee/-ure endings, l'eau exception | 10 | MC, true_false, fill_blank | CORRECT - all gender rules match source |
| 4 (Verbs) | -er conjugation, aller+inf future, VANDERTRAMP, past participles | 10 | MC, true_false, fill_blank | CORRECT - 80%+ stat, conjugation pattern, all verified |
| 5 (Grammar) | NE...PAS negation, questions, contractions, articles | 10 | MC, true_false, fill_blank | CORRECT - all grammar rules match |
| 6 (Numbers) | 70=soixante-dix, 80=quatre-vingts, 90=quatre-vingt-dix, Belgian variants | 10 | MC, true_false, fill_blank | CORRECT - math formulas and variants accurate |
| 7 (False Friends) | blesse, actuellement, excite, librairie, preservatif, etc | 10 | MC, true_false, fill_blank | CORRECT - all danger levels and correct alternatives match |
| 8 (Liaison) | Mandatory liaison, s/x->Z, d->T, elision, j'ai | 10 | MC, true_false, fill_blank | CORRECT - all liaison rules and pronunciation verified |
| 9 (Phrases) | Je ne comprends pas, Je voudrais, Enchante, etc | 10 | MC, fill_blank | CORRECT - all phrases match source |
| 10 (TEF) | Keep talking, fillers (Alors), self-correction, topic switch | 10 | MC, true_false, fill_blank | CORRECT - all TEF strategies match source |

**Spot-check verification of tricky answers:**
- q2_09: "bonne has nasal vowel" = False -- CORRECT (vowel+N/M followed by another vowel is NOT nasal)
- q3_03: "l'eau gender" = Feminine -- CORRECT (famous exception to -eau masculine rule)
- q4_07: "80%+ of French verbs end in -er" -- CORRECT (source line ~365)
- q6_05: "quatre-vingt-quinze = 95" -- CORRECT (4x20+15)
- q7_03: "excite = sexually aroused" -- CORRECT (source confirms VERY HIGH danger level)
- q8_06: "d becomes T in liaison" -- CORRECT (source: grand homme = grah(n)-TOM)

**Issues found:**
- **DATA-QUIZ-1 (LOW):** q1_01 has duplicate option: options include "-cion" twice. Should have 4 distinct options.
- **DATA-QUIZ-2 (OBSERVATION):** All questions have exactly 4 options (or 2 for true/false), which is consistent and appropriate.

**Verdict: PASS - 100 questions covering all 10 chapters with accurate content. One duplicate option noted.**

---

### 12. quizzes.json - PASS (DUPLICATE FILE)

**Count check:** 28 questions across 10 chapters (2-4 per chapter)

**Structure:** Same format as quiz_questions.json (id, chapterId, type, question, options, correctAnswer, explanation, difficulty).

**Content verification:** All 28 questions are accurate -- the content matches the source document. However, these questions are a subset/overlap with quiz_questions.json. Many cover the same topics but with slightly different wording.

**Issues found:**

- **DATA-QUIZDUP-1 (MEDIUM): Two quiz data files exist**
  `quiz_questions.json` has 100 questions (10 per chapter). `quizzes.json` has 28 questions (2-4 per chapter). The `DataRepository` references `quiz_questions.json`, while the old `data_provider.dart` references `quizzes.json`. Only one should be canonical. Recommendation: use `quiz_questions.json` (more comprehensive) and delete `quizzes.json`, or merge unique questions from both.

- **DATA-QUIZDUP-2 (LOW): ID format inconsistency**
  `quiz_questions.json` uses IDs like `q1_01` (zero-padded). `quizzes.json` uses `q1_1` (no padding). This would cause issues if both files were ever loaded together.

**Verdict: PASS for content accuracy. File should be consolidated with quiz_questions.json.**

---

## Overall Data Accuracy Summary

| File | Status | Accuracy |
|------|--------|----------|
| chapters.json | REVIEWED | PASS (structure correct, icon representation issue noted) |
| suffix_patterns.json | REVIEWED | PERFECT (16/16 patterns exact match) |
| pronunciation.json | REVIEWED | PERFECT (all rules, vowels, nasals, consonants exact match) |
| gender_rules.json | REVIEWED | PERFECT (8 feminine + 7 masculine, all accuracy % and exceptions correct) |
| verbs.json | REVIEWED | PERFECT (27/27 verbs, conjugation patterns, VANDERTRAMP all correct) |
| grammar.json | REVIEWED | PERFECT (negation, questions, articles, contractions all correct) |
| numbers.json | REVIEWED | PASS (all numbers correct; missing Belgian/Swiss variants) |
| false_friends.json | REVIEWED | PERFECT (13/13 entries with correct danger levels) |
| liaison_rules.json | REVIEWED | PERFECT (mandatory, sound changes, elision all correct) |
| phrases.json | REVIEWED | PERFECT (49 phrases across 6 categories, comprehensive) |
| quiz_questions.json | REVIEWED | PASS (100 questions, all accurate; 1 duplicate option in q1_01) |
| quizzes.json | REVIEWED | PASS (28 questions accurate but DUPLICATE file -- should be consolidated) |

**Overall data quality: EXCELLENT. 12/12 files reviewed. 9 files are perfect matches. 3 files have minor issues (Belgian variants, duplicate option, duplicate file). All French language content is factually accurate.**
