# Requirements Clarification - Game Mode System

## Initial Analysis Complete
The codebase has been analyzed. Key findings:
- Game uses event-based architecture with singletons
- Current "mode" is essentially endless with game over on ball drop
- Orb system is already data-driven and extensible
- UI is minimal but functional

---

## Q&A Session

### Q1: Mode Selection UX
**Question:** How should players select game modes?

**Options considered:**
1. Main Menu Sub-screen - Play button opens a mode selection screen before starting
2. Quick Play + Mode Button - Main menu has both "Quick Play" (default mode) and "Select Mode" button
3. Mode Carousel - Swipeable/scrollable mode cards on main menu

**Answer:** Option 2 - Quick Play + Mode Button

**Rationale:** Keeps casual onboarding simple (one tap to play) while providing access to other modes for interested players.

---

### Q2: Quick Play Default Mode
**Question:** What should "Quick Play" default to?

**Options considered:**
1. Classic Endless - The current behavior (play until ball drops)
2. Last Played Mode - Remember what the player chose last time
3. Always Prompt - Quick Play still shows a simplified mode picker

**Answer:** Option 1 - Classic Endless

**Rationale:** Provides consistent, predictable experience. New players get the simplest mode immediately.

---

### Q3: Time Attack Mode - Duration
**Question:** For Time Attack mode, what should the time limit be?

**Options considered:**
1. Fixed 60 seconds - Simple, consistent duration
2. Fixed 90 seconds - Slightly longer for more gameplay
3. Configurable tiers - Player chooses 30s / 60s / 90s before starting

**Answer:** 2 minutes (120 seconds) - Fixed duration

**Rationale:** Gives players enough time to build meaningful scores while maintaining urgency.

---

### Q4: Orb Hunt Mode - Objective
**Question:** For Orb Hunt mode, what defines the objective?

**Options considered:**
1. Collect X specific orbs - e.g., "Collect 10 blue orbs" then win
2. Collect all orb types - Must collect at least one of each orb type to win
3. Target score from specific orbs - Only certain orbs count toward score, reach target to win

**Answer:** Option 3 - Target score from specific orbs

**Rationale:** Creates focused gameplay where players must prioritize certain orbs while avoiding or ignoring others. Adds strategic depth.

---

### Q5: Fourth Mode Selection
**Question:** Based on the current codebase, which fourth mode would you prefer?

**Options considered:**
1. Combo Mode - Score multiplier builds with consecutive orb collections, resets on miss/drop
2. Target Score - Simple "reach X points to win" mode
3. Survival Waves - Survive increasingly difficult waves of orbs/time pressure

**Answer:** Option 3 - Survival Waves

**Rationale:** Offers progression and variety. Each wave can introduce new challenges. Most engaging for replayability, though more complex to implement.

---

### Q6: Survival Waves - Win/Lose Conditions
**Question:** For Survival Waves, how should waves and progression work?

**Options considered:**
1. Endless Waves - Survive as many waves as possible. Wave N+1 is harder than N. Game over when ball drops. Score = waves survived.
2. Fixed Wave Count - Complete X waves to win. Early exit if ball drops (lose).
3. Timed Waves - Each wave has a time limit. Survive all waves within time or lose.

**Answer:** Option 1 - Endless Waves

**Rationale:** Maintains the "endless" feel of the original game while adding structure. Players compete for highest wave reached. Simpler than managing win states.

---

### Q7: Survival Waves - Difficulty Progression
**Question:** What should increase between waves to make later waves harder?

**Options considered:**
1. Faster orb spawning - Decrease spawn interval each wave
2. More orbs per wave - Increase max orbs or orbs required to advance
3. Combo of both - Faster spawns AND more orbs as waves progress

**Answer:** Option 3 - Combo of both

**Rationale:** Creates meaningful progression. Players feel the intensity increase through both more frequent spawns and higher orb counts.

---

### Q8: Wave Advancement Trigger
**Question:** How does a player advance to the next wave in Survival mode?

