# Evaluation Criteria for French Learning App

## 1. UI/UX Review Criteria

### 1.1 Material Design 3 Compliance
- [ ] Uses Material 3 color scheme (ColorScheme.fromSeed or custom M3 palette)
- [ ] Proper use of Material 3 components (FilledButton, OutlinedButton, etc.)
- [ ] Correct elevation and surface tinting
- [ ] Typography scale follows M3 type system
- [ ] Proper use of Material 3 navigation components

### 1.2 Accessibility
- [ ] Touch targets >= 48x48dp on all interactive elements
- [ ] Text contrast ratio >= 4.5:1 for normal text (WCAG AA)
- [ ] Text contrast ratio >= 3:1 for large text (WCAG AA)
- [ ] Font scaling support (no fixed pixel sizes that break with system font scaling)
- [ ] Semantic labels on all icons and images
- [ ] Screen reader compatibility (Semantics widgets where needed)
- [ ] No information conveyed by color alone (use icons/text alongside)

### 1.3 Navigation Flow
- [ ] Bottom navigation is always visible on main screens
- [ ] Current tab is clearly indicated
- [ ] Back navigation behaves intuitively
- [ ] Deep links work (GoRouter configured correctly)
- [ ] No dead-end screens (always a way to navigate away)
- [ ] Loading states shown during data fetch
- [ ] Error states have retry actions

### 1.4 Visual Hierarchy
- [ ] Clear distinction between headings, body text, and metadata
- [ ] Important actions are visually prominent
- [ ] Secondary actions are visually subordinate
- [ ] Consistent spacing and alignment
- [ ] Information density appropriate per screen (not too crowded, not too sparse)

### 1.5 Animations
- [ ] Animations have clear purpose (guide attention, show state change)
- [ ] Duration appropriate (150-300ms for most transitions)
- [ ] No jarring or distracting motion
- [ ] Reduced motion preference respected
- [ ] Page transitions feel smooth and natural

### 1.6 Color Consistency
- [ ] French-inspired palette used consistently throughout
- [ ] Color usage is semantically meaningful (red = errors/important, gold = achievements)
- [ ] Dark/light mode considerations
- [ ] Sufficient contrast on all color combinations

## 2. Data Accuracy Criteria

### 2.1 Suffix Patterns (Chapter 1)
Expected: 16 patterns
| # | English Ending | French Ending | Must verify: examples, notes |
|---|---|---|---|
| 1 | -tion | -tion | nation, information, situation, education, revolution |
| 2 | -sion | -sion | television, decision, passion, version, mission |
| 3 | -ment | -ment | moment, apartment, document, government, department |
| 4 | -ous | -eux/-euse | famous->fameux, dangerous->dangereux, curious->curieux |
| 5 | -ty | -te | university->universite, quality->qualite, city->cite, liberty->liberte |
| 6 | -al | -al/-el | normal, final, national, international, animal, capital |
| 7 | -ble | -ble | possible, table, terrible, comfortable, flexible, visible |
| 8 | -ary/-ery | -aire | necessary->necessaire, ordinary->ordinaire, military->militaire |
| 9 | -ence/-ance | -ence/-ance | difference, silence, distance, importance, intelligence |
| 10 | -ic | -ique | music->musique, public->publique, fantastic->fantastique |
| 11 | -ism | -isme | tourism->tourisme, capitalism->capitalisme, optimism->optimisme |
| 12 | -ist | -iste | artist->artiste, tourist->touriste, dentist->dentiste |
| 13 | -ly | -ment | normally->normalement, exactly->exactement, rapidly->rapidement |
| 14 | -ive | -if/-ive | active->actif/active, positive->positif/positive |
| 15 | -ure | -ure | nature, culture, structure, adventure, temperature |
| 16 | -age | -age | garage, message, village, image, voyage |

### 2.2 Pronunciation Rules (Chapter 2)
- 3 golden rules (silent finals, last syllable stress, nasal vowels)
- 10 vowel sound entries
- 3 nasal vowel categories + the nasal trick
- 10 consonant rules
- CaReFuL rule with examples for C, R, F, L

