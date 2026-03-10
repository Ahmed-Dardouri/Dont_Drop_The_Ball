---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: ChainReactionBehavior Implementation

## Description
Implement the ChainReactionBehavior class for the Burst Orb. When executed, it finds all orbs within a configurable radius and triggers their collection, creating a chain reaction effect.

## Background
The Burst Orb is a rare orb type that clears nearby collectible orbs when collected. This requires scanning the scene for orbs in the "orbs" group, checking distances, and triggering their collect() method. The source orb must not collect itself.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.1)
- Plan: specs/orb-content-pack/plan.md (Step 4)

**Additional References:**
- scripts/data/behaviors/orb_behavior.gd (base class)
- Existing orb node structure (for collect() method)

## Technical Requirements
1. Create `scripts/data/behaviors/chain_reaction_behavior.gd` extending OrbBehavior
2. Export `radius: float` with default value of 150.0
3. In `execute()`: get all nodes in "orbs" group from scene tree
4. For each orb within radius, call `orb.collect()` if the method exists
5. Skip the source orb (context["orb"])
6. Skip orbs not inside the tree (is_inside_tree() check)
7. Handle null source orb gracefully

## Dependencies
- scripts/data/behaviors/orb_behavior.gd (base class)
- Orbs must be in "orbs" group
- Orbs must have `collect()` method

## Implementation Approach
1. **TDD: Write failing tests first**
   - Create `tests/unit/test_chain_reaction_behavior.gd`
   - Test orbs_in_radius_cleared
   - Test self_not_collected
   - Test empty_radius
   - Test custom_radius
2. **Implement minimal code to pass**
   - Create ChainReactionBehavior class with distance-based collection
3. **Refactor while keeping tests green**
   - Add safety checks for null and tree state

## Acceptance Criteria

1. **Orbs In Radius Cleared**
   - Given 3 orbs within 150px of source and 1 orb outside
   - When execute() is called
   - Then 3 nearby orbs are collected, 1 outside is not

2. **Self Not Collected**
   - Given source orb is in the "orbs" group
   - When execute() is called
   - Then source orb is NOT collected

3. **Empty Radius**
   - Given no other orbs in the scene
   - When execute() is called
   - Then no crash occurs (graceful no-op)

4. **Custom Radius**
   - Given radius=50 and an orb at 75px distance
   - When execute() is called
   - Then the orb is NOT collected

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, chain-reaction, burst, radius-detection
- **Required Skills**: GDScript, Godot scene tree, node groups