**Options considered:**
1. Collect X orbs - Collect N orbs to complete current wave and advance
2. Survive X seconds - Each wave lasts N seconds, then auto-advance
3. Clear all orbs - Collect all currently spawned orbs to advance

**Answer:** Option 1 - Collect X orbs

**Rationale:** Gives players clear, actionable progress indicator. Creates natural rhythm of collection and advancement. Works well with orb-focused gameplay.

---

### Q9: Mode-Specific HUD Elements
**Question:** What additional HUD elements should modes display during gameplay?

**Options considered:**
1. Minimal - Only show current score (like now). Mode info only on mode selection screen.
2. Mode badge + key metric - Show mode name/icon + one key metric (timer for Time Attack, wave number for Survival, target progress for Orb Hunt)
3. Full status panel - Mode name, all relevant metrics, progress bars

**Answer:** Option 2 - Mode badge + key metric

**Rationale:** Provides context without UI clutter. Players know what mode they're in and can track primary objective at a glance.

---

### Q10: High Score Tracking
**Question:** How should high scores work across different modes?

**Options considered:**
1. Separate per mode - Each mode has its own high score (Endless HS, Time Attack HS, etc.)
2. Shared global - One high score across all modes
3. No high scores for non-endless - Only Classic Endless tracks high score; other modes show session score only

**Answer:** Option 1 - Separate per mode

**Rationale:** Fair comparison within each mode. Time Attack scores aren't directly comparable to Survival wave counts. Encourages replay across all modes.

---

### Q11: Mode-Specific Orb Pools
**Question:** Should different modes have different orb spawn configurations?

**Options considered:**
1. Same orbs for all modes - Keep it simple, all modes use the same orb pool
2. Mode-specific pools - Each mode can define which orbs spawn (e.g., Orb Hunt only spawns target orbs + distractors)
3. Same pool, different weights - All orbs available but modes can adjust spawn rarity/weights

**Answer:** Option 2 - Mode-specific pools

**Rationale:** Maximum flexibility for mode design. Orb Hunt can focus on target orbs, Survival can include special challenge orbs. Makes each mode feel distinct.

---

### Q12: High Score Persistence
**Question:** How should mode high scores be saved?

**Options considered:**
1. Extend existing save system - Add mode high scores to current `saved_game.gd` structure
2. New save file - Separate file for mode-specific data
3. In-memory only for now - Persist in future phase

**Answer:** Option 1 - Extend existing save system

**Rationale:** Minimal code changes. Leverages existing `GameSaveMngr` infrastructure. Keeps all player progress in one place.

---

### Q13: Mode Unlock Requirements
**Question:** Should all game modes be available immediately, or should some be unlocked?

**Options considered:**
1. All unlocked from start - All 4 modes available immediately
2. Progressive unlock - Unlock modes by achieving certain scores in previous modes
3. Tutorial gate - Complete a basic tutorial/intro to unlock all modes

**Answer:** Option 1 - All unlocked from start

**Rationale:** Simplest UX for casual players. No barriers to trying different modes. Reduces implementation complexity.

---

## Requirements Summary

### Confirmed Game Modes (4 total)

| Mode | Win Condition | Lose Condition | Primary Metric | Score Basis |
|------|---------------|----------------|----------------|-------------|
| Classic Endless | N/A (endless) | Ball drops | Score | Total points collected |
| Time Attack | Survive 2 min | Ball drops before time | Score | Total points in 2 min |
| Orb Hunt | Reach target score from specific orbs | Ball drops | Progress % | Target orb points only |
| Survival Waves | N/A (endless waves) | Ball drops | Wave number | Waves survived |

### Key Architecture Decisions
- Mode selection via Quick Play + Mode Button on main menu
- Quick Play defaults to Classic Endless
- Mode-specific orb pools
- Separate high scores per mode
- Extend existing save system for persistence
- All modes unlocked from start
- HUD shows mode badge + one key metric

### Technical Constraints
- Preserve core bounce mechanic
- Keep diffs small
- Typed GDScript
- Validate via ./devscripts/test.sh

