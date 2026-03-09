---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Add Groups to Entities

## Description
Add group membership to Ball and Ground entities to enable group-based collision detection instead of hardcoded name checks.

## Background
Collision detection currently uses hardcoded `body.name == "ground_static"` checks. Migrating to groups enables more flexible and maintainable collision handling.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 3: Architecture Overview - Collision System)

**Additional References:**
- specs/ai-refactor-prep/context.md (Existing Group Usage)
- specs/ai-refactor-prep/plan.md (Step 11)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/ball.gd` to add `add_to_group("ball")` in `_ready()`
2. Modify `scenes/ground.tscn` to add "ground" group to ground_static node
3. Ensure "orbs" group continues to work (already in use)

## Dependencies
- None (standalone modification)

## Implementation Approach
1. Read `scripts/ball.gd` and find `_ready()` function
2. Add `add_to_group("ball")` call
3. Read `scenes/ground.tscn` and add `groups=["ground"]` to ground_static node
4. Verify via smoke test that existing functionality still works

## Acceptance Criteria

1. **Ball in Ball Group**
   - Given the ball scene is instantiated
   - When checking `ball.is_in_group("ball")`
   - Then result is true

2. **Ground in Ground Group**
   - Given the ground scene is loaded
   - When checking `ground.is_in_group("ground")`
   - Then result is true

3. **Orbs Group Still Works**
   - Given the game is running
   - When orbs are spawned
   - Then `get_tree().get_nodes_in_group("orbs")` returns spawned orbs

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass

5. **Smoke Test Passes**
   - Given the implementation is complete
   - When running `./devscripts/smoke_test.sh`
   - Then exit code is 0

## Metadata
- **Complexity**: Low
- **Labels**: collision, groups, entities
- **Required Skills**: GDScript, Godot 4.x scene format
