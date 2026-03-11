---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: HUD Mode Display

## Description
Update the HUD to display mode-specific information including mode badge and current metric. Each mode shows its relevant gameplay metric (score, timer, progress, wave).

## Background
The HUD currently shows score and basic game info. This task adds a mode badge showing the current mode name and a dynamic metric display that changes based on the active mode. The metric format varies: score (number), timer (MM:SS), progress (X/Y or %), wave (number).

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 2 Architecture - HUD)

**Additional References:**
- specs/game-mode-system/context.md (Metric formats per mode)
- specs/game-mode-system/plan.md (Step 11 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scenes/hud.tscn`:
   - Add mode badge label (top-left or top-center)
   - Add metric display label (score area or separate)
   - Adjust layout for new elements
2. Modify `scripts/hud.gd`:
   - Subscribe to `ModeManager.mode_started` to update badge
   - Subscribe to `ModeManager.metric_updated` to update metric
   - Implement metric formatting:
     - "score": just the number
     - "timer": format as MM:SS from seconds
     - "progress": format as "X / Y" or percentage
     - "wave": just the number with "Wave" prefix
3. Update metric on each frame or when ModeManager emits signal

## Dependencies
- Task 04: Integrate ModeManager with Game Flow (needs ModeManager signals)

## Implementation Approach
1. **TDD: Write failing test first**
   - Manual verification for UI (visual element)
   - Unit test for metric formatting functions
2. **Implement minimal code to pass**
   - Add UI elements to hud.tscn
   - Update hud.gd with mode display logic
3. **Refactor while keeping tests green**
   - Polish visual layout
   - Ensure metric updates smoothly

## Acceptance Criteria

1. **Mode Badge Displays**
   - Given a mode is started
   - When the HUD updates
   - Then the mode badge shows the mode's display_name

2. **Score Metric Format**
   - Given Endless mode is active with score 500
   - When the HUD updates
   - Then metric displays "500"

3. **Timer Metric Format**
   - Given Time Attack mode is active with 90 seconds remaining
   - When the HUD updates
   - Then metric displays "1:30"

4. **Progress Metric Format**
   - Given Orb Hunt mode is active with progress 50/100
   - When the HUD updates
   - Then metric displays "50 / 100" or "50%"

5. **Wave Metric Format**
   - Given Survival mode is active at wave 3
   - When the HUD updates
   - Then metric displays "Wave 3"

6. **Demo Works**
   - Given each mode is played
   - When observing the HUD
   - Then the correct metric format is shown for each mode

## Metadata
- **Complexity**: Low
- **Labels**: ui, hud, display
- **Required Skills**: GDScript, Godot UI, Formatting
