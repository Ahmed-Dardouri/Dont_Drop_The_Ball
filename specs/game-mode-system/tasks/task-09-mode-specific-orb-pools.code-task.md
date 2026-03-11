---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Mode-Specific Orb Pools

## Description
Modify the orb spawner to use mode-specific orb pools when available. Modes can define custom orb pools in their ModeConfig to spawn different orb types for different gameplay experiences.

## Background
OrbHunt and other modes benefit from spawning only specific orb types. The orb_spawner already has an `orb_data_array` property. This task adds a check for `ModeManager.current_mode.orb_pool` and uses it if available, falling back to the default pool otherwise.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 5.2 Orb Collection Flow)

**Additional References:**
- specs/game-mode-system/context.md (Integration Point 4: Orb Spawning)
- specs/game-mode-system/plan.md (Step 9 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/orb_spawner.gd`:
   - In `_spawn_from_props()`, check `ModeManager.current_mode.orb_pool` first
   - If mode has custom pool and it's not empty: use mode pool
   - Otherwise: use default `orb_data_array`
2. Handle edge cases:
   - ModeManager.current_mode is null: use default
   - ModeConfig.orb_pool is empty: use default
3. Update OrbHunt mode config to specify target orbs in its pool

## Dependencies
- Task 04: Integrate ModeManager with Game Flow (needs ModeManager integration)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/integration/test_mode_orb_spawner.gd` with test cases:
     - test_default_pool_no_mode
     - test_mode_pool_override
     - test_empty_pool_fallback
2. **Implement minimal code to pass**
   - Modify orb_spawner.gd to check mode pool
   - Update mode configs with orb pools
3. **Refactor while keeping tests green**
   - Ensure no regressions in default spawning
   - Verify pool switching works at runtime

## Acceptance Criteria

1. **Default Pool Without Mode**
   - Given ModeManager.current_mode is null
   - When orb_spawner spawns an orb
   - Then it uses the default orb_data_array

2. **Mode Pool Override**
   - Given a mode with custom orb_pool = [gold_orb, silver_orb]
   - When orb_spawner spawns an orb
   - Then it uses the mode's orb_pool

3. **Empty Pool Fallback**
   - Given a mode with empty orb_pool = []
   - When orb_spawner spawns an orb
   - Then it falls back to the default orb_data_array

4. **Integration Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 3 tests in test_mode_orb_spawner.gd pass

5. **No Regressions**
   - Given the integration is complete
   - When running existing orb spawning tests
   - Then all existing tests still pass

6. **Demo Works**
   - Given Orb Hunt mode is selected
   - When playing the mode
   - Then only target orbs spawn (no unwanted orb types)

## Metadata
- **Complexity**: Low
- **Labels**: integration, spawning, pools
- **Required Skills**: GDScript, Array Operations
