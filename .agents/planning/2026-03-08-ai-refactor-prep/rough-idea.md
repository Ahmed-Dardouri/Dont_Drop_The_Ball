# Rough Idea: AI-Friendly Godot Game Refactor

## Project: Don't Drop the Ball

### Overview
Refactor an existing functional Godot 4 GDScript game ("Don't Drop the Ball") to become more AI-friendly, modular, testable, and easy to extend, while preserving current gameplay behavior.

### Core Gameplay (Must Remain Unchanged)
- Player bounces an object (ball) using a semi-round head
- Object can deflect sideways
- Orbs spawn in the air and grant bonuses when collected

### Primary Objective
Refactor the existing project so it keeps the same functional gameplay, but becomes easier for AI to modify and extend later.

### Refactor Goals

1. **Preserve Current Behavior**
   - Game should remain functionally the same after the refactor
   - Existing mechanics, controls, scoring behavior, orb behavior, and game flow should not be intentionally changed
   - Only change where required to improve structure or testability

2. **Improve Modularity**
   - Separate pure gameplay logic from scene/node glue where possible
   - Reduce unnecessary coupling between systems
   - Make orb behavior, scoring, state transitions, and environment/game-mode logic easier to extend independently

3. **Improve Testability**
   - Add or improve GUT tests for the most important existing systems
   - Prioritize deterministic tests for:
     - Orb behavior/effects
     - Score/combo logic
     - Player/ball interaction rules
     - Game state or mode transitions
     - Existing environment/modifier logic if present
   - If some code is hard to test, do minimal safe refactors to make it testable

4. **Make Future Expansion Data-Driven**
   - Prepare the architecture so future orb types, game modes, and environment variants can be added with minimal rewrites
   - Prefer configuration/resources/data objects over hardcoded branching where appropriate
   - Introduce extension points rather than shipping all future content now

5. **Keep the Repo AI-Compatible**
   - Keep diffs small and focused
   - Prefer typed GDScript
   - Avoid changing project settings unless required
   - Avoid modifying large assets; placeholders are fine if needed
   - Prefer text-based resources and modular scenes/scripts

### Validation Requirements
- All work must be validated via `./devscripts/test.sh` and it must exit 0
- Add or update tests as part of the refactor
- Do not allow zero-test success
- Keep the smoke test and test pipeline green throughout

### Important Constraint
This task is preparation for a later major expansion. Do not spend effort on adding many new orb types, new modes, or lots of new content yet. Focus on making the existing project architecture clean, modular, testable, and ready for AI-assisted expansion.

### Current Codebase Summary
- **Engine**: Godot 4.x
- **Language**: GDScript
- **Test Framework**: GUT (Godot Unit Testing)
- **Event System**: Custom dynamic event manager (addons/dynamic_event_manager)

**Key Scripts**:
- `main.gd` - Main scene orchestration
- `world_builder.gd` - World/scene management
- `physics_player.gd` - Player movement physics
- `ball.gd` - Ball physics
- `orb_mngr.gd` - Orb scoring/effects
- `orb_spawner.gd` - Orb spawning logic
- `generic_orb.gd` - Orb container/selector
- `blue_orb.gd`, `red_orb.gd`, `half_solid_orb.gd` - Orb implementations
- `score_mngr.gd` - Score tracking
- `hud.gd` - UI display

**Utilities**:
- `utils/Constants.gd` - Game constants
- `utils/enums.gd` - Enumerations
- `utils/variables.gd` - Global game variables
- `utils/orb_properties.gd` - Orb property resource

**Events** (custom event system):
- `AddScoreEvent`, `OrbCollectedEvent`, `PauseEvent`, `MoveEvent`, etc.
