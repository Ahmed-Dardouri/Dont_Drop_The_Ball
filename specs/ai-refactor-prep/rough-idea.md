# AI-Friendly Godot Game Refactor

## Initial Prompt

Refactor the Dont_Drop Godot 4.x game to be more AI-friendly by:
1. Extracting game state into singletons (GameState, ScoreManager)
2. Extracting physics into pure static classes (BallPhysics, PlayerPhysics)
3. Creating a data-driven orb system (OrbDefinition, OrbRegistry)
4. Updating collision detection to use groups instead of hardcoded names
5. Adding comprehensive unit tests

## Source Documents

- Implementation Plan: `.agents/planning/2026-03-08-ai-refactor-prep/implementation/plan.md`
- README for Agents: `README_FOR_AGENT.md`

## Current State Analysis

### Existing Autoloads
- PhantomCameraManager
- Events (dynamic_event_manager)
- Constants
- GameSaveMngr
- Variables

### Existing Code Structure
- `scripts/` - gameplay scripts (ball.gd, blue_orb.gd, red_orb.gd, etc.)
- `scripts/events/` - event classes
- `scripts/utils/` - utilities (enums.gd, Constants.gd, variables.gd)
- `tests/` - GUT test suite

### Key Technical Debt Identified
1. `PauseEvent.state` is a static variable (should be singleton)
2. Collision detection uses hardcoded node names (`body.name == "ground_static"`)
3. Orb types are separate scripts (should be unified with data-driven approach)
4. Physics logic is embedded in entity scripts (should be extracted)

## Identified Gap

The plan references `Enums.GameMode` in Step 1, but this enum does not exist in `scripts/utils/enums.gd`.
