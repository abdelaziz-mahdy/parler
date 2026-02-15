# Session-First Redesign — Design Document

**Date:** 2026-02-15
**Status:** Approved

## Problem Statement

The current app requires users to self-direct their learning: pick chapters, choose flashcard categories, rate their own recall (Easy/Good/Hard/Again). This creates decision fatigue, unreliable self-assessment, and low engagement. Users want to open the app and be told what to do today.

## Design Decisions

| Decision | Choice |
|----------|--------|
| Learning path | Guided but flexible — recommended order, not locked |
| Session length | User-configurable: Casual (5min), Regular (10min), Intense (15min) |
| Review style | Quiz-style (4 English options for French word) — no self-rating |
| Navigation | 3 tabs: Today / Learn / Profile |
| Gamification | Streak + Words Mastered only (XP removed) |
| SRS algorithm | FSRS replacing SM-2 |

---

## 1. FSRS Algorithm (replacing SM-2)

Replace `lib/services/spaced_repetition.dart` with FSRS (Free Spaced Repetition Scheduler).

### Card State Model

```
CardState {
  stability: double      // days until 90% recall probability
  difficulty: double     // 1-10, card-intrinsic difficulty
  lastReview: DateTime   // when last reviewed
  nextReview: DateTime   // scheduled next review
  reps: int             // total successful reviews
  lapses: int           // times forgotten (rating = Again)
  state: enum           // new / learning / review / relearning
}
```

### Core Formula

- Retrievability: `R = (1 + t/(9*S))^(-1)` where t = elapsed days, S = stability
- Next review scheduled when R drops to desired retention (default 90%)
- 19 default parameters (w[0]-w[18]), optimizable per-user after ~1000 reviews

### Review Flow

1. Card shows French word + TTS auto-plays
2. User picks from 4 English options (multiple choice)
3. Correct → FSRS records "Good" (rating 3), stability increases
4. Wrong → FSRS records "Again" (rating 1), stability resets
5. Response time tracked as supplementary data

### Review Log (new — stored for future optimization)

```
ReviewLog {
  cardId: String
  timestamp: DateTime
  rating: int           // 1 (Again) or 3 (Good)
  elapsedDays: double
  responseTimeMs: int
  stability: double     // at time of review
  difficulty: double    // at time of review
}
```

### Overdue Handling

- Cap daily reviews at 30 cards
- Prioritize by lowest retrievability (most at risk of being forgotten)
- Spread overflow across subsequent days

### Migration from SM-2

On first launch after update, convert existing SM-2 data:
- High ease_factor → high initial stability
- Cards with many reps get proportionally higher stability
- All existing review history preserved

---

## 2. Daily Session Engine

### 3-Phase Structure

**Phase 1: Review (warm-up)**
- FSRS-due cards, lowest retrievability first
- Quiz-style: French word + TTS auto-play → pick English from 4 options
- Correct/wrong is the only signal — no self-rating
- Fast pace, card-after-card

**Phase 2: New Content (lesson bite)**
- Next unlearned section from current chapter
- 3-5 new vocabulary items OR 1 grammar/rule concept
- Each new word: French + TTS + English + example sentence
- Immediate mini-quiz on the new items

**Phase 3: Mixed Practice**
- Questions interleaving new items from Phase 2 with older material
- Multiple choice format
- Interleaving proven to strengthen long-term retention

### Session Sizing

| Setting | Review cards | New items | Mixed questions | ~Duration |
|---------|-------------|-----------|----------------|-----------|
| Casual | 5 | 3 | 3 | ~5 min |
| Regular | 10 | 5 | 5 | ~10 min |
| Intense | 15 | 8 | 8 | ~15 min |

### Adaptive Balance Over Time

- Early (Chapters 1-2): 20% review, 80% new
- Mid (Chapters 4-6): 50/50
- Late (Chapters 8-10): 70% review, 30% new

### Edge Cases

- No reviews due → skip Phase 1, start with new content
- All chapters complete → pure review session
- User returns after days off → capped review with gradual catch-up

### Session Completion

Clear "Session Complete" screen showing:
- Words reviewed count
- New items learned
- Current streak (with fire animation)
- "Words Mastered" running total
- "Done for today" button

---

## 3. Navigation & Screens

### 3-Tab Structure

**Tab 1: "Today" (Home — default landing)**
- Streak banner (flame icon + day count + freeze indicator)
- "Start Session" button — large, prominent, primary CTA
- Session preview: "Today: 8 reviews + 4 new words + quiz"
- Words Mastered counter: "You know 342 French words"
- Chapter roadmap mini-view — horizontal scroll showing position

**Tab 2: "Learn" (Browse)**
- Chapter list — all 10 visible, current highlighted with "Recommended" badge
- Within chapters: sections, vocabulary, rules (browsable)
- Word Bank — all vocabulary by category with search
- TEF Practice — exam prep tests

**Tab 3: "Profile"**
- Stats: streak, words mastered, chapters completed, total reviews
- Chapter mastery bars (FSRS retention-based, not just completion)
- Settings: session length, TTS speed, dark mode, streak freeze
- Weekly summary chart

### Removed

- 4-tab structure (Lessons/Words/TEF/Quiz)
- Flashcard screen with Easy/Good/Hard/Again
- Old "Daily Tasks" widget
- XP system

---

## 4. Audio & TTS

### Auto-play Rules

