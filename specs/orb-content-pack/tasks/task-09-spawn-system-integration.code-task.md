---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Spawn System Integration

## Description
Integrate the 8 new orb types into the game's spawning system so they appear during gameplay. This involves updating the spawn table/weights and ensuring the spawner can instantiate the new OrbData-based orbs.

## Background
The orb spawner controls which orbs appear and how frequently. New orb types must be registered with appropriate spawn weights based on their rarity (UNCOMMON vs RARE). The spawner must be able to load and instantiate the OrbData resources created in Task 8.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 7 - Implementation Sequence)
- Plan: specs/orb-content-pack/plan.md (Step 9)

**Additional References:**
- scripts/orb_spawner.gd (current spawning logic)
- Existing spawn configuration
- Task 8: Orb Data Resources

## Technical Requirements
1. Modify the spawn system to include all 8 new orb types
2. Set appropriate spawn weights:
   - UNCOMMON orbs: higher weight (more frequent)
   - RARE orbs: lower weight (less frequent)
3. Ensure the spawner can load OrbData resources
4. Verify orbs spawn with correct behaviors attached
5. Maintain backward compatibility with existing orb spawning

## Dependencies
- Task 8: Orb Data Resources (all 8 orb definitions)
- scripts/orb_spawner.gd (spawning logic)
- Spawn configuration system

## Implementation Approach
1. **Analyze current spawn system**
   - Read orb_spawner.gd to understand spawning mechanism
   - Identify where orb types are registered
2. **Add new orb types**
   - Register each new orb with appropriate weight
   - Ensure rarity affects spawn frequency
3. **Test spawning**
   - Verify each orb type can be spawned
   - Check that behaviors are attached correctly

## Acceptance Criteria

1. **All Orbs Spawnable**
   - Given the spawn system is updated
   - When playing the game
   - Then all 8 new orb types can appear

2. **Rarity Respected**
   - Given UNCOMMON and RARE orbs
   - When spawning over time
   - Then UNCOMMON orbs appear more frequently than RARE

3. **Behaviors Functional**
   - Given a spawned orb
   - When collecting it
   - Then its behaviors execute correctly

4. **Integration Tests Pass**
   - Given the implementation is complete
   - When running integration tests
   - Then spawn tests pass for all orb types

5. **No Existing Spawning Broken**
   - Given the changes
   - When running existing spawn tests
   - Then no regressions occur

## Metadata
- **Complexity**: Medium
- **Labels**: spawning, integration, weights, rarity
- **Required Skills**: GDScript, spawn systems, probability
