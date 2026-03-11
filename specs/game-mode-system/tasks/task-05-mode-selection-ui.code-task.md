---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Mode Selection UI

## Description
Create the mode selection screen where players can choose between available game modes. This includes the scene file, the script, and integration with the main menu.

## Background
The main menu currently has a Play button that starts endless mode. This task adds a mode selection screen between the menu and gameplay, allowing players to choose their preferred mode. The UI should match the existing game aesthetic and be simple to navigate.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 2 Architecture - UI Layer)

**Additional References:**
- specs/game-mode-system/context.md (Enums to Add - MainButtonType.SELECT_MODE)
- specs/game-mode-system/plan.md (Step 5 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scenes/mode_selection.tscn` with:
   - Title label "Select Mode"
   - 4 mode buttons (Endless, Time Attack, Orb Hunt, Survival)
   - Back button to return to main menu
2. Create `scripts/mode_selection.gd` to handle:
   - Button clicks for each mode
   - Calling `ModeManager.start_mode(mode_id)` then switching to game scene
   - Back button navigation
3. Modify `scripts/main_menu.gd`:
   - Add "Select Mode" button (rename Play to Quick Play or keep both)
   - Add SELECT_MODE to Enums.MainButtonType
   - Navigate to mode_selection scene
4. Modify `scripts/utils/enums.gd`:
   - Add `enum PlayMode { ENDLESS, TIME_ATTACK, ORB_HUNT, SURVIVAL }`
   - Add `SELECT_MODE` to `MainButtonType`

## Dependencies
- Task 02: ModeManager Singleton Core (needs ModeManager.start_mode)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_mode_selection.gd` with basic UI tests
   - Manual verification for UI appearance
2. **Implement minimal code to pass**
   - Create mode_selection scene and script
   - Add enum values
   - Modify main_menu.gd
3. **Refactor while keeping tests green**
   - Polish UI layout
   - Ensure navigation works correctly

## Acceptance Criteria

1. **Mode Selection Scene Exists**
   - Given the mode_selection scene is created
   - When loading it
   - Then it displays 4 mode buttons and a back button

2. **Mode Buttons Work**
   - Given the mode selection screen is shown
   - When clicking "Time Attack" button
   - Then ModeManager.start_mode("time_attack") is called and game scene loads

3. **Back Button Works**
   - Given the mode selection screen is shown
   - When clicking "Back" button
   - Then the main menu scene loads

4. **Main Menu Integration**
   - Given the main menu is shown
   - When clicking "Select Mode" button
   - Then the mode selection scene loads

5. **Demo Works**
   - Given the game is launched
   - When clicking Select Mode, choosing a mode
   - Then game starts with that mode active

## Metadata
- **Complexity**: Medium
- **Labels**: ui, scenes, navigation
- **Required Skills**: GDScript, Godot Scenes, UI Design
