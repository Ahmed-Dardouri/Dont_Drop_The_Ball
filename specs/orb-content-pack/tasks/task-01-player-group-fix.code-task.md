---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Player Group Fix

## Description
Add the player to the "player" group so that the ball can detect player collisions for the sticky head effect. This is a prerequisite for the StickyHeadBehavior implementation.

## Background
The ball's `_on_body_entered()` signal handler needs to identify when it collides with the player. Currently, `physics_player.gd` does NOT add itself to any group. The sticky head effect requires detecting player collisions specifically to apply bounce velocity dampening.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.6)
- Plan: specs/orb-content-pack/plan.md (Step 1)

**Additional References:**
- scripts/ball.gd (existing collision handling)
- scripts/physics_player.gd (current implementation)

## Technical Requirements
1. Add `add_to_group("player")` to `physics_player.gd` in the `_ready()` function
2. Ensure this does not break any existing functionality
3. Create a unit test to verify the player is in the "player" group

## Dependencies
- None (this is the first task)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_player_in_group.gd`
   - Test that player is in "player" group after _ready()
2. **Implement minimal code to pass**
   - Add `add_to_group("player")` to `physics_player.gd`
3. **Refactor while keeping tests green**
   - Verify no regressions in existing tests

## Acceptance Criteria

1. **Player in Group**
   - Given a physics_player instance
   - When _ready() is called
   - Then the player is in the "player" group

2. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass including the new player group test

3. **No Regressions**
   - Given the change is made
   - When running existing tests
   - Then no existing tests fail

## Metadata
- **Complexity**: Low
- **Labels**: prerequisite, player, groups, collision-detection
- **Required Skills**: GDScript, Godot node groups