| Context | Behavior |
|---------|----------|
| Review card appears (Phase 1) | Auto-play French word |
| New word introduction (Phase 2) | Auto-play on reveal |
| Example sentences | Manual tap |
| Quiz question with French text | Auto-play once |
| Learn tab / Word Bank browsing | Manual tap only |
| Lesson content (rules, grammar) | Manual tap only |

### Speed Control

- User setting: Slow (rate 0.35) / Normal (rate 0.50)
- Stored in SharedPreferences
- Quick toggle icon in session top bar

### TtsService Changes

- Add `speakAuto(text)` — plays immediately, respects speed setting
- Existing `speakOnTap(text)` unchanged for SpeakerButton

---

## 5. Gamification & Progress

### Streak (enhanced)

- Session completion = streak day counted
- Streak Freeze: earn 1 per 7 consecutive days (max 2 stored)
- Streak Recovery: 24-hour grace period after break
- Visual: fire icon grows at milestones (7, 30, 60, 100 days)

### Words Mastered (replaces XP)

- Word is "mastered" when FSRS stability > 30 days
- Displayed on Today tab: "You know 342 French words"
- Can un-master if stability drops after failed reviews (keeps it honest)

### Chapter Mastery

- Two-factor mastery percentage:
  - Content completion (sections read) — 50% weight
  - Vocabulary retention (average FSRS retrievability) — 50% weight
- Prevents speedrunning without retention

### Removed

- XP points
- Quiz attempt counters as primary metric

---

## 6. Storage & Data Model Changes

### Storage Migration: SharedPreferences → Drift (SQLite)

**Why:** Review logs accumulate over time (potentially thousands of entries). SharedPreferences stores everything as a single JSON string — too slow, no querying, risk of corruption. Drift provides type-safe SQLite with reactive streams that integrate cleanly with Riverpod.

**Drift configuration:**
- Package: `drift` + `drift_dev` (build_runner for code generation)
- **Web support:** `drift/web.dart` with `sql.js` (SQLite compiled to WASM). Use `WasmDatabase` for web, `NativeDatabase` for mobile/desktop. Platform-conditional factory.
- Database file: `parler.db`

### Database Tables

```sql
-- FSRS state per vocabulary card
CREATE TABLE card_states (
  card_id TEXT PRIMARY KEY,
  stability REAL NOT NULL DEFAULT 0,
  difficulty REAL NOT NULL DEFAULT 5.0,
  last_review INTEGER,          -- epoch ms
  next_review INTEGER,          -- epoch ms
  reps INTEGER NOT NULL DEFAULT 0,
  lapses INTEGER NOT NULL DEFAULT 0,
  state TEXT NOT NULL DEFAULT 'new'  -- new/learning/review/relearning
);

-- Every review interaction (append-only, for FSRS optimization)
CREATE TABLE review_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  card_id TEXT NOT NULL,
  timestamp INTEGER NOT NULL,    -- epoch ms
  rating INTEGER NOT NULL,       -- 1 (Again) or 3 (Good)
  elapsed_days REAL NOT NULL,
  response_time_ms INTEGER,
  stability REAL NOT NULL,       -- at time of review
  difficulty REAL NOT NULL,      -- at time of review
  FOREIGN KEY (card_id) REFERENCES card_states(card_id)
);

-- User preferences and progress (small, key-value style)
CREATE TABLE user_prefs (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Chapter progress
CREATE TABLE chapter_progress (
  chapter_id TEXT PRIMARY KEY,
  sections_completed TEXT NOT NULL DEFAULT '[]',  -- JSON array of section IDs
  mastery_percent REAL NOT NULL DEFAULT 0
);
```

### What stays in SharedPreferences

Only lightweight, non-queryable preferences:
- `sessionLength` (casual/regular/intense)
- `ttsSpeed` (slow/normal)
- `themeMode` (light/dark)
- `streak`, `lastStudyDate`, `streakFreezes`, `lastStreakFreezeEarned`

### What moves to Drift

- All card states (FSRS data) → `card_states` table
- All review logs → `review_logs` table
- Chapter progress → `chapter_progress` table

### Migration from current SharedPreferences data

On first launch after update:
1. Read existing UserProgress JSON from SharedPreferences
2. Convert SM-2 card data to FSRS initial states and insert into `card_states`
3. Convert chapter progress into `chapter_progress` rows
4. Delete migrated data from SharedPreferences
5. Mark migration complete with a `migration_v2_done` flag in SharedPreferences

### Drift + Riverpod Integration

- `AppDatabase` singleton provided via Riverpod provider
- DAOs (CardStateDao, ReviewLogDao, ChapterProgressDao) as separate providers
- Drift's `.watch()` streams wrapped in `StreamProvider` for reactive UI updates
- Example: `dueCardsProvider` watches `card_states` where `next_review <= now`

---

## 7. Implementation Team

| Agent | Role | Responsibilities |
|-------|------|-----------------|
| **lead** | Coordinator | Task assignment, integration, conflict resolution |
| **algo-dev** | Algorithm Developer | FSRS service, session engine, migration logic |
| **ui-dev** | UI/Screen Developer | Today tab, session screens, navigation, profile |
| **data-dev** | Data & State Developer | Drift DB setup (with web support), models, providers, migration from SharedPreferences, TTS upgrades |
| **reviewer** | Code Reviewer | Reviews each piece for correctness and consistency |

Parallel work: algo-dev and ui-dev work simultaneously. Reviewer checks each deliverable before integration.
