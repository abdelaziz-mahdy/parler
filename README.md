# Parler - Learn French Naturally

A modern French learning app built with Flutter. Parler uses spaced repetition (FSRS algorithm) and session-based learning to help English speakers build practical French skills for daily life and TEF/NCLC exams.

**[Try the Web App](https://abdelaziz-mahdy.github.io/parler/)** | **[Download APK](https://github.com/abdelaziz-mahdy/parler/releases/latest)**

## What Makes Parler Different

- **Session-first design** — open the app, tap "Start Session", and get a personalized practice mix of review, new content, and mixed exercises
- **FSRS spaced repetition** — the same modern algorithm used by Anki, 20-30% more efficient than SM-2
- **Multi-mode quizzes** — French→English, English→French, and fill-in-the-blank (cloze) to keep learning engaging
- **Smart distractors** — quiz options come from the same word category so you can't guess by elimination
- **Post-answer context** — after every question, see the example sentence, memory hint, and related words
- **Matching game** — end each session with a fun matching challenge connecting French↔English pairs
- **Auto-play TTS** — French words are spoken automatically during sessions

## Features

### Daily Sessions
- 3-phase practice: review due words → learn new content → mixed practice
- Configurable session length: Casual (5 min), Regular (10 min), Intense (15 min)
- Streak tracking with streak freeze rewards (earn 1 every 7-day streak, max 2)

### 10 Structured Chapters
1. Cognates & Suffix Patterns (16 patterns, ~3000-5000 instant vocabulary)
2. Pronunciation (golden rules, vowel sounds, nasal vowels, CaReFuL rule)
3. Gender Rules (8 feminine / 7 masculine endings with accuracy percentages)
4. Verb Conjugation (27 essential verbs, -er patterns, future/past shortcuts)
5. Essential Grammar (negation, questions, articles, contractions)
6. Numbers (1-100 including the 70-99 math system)
7. False Friends (11 pairs with danger levels)
8. Liaison & Connected Speech (mandatory liaisons, elision)
9. Survival Phrases (40+ phrases for basics, communication, daily life)
10. TEF/TCF Speaking Tricks (filler words, opinion structures, recovery strategies)

### Vocabulary
- 873 words across 25+ categories and 4 CEFR levels (A1-B2)
- Words mastered count based on FSRS stability (>30 days retention)
- Chapter mastery based on both content completion and vocabulary retention

### TEF Test Prep
- Practice tests modeled after TEF Canada Comprehension ecrite
- 3 complete tests with 60 reading comprehension questions
- NCLC level estimation based on score

### More
- Dark mode with French-inspired color palette
- Text-to-speech with adjustable speed (slow/normal)
- Auto-update notifications with in-app download (Android)
- Offline-first: all content bundled locally
- Desktop-friendly responsive layouts

## Screenshots

| Today | Session | Learn |
|-------|---------|-------|
| Daily overview with streak, mastery stats, and chapter roadmap | Multi-mode quiz with post-answer context | Browse chapters, word bank, and TEF prep |

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x (Dart ^3.10.8) |
| State Management | Riverpod v3 (Notifier pattern) |
| Routing | go_router with ShellRoute |
| Database | Drift (SQLite) for card states & review logs |
| Spaced Repetition | FSRS algorithm |
| Typography | Google Fonts (Playfair Display, Inter) |
| Animations | flutter_animate |
| TTS | flutter_tts (fr-FR) |

## Getting Started

```bash
git clone https://github.com/abdelaziz-mahdy/parler.git
cd parler
flutter pub get
flutter run
```

### Running Tests
```bash
flutter test
```

### Building

```bash
# Android APK
flutter build apk --release

# Web
flutter build web --release
```

## Project Structure

```
lib/
  core/
    constants/     # Colors, adaptive colors, icon mappings
    router/        # go_router configuration with ShellRoute
  models/          # Data models (manual fromJson/toJson)
  providers/       # Riverpod providers (data, progress, theme, database)
  screens/
    home/          # Today tab — streak, session preview, chapter roadmap
    learn/         # Learn tab — chapters, word bank, TEF prep
    profile/       # Profile tab — stats, settings, chapter mastery
    session/       # Session flow — quiz, matching game, completion
    words/         # Word detail screen
    tef/           # TEF test play screen
  services/        # FSRS, TTS, update service
  widgets/         # Reusable components (FrenchCard, StatBadge, etc.)
assets/
  data/            # JSON content files (chapters, vocabulary, TEF tests)
  icon/            # App icon source files
```

## CI/CD

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| CI | Push / PR | `dart analyze` + `flutter test` |
| Release | `v*` tag | Creates GitHub Release, builds APK, deploys web to Pages |
| Deploy Web | Push to main | Deploys web build to GitHub Pages |
| Build | Manual | Builds APK (universal + split) and web artifacts |

## Design

French-inspired color palette:
- Navy `#1B2A4A` — primary
- Red `#E63946` — accent / active states
- Gold `#D4A574` — highlights / achievements
- Cream `#F1FAEE` — light backgrounds

## License

This project is for personal and educational use.
