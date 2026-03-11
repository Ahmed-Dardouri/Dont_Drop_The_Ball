# Game Mode System - Requirements

## Overview

A modular game mode system for "Don't Drop the Ball" that supports multiple play modes with different win/lose conditions while maintaining the core bounce mechanic.

---

## Functional Requirements

### FR-1: Mode Selection
- Main menu displays "Quick Play" button (default: Classic Endless)
- Main menu displays "Select Mode" button that opens mode picker
- Mode picker shows all 4 modes with brief descriptions
- All modes are unlocked from the start

### FR-2: Classic Endless Mode
- Gameplay continues until ball drops
- All orbs contribute to score
- Tracks high score per session and all-time

### FR-3: Time Attack Mode
- Fixed 2-minute (120 second) time limit
- Gameplay ends when time expires (win) or ball drops (lose)
- Score based on total points collected
- Timer displayed prominently in HUD

### FR-4: Orb Hunt Mode
- Target score must be reached from specific orb types only
- Non-target orbs may spawn but don't contribute to objective
- Win when target score reached, lose if ball drops
- Progress indicator shows % to target

### FR-5: Survival Waves Mode
- Endless waves of increasing difficulty
- Advance to next wave by collecting X orbs
- Difficulty increases: faster spawns + more orbs required
- Score = highest wave reached
- Game over when ball drops

### FR-6: High Score Persistence
- Each mode maintains separate high score
- High scores persist via existing save system
- High scores display in mode selection and game over screen

### FR-7: Mode-Specific HUD
- Display mode badge/icon
- Display one key metric: timer, wave number, or progress %

---

## Technical Requirements

### TR-1: Typed GDScript
- All new code uses typed variables and function signatures
- Follow existing code style conventions

### TR-2: Minimal Changes
- Preserve existing core mechanics (ball physics, player controls)
- Keep diffs small and focused
- No reformatting of unrelated code

### TR-3: Testability
- All deterministic logic must be unit testable
- Integration tests for mode transitions
- Validation via ./devscripts/test.sh

---

## Non-Goals

- Monetization or premium modes
- Online leaderboards
- Mode-specific player abilities or physics changes

---

## Success Criteria

1. All 4 modes playable from main menu
2. Each mode tracks separate high score
3. High scores persist across sessions
4. Mode selection UI is clear and functional
5. HUD displays correct metric for each mode
6. All tests pass: `./devscripts/test.sh`
7. Smoke test passes: `./devscripts/smoke_test.sh`

---

## Game Modes Summary

| Mode | Win Condition | Lose Condition | Score Metric | HUD Display |
|------|---------------|----------------|--------------|-------------|
| **Classic Endless** | N/A (endless) | Ball drops | Total score | Score |
| **Time Attack** | Survive 2 minutes | Ball drops before time | Score in 2 min | Timer countdown |
| **Orb Hunt** | Reach target from specific orbs | Ball drops | Progress % | Percentage |
| **Survival Waves** | N/A (endless) | Ball drops | Waves survived | Wave number |

---

## Key Decisions

- **Mode Selection**: Quick Play + Mode Button (Quick Play = Classic Endless)
- **High Scores**: Separate per mode, persisted via existing save system
- **Orb Pools**: Mode-specific, each mode defines which orbs spawn
- **Unlock System**: All modes unlocked from start
- **HUD**: Mode badge + one key metric (minimal, clean)
