# Early Architecture & Models Review

**Reviewed by:** UX Evaluator
**Date:** 2026-02-08
**Status:** In-progress (architecture and data still being built)

## 1. Overall Assessment

The project is shaping up well. The foundational choices (Riverpod, GoRouter, Google Fonts, JSON data layer) are solid and appropriate for this type of app. The model layer covers all the content areas from the reference document comprehensively.

**Rating: GOOD foundation, with specific improvements noted below.**

---

## 2. Theme & Design System Review

### Strengths
- French-inspired color palette (navy, red, gold) is well-chosen and distinctive
- Material 3 is enabled (`useMaterial3: true`)
- Typography uses Playfair Display for headlines (elegant, French feel) and Inter for body (clean, readable)
- Button padding (32h x 16v) provides good touch targets
- Card radius of 16dp is modern and clean
- Comprehensive color system with semantic colors (success, warning, error, info)

### Issues Found

**ISSUE 1 - Accessibility: Color Contrast**
- `textLight` (#95A5A6) on `offWhite` (#FAFAFA) background: contrast ratio ~2.3:1. FAILS WCAG AA for normal text (needs 4.5:1). This is used for `bodySmall` and `labelSmall`.
- `textSecondary` (#5D6B7E) on white (#FFFFFF): contrast ratio ~4.7:1. PASSES AA for normal text but barely. Fine for `bodyMedium` at 14px.
- `navInactive` (#95A5A6) on white: same 2.3:1 concern for bottom nav labels.

**RECOMMENDATION:** Darken `textLight` to at least #6B7B8D (~4.5:1 on white) and `navInactive` similarly.

**ISSUE 2 - Missing headlineLarge**
- The TextTheme defines displayLarge/Medium/Small and headlineMedium/Small but skips `headlineLarge`. This gap in the type scale may cause inconsistencies if widgets reference it.

**ISSUE 3 - No Dark Theme**
- Only `lightTheme` is defined. While not a launch blocker, many users expect dark mode support. Consider adding it as a follow-up.

**ISSUE 4 - Missing NavigationBar theme**
- The theme uses `bottomNavigationBarTheme` but GoRouter with Material 3 typically uses `NavigationBar` (the M3 version), not `BottomNavigationBar` (the M2 version). The theme should also include `navigationBarTheme`.

---

## 3. Data Models Review

### Strengths
- All 10 content chapters from the reference document have corresponding models
- Clean, simple Dart classes with const constructors
- fromJson/toJson implemented consistently across all models
- Good use of nullable fields for optional data
- `UserProgress` with `copyWith` pattern is well-designed for Riverpod state management
- `CardProgress` with SM-2 fields (easeFactor, interval, repetitions) is correctly structured

### Issues Found

**ISSUE 5 - Lesson vs Chapter Duplication**
- Both `Lesson` and `Chapter` models exist with overlapping purposes. `Chapter` has `id`, `title`, `description`, `icon`, `sections`. `Lesson` has `id`, `title`, `subtitle`, `icon`, `totalSections`, `completedSections`, `category`, `sections`. The relationship between them is unclear. Consider: is a Chapter a container of Lessons, or are they the same thing?

**RECOMMENDATION:** Clarify the data hierarchy. Suggested: Chapter (10 total, matching the document) -> contains Lessons (subsections within each chapter). The `Lesson` model should probably reference a `chapterId`.

**ISSUE 6 - Lesson model mixes data and state**
- `Lesson` has `completedSections` which is user-specific state. Data models should be immutable representations of content. User progress should live exclusively in `UserProgress`/`ChapterProgress`.

**ISSUE 7 - Models lack `toJson` in Lesson/LessonSection/LessonExample**
- `Lesson`, `LessonSection`, and `LessonExample` have `fromJson` but no `toJson`. This breaks serialization roundtrip testing.

**ISSUE 8 - Pronunciation model file naming**
- File is `pronunciation_rule.dart` but contains 4 classes: `VowelSound`, `NasalVowel`, `ConsonantRule`, `CarefulRule`. Consider renaming to `pronunciation.dart` or splitting into separate files for clarity.

**ISSUE 9 - Grammar model file naming**
- File is `grammar.dart` but contains `QuestionWord`, `Article`, `Contraction`. No umbrella `Grammar` class ties them together. This is fine structurally but the file name doesn't clearly indicate its contents.

**ISSUE 10 - QuizQuestion.type uses raw strings**
- `type` field accepts strings like 'multiple_choice', 'true_false', etc. Consider using an enum for type safety, or at minimum document the valid values.

**ISSUE 11 - No equality/hashCode overrides**
- None of the models implement `==` or `hashCode`. This could cause issues with Riverpod state comparison. Models used as state or in collections should implement value equality (consider `Equatable` package or manual overrides).

---

## 4. Progress & State Management Review

### Strengths
- `ProgressNotifier` using `StateNotifier` with SharedPreferences persistence is clean
- Streak tracking logic is correct (checks yesterday for continuity)
- Quiz best score tracking preserves the highest score
- XP system is simple and understandable

### Issues Found

**ISSUE 12 - SharedPreferences provider throws**
- `sharedPreferencesProvider` throws `UnimplementedError`. This must be overridden in `main.dart` before use. This is a valid pattern but should be documented clearly and the override must appear in the app initialization.

**ISSUE 13 - No loading state for initial data**
- `ProgressNotifier._load()` is called synchronously in the constructor but reads a String synchronously. This works with SharedPreferences (which must be pre-initialized), but there is no error handling if the JSON is malformed.

---

## 5. File Structure Assessment

### Current Structure
```
lib/
  main.dart                    (default Flutter counter - needs replacement)
  core/
    constants/
      app_colors.dart
      app_strings.dart
    theme/
      app_theme.dart
  models/
    (12 model files + barrel export)
  providers/
    progress_provider.dart
```

### Assessment
- Good separation of core/models/providers
- Missing: router/, repositories/, screens/, widgets/
- The `core/constants/` and `core/theme/` organization is clean
- Barrel export file (`models.dart`) is helpful

---

## 6. Priority Fixes

| Priority | Issue | Impact |
|----------|-------|--------|
| HIGH | #1 - textLight contrast | Accessibility failure |
| HIGH | #5 - Lesson vs Chapter | Architecture confusion |
| HIGH | #6 - Lesson mixes data/state | State management problems |
| MEDIUM | #7 - Missing toJson on Lesson | Testing gaps |
| MEDIUM | #4 - NavigationBar theme | M3 inconsistency |
| MEDIUM | #11 - No equality overrides | Potential state bugs |
| LOW | #2 - Missing headlineLarge | Minor type scale gap |
| LOW | #3 - No dark theme | User preference |
| LOW | #8, #9 - File naming | Code clarity |
| LOW | #10 - Quiz type strings | Type safety |

---

## 7. Data Files Status

**No JSON data files exist yet** (assets/data/ is empty). The data-engineer is still working on Task #5. Once JSON files are created, a full data accuracy review against `docs/french_content.txt` will be performed.

Expected files to validate:
- [ ] suffix_patterns.json (16 patterns)
- [ ] pronunciation_rules.json (golden rules, vowels, nasals, consonants, CaReFuL)
- [ ] gender_rules.json (8 feminine + 7 masculine endings)
- [ ] verbs.json (27 essential verbs + conjugation patterns + VANDERTRAMP)
- [ ] grammar_rules.json (negation, questions, articles, contractions)
- [ ] numbers.json (0-100 with 70-99 system)
- [ ] false_friends.json (11-13 entries)
- [ ] liaison_rules.json (mandatory, sound changes, elision)
- [ ] survival_phrases.json (21+ phrases across 3 categories)
- [ ] quiz_questions.json (90+ questions, 10+ per chapter)
