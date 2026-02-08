# French Language Learning App - Project Conventions

## Overview
A Flutter app that teaches French to English speakers, based on the "French Language Tips, Tricks & Shortcuts" reference document. Designed for learners preparing for NCLC 5 / TEF exams, with a focus on practical spoken French.

## Architecture

### State Management
- **Riverpod** (`flutter_riverpod`) for all state management
- Use `@riverpod` annotation-based providers where possible
- Keep providers in dedicated files under `lib/providers/`

### Navigation
- **GoRouter** (`go_router`) for declarative routing
- Route definitions in `lib/router/`
- Bottom navigation with 5 tabs: Home, Lessons, Word Bank, Quizzes, Profile

### Data Layer
- JSON data files in `assets/data/`
- Data models in `lib/models/` using `json_annotation`
- Repository pattern in `lib/repositories/` for loading/caching
- Local persistence via `shared_preferences`

### Project Structure
```
lib/
  main.dart
  app.dart                    # App widget with theme & router
  router/
    app_router.dart           # GoRouter configuration
  theme/
    app_theme.dart            # Material 3 theme definition
    app_colors.dart           # French-inspired color palette
  models/                     # Data classes with JSON serialization
  providers/                  # Riverpod providers
  repositories/               # Data loading & caching
  screens/                    # Full-page screens
    home/
    lessons/
    quiz/
    word_bank/
    profile/
  widgets/                    # Reusable UI components
assets/
  data/                       # JSON content files
docs/
  french_content.txt          # Source reference document
```

## Design System

### Color Palette (French-inspired)
- **Primary / Navy**: Deep navy blue (inspired by the French tricolore)
- **Accent / Red**: French red for emphasis, errors, important items
- **Highlight / Gold**: Gold for achievements, streaks, progress
- **Surface**: Clean whites and light grays
- **Text**: Dark navy for primary, medium gray for secondary

### Typography
- Use `google_fonts` package
- Headlines: A distinctive serif or display font
- Body: Clean sans-serif for readability
- French text: Consider italic or distinct styling to differentiate from English

### Components
- Custom cards with subtle elevation and rounded corners (12-16dp radius)
- Touch targets minimum 48x48dp (Material accessibility guideline)
- Consistent spacing using 8dp grid system
- Animations via `flutter_animate` - subtle, purposeful, not distracting

## Content Structure (from Reference Document)

The app covers 10 chapters from the source document:
1. **Cognates & Suffix Patterns** - 16 suffix conversion patterns, ~3000-5000 instant vocabulary
2. **Pronunciation** - Golden rules, vowel sounds, nasal vowels, consonant tricks, CaReFuL rule
3. **Gender Rules** - 8 feminine endings, 7 masculine endings, survival strategy
4. **Verb Conjugation** - 27 essential verbs, -er verb patterns, future/past shortcuts
5. **Essential Grammar** - Negation, questions, articles, contractions
6. **Numbers** - 1-69 straightforward, 70-99 math system, Belgian/Swiss variants
7. **False Friends** - 11 false friend pairs with danger levels
8. **Liaison & Connected Speech** - Mandatory liaisons, sound changes, elision
9. **Survival Phrases** - 40+ phrases across basics, communication, daily life
10. **TEF/TCF Speaking Tricks** - Filler words, opinion structures, recovery strategies

## Data Accuracy Requirements

All JSON data MUST match the reference document (`docs/french_content.txt`) exactly:
- Suffix patterns: 16 patterns with correct English/French endings, examples, and notes
- Pronunciation rules: All vowel sounds, nasal vowels, consonant rules as documented
- Gender rules: Exact accuracy percentages (e.g., -tion/-sion is ~99% feminine)
- Verbs: All 27 verbs from the 80/20 list with correct meanings
- False friends: All entries with correct danger levels
- Phrases: All 40+ survival phrases with correct French/English pairs
- Numbers: Complete 0-100 system including the 70-99 math explanation

## Coding Conventions

### Dart Style
- Follow official Dart style guide and `flutter_lints` rules
- Use `const` constructors wherever possible
- Prefer named parameters for widget constructors
- File names: `snake_case.dart`
- Class names: `PascalCase`
- Variables/methods: `camelCase`
- Private members: prefix with `_`

### Widget Organization
- One primary widget per file
- Extract sub-widgets as private classes in the same file when small
- Move to separate files when reused or exceeding ~100 lines

### Testing
- Widget tests in `test/` mirroring `lib/` structure
- Test file naming: `<feature>_test.dart`

## Key Dependencies
- `flutter_riverpod: ^3.2.1` - State management
- `go_router: ^17.1.0` - Navigation
- `google_fonts: ^8.0.1` - Typography
- `flutter_animate: ^4.5.2` - Animations
- `shared_preferences: ^2.5.4` - Local storage
- `json_annotation: ^4.10.0` - JSON serialization

## Review Checklist (for PRs)
- [ ] Follows project file structure
- [ ] Uses Riverpod for state (no raw setState except local UI state)
- [ ] Navigation uses GoRouter routes
- [ ] Touch targets >= 48x48dp
- [ ] Text contrast meets WCAG AA (4.5:1 for normal text)
- [ ] French content matches reference document exactly
- [ ] No hardcoded strings that should be in data files
- [ ] Animations are subtle and have purpose
- [ ] Works on both iOS and Android
