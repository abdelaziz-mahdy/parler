# Changelog

## 2.1.0

### UX Fixes
- **Quiz Continue Button**: Helper text (examples, memory hints) after answering now stays until you tap "Continue" instead of auto-dismissing on a 2.5s timer
- **Matching Exercise Layout**: Pick-and-choose matching game is now centered with a max-width constraint instead of stretching full-width
- **Word Count Accuracy**: "Words I Know" count now updates correctly after completing sessions (migrated from legacy SharedPreferences to Drift database)

### New Content in Sessions
- **Phrases, Verbs & False Friends**: Daily sessions now include bonus quiz questions from survival phrases, essential verbs, and false friends data — not just vocabulary words
- **Session Length Setting**: The Casual/Regular/Intense setting in Profile now actually controls session length (was previously hardcoded to Regular)

### Data Migration
- **Full FSRS Migration**: All screens (Flashcards, Vocab Quiz, Today, Learn, Lessons) now read/write card progress exclusively through Drift/FSRS instead of the legacy SM-2/SharedPreferences system
- **Removed Legacy Flashcard System**: Cleaned up `UserProgress.flashcards` field, `updateCardProgress()`, and all SM-2 references from UI screens

### Session Content
- **False Friend Trap Questions**: False friend quizzes always include the misleading English word as a distractor (e.g., "actually" as a wrong option for "actuellement") with a post-answer warning hint

### Cleanup
- **Removed 6 Orphaned Screens**: Deleted unused v1 screens (home, lessons, quiz, profile, wordbank) and duplicate WordsScreen
- **Removed Dead SM-2 Code**: Deleted `spaced_repetition.dart`, `sm2_migration.dart`, and `CardProgress` class
- **Removed Duplicate Word Bank Route**: `/words` entry point removed — Word Bank is accessible via the Learn tab

## 2.0.3

### Branding & Polish
- **App Icon**: Custom Parler icon across Android, iOS, macOS, and web
- **Repo Renamed**: GitHub repository renamed from `french` to `parler`
- **Web Branding**: Proper title, description, Open Graph tags, PWA manifest, and favicon
- **README**: Complete rewrite reflecting v2.0 features and architecture
- **CI/CD Cleanup**: Removed redundant `flutter create --platforms=web` steps, updated APK naming

## 2.0.2

### Improvements
- **Check for Updates**: Added manual update check button in Profile settings
- **Snooze Dismiss**: "Later" now snoozes for 24 hours instead of permanently hiding the update

## 2.0.1

### Bug Fixes & Polish
- **Missing Back Buttons**: Added back navigation to Words and TEF screens
- **Inline Learn Content**: Word Bank now shows category grid directly, TEF shows test list — no extra tap needed
- **App Name**: Renamed from "french" to "Parler" on Android, iOS, and macOS
- **Update Dialog**: Release notes now render markdown properly using flutter_markdown_plus

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
