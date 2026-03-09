---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create Orb Collection Integration Test

## Description
Create integration tests that verify the complete orb collection flow: orb spawning, ball collision, score update, and pause blocking.

## Background
Integration tests verify that components work together correctly. This test ensures the orb system, score manager, and game state all integrate properly.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 7: Testing Strategy - Integration Tests)

**Additional References:**
- specs/ai-refactor-prep/plan.md (Step 16)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `tests/integration/test_orb_collection_integration.gd`
2. Test cases:
   - Orb collects and adds score
   - Paused orb is not collected
   - Ball group is detected correctly
3. Use GUT's `add_child_autofree()` for scene management
4. Reset global state between tests

## Dependencies
- All Phase 1 tasks (requires complete orb system implementation)

## Implementation Approach
1. Create integration test file
2. Set up test fixtures with ScoreManager, GameState reset
3. Test orb collection flow end-to-end
4. Test pause blocking behavior
5. Verify all tests pass

## Acceptance Criteria

1. **Orb Collects and Adds Score**
   - Given OrbRegistry is initialized, ScoreManager is reset, GameState.is_paused is false
   - When creating an active Orb with definition.score_value = 2
   - And calling orb.collect()
   - Then ScoreManager.get_score() equals 2

2. **Paused Orb Not Collected**
   - Given GameState.is_paused is true, ScoreManager is reset
   - When creating an active Orb and calling collect()
   - Then ScoreManager.get_score() remains 0

3. **Ball Group Detection**
   - Given an Orb and a body in "ball" group
   - When body enters orb's detection area
   - Then orb collects (score increases)

4. **Integration Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all integration tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: testing, integration, orb-system
- **Required Skills**: GDScript, GUT testing framework
