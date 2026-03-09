---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create Unified Orb Class

## Description
Create the unified `Orb` base class that handles spawn animation, lifetime management, and collection behavior for all orb types.

## Background
Orb behavior is duplicated across blue_orb.gd, red_orb.gd, and generic_orb.gd. The unified Orb class consolidates common behavior while allowing subclasses to customize.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.8: Orb Base Class)

**Additional References:**
- specs/ai-refactor-prep/context.md (GenericOrb Spawn Animation, Constraints)
- specs/ai-refactor-prep/plan.md (Step 13)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/entities/orb/orb.gd` with class_name Orb extends Node2D
2. Signal: `collected`
3. Property: `@export var definition: OrbDefinition`
4. Spawn animation:
   - 1.5 second timer
   - Opacity: 0.0 → 0.75 during spawn → 1.0 when active
5. Lifetime timer using `definition.lifespan_seconds`
6. Methods:
   - `collect()` - Add score, emit signal, queue_free
   - `_on_body_entered(body: Node2D)` - Check for ball group, call collect
7. Block collection when paused (check GameState.is_paused)
8. Block collection during spawn animation

## Dependencies
- task-02-create-gamestate-singleton (for GameState.is_paused)
- task-03-create-scoremanager-singleton (for ScoreManager.add_score)
- task-08-create-orbdefinition-resource (for OrbDefinition)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_orb.gd` first
2. Implement spawn animation with Timer
3. Implement lifetime countdown
4. Implement collect method with score and pause check
5. Implement body detection using "ball" group
6. Verify all tests pass

## Acceptance Criteria

1. **Orb Requires Definition**
   - Given an Orb without definition
   - When `_ready()` is called
   - Then error is logged but orb doesn't crash

2. **Spawn Animation Works**
   - Given an Orb with definition
   - When `_ready()` is called
   - Then modulate.a starts at 0.0
   - And after 1.5s, modulate.a is 1.0

3. **Collect Adds Score**
   - Given an active Orb with score_value=10
   - When calling `collect()`
   - Then `ScoreManager.get_score()` increases by 10

4. **Collect Blocked When Paused**
   - Given GameState.is_paused is true
   - When calling `collect()`
   - Then score is NOT added and orb is NOT freed

5. **Collect Blocked During Spawn**
   - Given Orb is in spawn animation (not active)
   - When calling `collect()`
   - Then score is NOT added

6. **Ball Detection Uses Group**
   - Given an Orb and a body in "ball" group
   - When body enters orb's area
   - Then collect() is called

7. **Collected Signal Emits**
   - Given an active Orb
   - When calling `collect()`
   - Then `collected` signal is emitted

8. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all Orb tests pass

## Metadata
- **Complexity**: Medium-High
- **Labels**: orb-system, spawn-animation, collection
- **Required Skills**: GDScript, Godot 4.x, Timer