### 2.3 Gender Rules (Chapter 3)
- 8 feminine endings with accuracy percentages
- 7 masculine endings with accuracy percentages
- Exception examples where noted (la plage, l'eau, etc.)

### 2.4 Verbs (Chapter 4)
- 27 essential verbs with correct meanings
- -er verb conjugation table (6 subjects x pattern)
- Future tense cheat (aller + infinitive examples)
- Passe compose formula + DR MRS VANDERTRAMP verbs (16 verbs)
- Past participle shortcuts (-er->-e, -ir->-i, -re->-u)

### 2.5 Grammar (Chapter 5)
- Negation pattern (ne...pas) with spoken shortcut
- 3 question formation methods
- 7 question words with examples and pronunciation
- Articles table (definite, indefinite, before vowel)
- 6 mandatory contractions

### 2.6 Numbers (Chapter 6)
- Numbers 0-19 individually
- Tens 20-60
- Compound examples (21, 22, 31, 32)
- The 70-99 system with explanation
- Belgian/Swiss alternatives (septante, huitante/octante, nonante)

### 2.7 False Friends (Chapter 7)
- 11 false friend entries
- Each with: French word, looks like, actually means, danger level, English equivalent
- Danger levels: LOW, MEDIUM, HIGH, VERY HIGH, FUNNY

### 2.8 Liaison Rules (Chapter 8)
- 4 mandatory liaison categories with examples
- 4 liaison sound changes (s/x->Z, d->T, n->N, t->T)
- 5 elision examples

### 2.9 Survival Phrases (Chapter 9)
- 7 basic greetings/courtesies
- 7 communication lifeline phrases
- 7 daily life/work phrases

### 2.10 TEF Tricks (Chapter 10)
- 8 filler words with meanings and usage
- 6 opinion structures
- 5 recovery strategies

## 3. Learning Experience Criteria

### 3.1 Lesson Ordering
- [ ] Progresses from most accessible to more complex
- [ ] Chapter 1 (cognates) first - builds confidence with existing knowledge
- [ ] Pronunciation early so learners can sound out words
- [ ] Grammar builds on vocabulary already introduced
- [ ] Practical phrases available early for immediate usefulness

### 3.2 Quiz Design
- [ ] Questions test recognition AND production
- [ ] Multiple question types (multiple choice, matching, fill-in-blank, audio)
- [ ] Difficulty scales within each topic
- [ ] Incorrect answers provide helpful explanations
- [ ] Questions reference material from the lessons (not external knowledge)

### 3.3 Spaced Repetition
- [ ] SM-2 or similar algorithm implemented correctly
- [ ] New items introduced at reasonable rate
- [ ] Review intervals increase with mastery
- [ ] Difficult items surface more frequently
- [ ] User can see their review schedule

### 3.4 Progress Tracking
- [ ] Clear visual progress per lesson/chapter
- [ ] Overall mastery percentage
- [ ] Streak tracking for engagement
- [ ] Words mastered count
- [ ] Quiz score history

## 4. Code Quality Criteria

### 4.1 File Organization
- [ ] Follows project structure defined in CLAUDE.md
- [ ] One primary widget per file
- [ ] Models, providers, repositories properly separated
- [ ] No circular dependencies

### 4.2 Naming Conventions
- [ ] Files: snake_case.dart
- [ ] Classes: PascalCase
- [ ] Variables/methods: camelCase
- [ ] Constants: camelCase or SCREAMING_SNAKE for compile-time constants
- [ ] Descriptive names (not abbreviated beyond common patterns)

### 4.3 State Management
- [ ] Riverpod used consistently (no raw setState except for local UI animation state)
- [ ] Providers are appropriately scoped
- [ ] No unnecessary rebuilds
- [ ] Async state handled with AsyncValue

### 4.4 Separation of Concerns
- [ ] UI code does not contain business logic
- [ ] Data transformation in repositories/providers, not widgets
- [ ] JSON parsing in model classes
- [ ] Navigation logic in router, not scattered in widgets
