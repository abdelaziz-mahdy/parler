# Parler - French Learning App

A comprehensive French learning app built with Flutter, featuring structured lessons, vocabulary flashcards with spaced repetition, TEF exam preparation, and interactive quizzes.

## Features

### Lessons
- 10 structured chapters covering French fundamentals (pronunciation, grammar, vocabulary, verbs, etc.)
- Interactive lesson content with examples and audio pronunciation
- Progress tracking per chapter with completion status

### Vocabulary (Words)
- 666 words across 25 categories and 4 CEFR levels (A1-B2)
- Flashcard learning with flip-to-reveal and TTS pronunciation
- SM-2 spaced repetition algorithm for optimal review scheduling
- Daily review reminders for due cards
- Category browser with level breakdown and progress tracking

### TEF Test Simulator
- Practice tests modeled after the real TEF Canada Comprehension ecrite format
- 3 complete tests with 60 reading comprehension questions
- Timed sessions with countdown timer
- NCLC level estimation based on score
- Question-by-question flow with explanations

### Quizzes
- Chapter-based multiple choice quizzes
- Score tracking with best score history
- Explanations for each answer

### Daily Learning Path
- "Today" section showing personalized daily tasks
- Streak tracking with motivational messages
- Smart suggestions: due reviews, next chapter, quiz recommendations
- Circular progress ring for daily goals

### Additional Features
- Dark mode with French-inspired color palette
- Text-to-speech pronunciation (fr-FR)
- Offline-first: all content bundled as JSON assets
- Progress persistence via SharedPreferences

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter (Dart ^3.10.8) |
| State Management | Riverpod v3 (Notifier pattern) |
| Routing | go_router with ShellRoute |
| Typography | Google Fonts (Playfair Display, Inter) |
| Animations | flutter_animate |
| Audio | flutter_tts (fr-FR) |
| Storage | SharedPreferences |
| Spaced Repetition | SM-2 algorithm |

## Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Dart ^3.10.8

### Setup
```bash
git clone <repo-url>
cd french
flutter pub get
flutter run
```

### Running Tests
```bash
flutter test
```

### Building

**Android APK:**
```bash
flutter build apk --release
```

**Web:**
```bash
flutter build web --release
```

## Project Structure

```
lib/
  core/
    constants/     # Colors, adaptive colors, icon mappings
    router/        # go_router configuration with ShellRoute
  models/          # Data models (manual fromJson/toJson)
  providers/       # Riverpod providers (data, progress, theme)
  repositories/    # DataRepository for JSON asset loading
  screens/
    lessons/       # Lesson list + detail screens with Today section
    words/         # Category browser, flashcards, vocab quiz
    tef/           # TEF test list + play screens
    quiz/          # Quiz list + play screens
    splash/        # Splash screen
  services/        # Spaced repetition, TTS service
  widgets/         # Reusable widgets (FrenchCard, SpeakerButton, etc.)
assets/
  data/            # JSON data files (chapters, vocabulary, TEF tests, etc.)
```

## CI/CD

GitHub Actions workflows are included:

- **CI** (`ci.yml`): Runs `dart analyze` + `flutter test` on every push/PR
- **Build** (`build.yml`): Builds APK and web on version tags (`v*`)
- **Release** (`release.yml`): Attaches APK to GitHub releases, deploys web to Pages
- **Deploy Web** (`deploy-web.yml`): Auto-deploys web build to GitHub Pages on push to main

### Downloads

Once CI/CD is configured with a GitHub remote:
- **APK**: Available as release assets on the Releases page
- **Web**: Deployed to GitHub Pages automatically

## Design

French-inspired color palette:
- Navy `#1B2A4A` - Primary dark color
- Red `#E63946` - Accent / active states
- Gold `#D4A574` - Highlights / streak
- Cream `#F1FAEE` - Light backgrounds

Dark mode uses `#121212` / `#1E1E1E` / `#2C2C2C` with adaptive color extensions.

## License

This project is for personal/educational use.
