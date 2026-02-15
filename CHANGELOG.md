# Changelog

## 2.0.0

### Session-First Redesign

Complete UX overhaul — the app now guides your daily learning instead of requiring you to choose what to study.

### New Learning Experience
- **Daily Sessions**: Open the app, tap "Start Session", and get a personalized 3-phase practice (review, new content, mixed practice)
- **Multi-Mode Quizzes**: 3 question types to keep learning fresh — French→English, English→French, and fill-in-the-blank (cloze)
- **Matching Game**: End each session with a matching challenge — connect 4 French↔English pairs
- **Post-Answer Context**: After every question, see the example sentence, memory hint, and related words to reinforce learning
- **Same-Category Distractors**: Quiz options come from the same word category so you can't guess by elimination
- **FSRS Algorithm**: Replaced SM-2 with the modern FSRS spaced repetition scheduler (20-30% more efficient, used by Anki)
- **Auto-Play TTS**: French words are spoken automatically during sessions — no need to tap the speaker button
- **Configurable Session Length**: Choose Casual (5 min), Regular (10 min), or Intense (15 min) in settings

### New Navigation
- **3-Tab Layout**: Today / Learn / Profile (replaced 4-tab Lessons/Words/TEF/Quiz)
- **Today Tab**: See your streak, session preview, words mastered count, and chapter roadmap at a glance
- **Learn Tab**: Filter chips to switch between Chapters, Word Bank, and TEF Prep — no more scrolling
- **Profile Tab**: Stats dashboard, chapter mastery bars, and all settings

### Improved Progress Tracking
- **Words Mastered**: Real count of words you've retained (FSRS stability > 30 days) — replaces meaningless XP
- **Chapter Mastery**: Based on both content completion and vocabulary retention — no more speedrunning without learning
- **Streak Freeze**: Earn 1 streak freeze every 7 consecutive days (max 2) — miss a day without losing your streak
- **Smart Session Button**: Shows "Practice More" after completing today's session

### Desktop & Responsive
- Desktop-friendly 2-column layout on Today tab
- Chapter roadmap wraps on wide screens instead of horizontal scroll
- Smooth animations without stagger delays

### Under the Hood
- Drift (SQLite) database for card states and review logs (replaces SharedPreferences for learning data)
- Web support via WASM-compiled SQLite
- Configurable TTS speed (Slow / Normal)
- Full SM-2 to FSRS data migration on first launch

## 1.1.0

### UX Improvements
- Speaker button on French example sentences in flashcards
- Daily words now pull from multiple categories for better variety
- Learning/study step before vocabulary quizzes
- Fixed flashcard rating buttons all showing "1d" — now shows distinct intervals (Easy: 4d, Good: 1d, Hard: 1d, Again: <1d)

### Auto-Update
- Android users get notified of new releases with in-app update dialog
- Downloads APK directly from GitHub Releases

### Infrastructure
- Secure release keystore signing for CI builds
- Vocabulary data audit: fixed 28 errors, added 75 new words (873 total)

## 1.0.0

- Initial release
- 10 chapters covering cognates, pronunciation, gender, verbs, grammar, numbers, false friends, liaison, phrases, and TEF tips
- Flashcard system with SM-2 spaced repetition
- Vocabulary quiz with 873 words across 20+ categories
- TEF reading comprehension practice tests
- Text-to-speech for French pronunciation
- Progress tracking with SharedPreferences
- Web and Android builds
