# UX Fixes Design - 2026-02-17

## Fixes

### 1. QuizCard: Replace auto-dismiss timer with Continue button
- Remove `Timer(2500ms)` from `_onOptionTap` in `quiz_card.dart`
- Add callback-driven flow: after answering, show feedback + "Continue" button
- User taps Continue to call `onComplete()`
- Matches existing VocabQuizScreen pattern

### 2. MatchingCard: Center and constrain layout
- Add horizontal padding (24px) and vertical centering
- Constrain max-width (~400px) for columns
- Center vertically in available space

### 3. Migrate word counts to Drift DB
- Add `studiedCountProvider` (cards with reps > 0) to database_provider.dart
- Add `studiedCountByCategoryProvider` for per-category counts
- Update `words_screen.dart` to use Drift providers instead of `progress.flashcards`

### 4. Remove legacy flashcard system
- Remove `flashcards` map from `UserProgress` model
- Remove `updateCardProgress()` from `ProgressNotifier`
- Update `VocabQuizScreen` to write to Drift/FSRS
- Update `FlashcardScreen` to write to Drift/FSRS
- Remove SM-2 imports where no longer needed
