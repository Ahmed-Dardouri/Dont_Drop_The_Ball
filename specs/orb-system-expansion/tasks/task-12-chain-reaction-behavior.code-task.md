---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create ChainReactionBehavior

## Description
Create the `ChainReactionBehavior` that triggers collection of all orbs within a specified radius when executed.

## Background
ChainReactionBehavior is used by Burst orbs. When the burst orb is collected, it finds all other orbs within the radius and triggers their collection, creating a chain reaction effect.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/chain_reaction_behavior.gd` extending OrbBehavior
2. Add `@export` properties:
   - `var radius: float = 150.0`
3. Implement `execute(context: Dictionary) -> void`:
   - Get source orb position from context
   - Find all Orb nodes within radius using `get_tree().get_nodes_in_group("orbs")`
   - For each orb in radius (except self):
     - Call `orb.collect()`
   - Exclude the source orb from collection

## Dependencies
- Task 02: OrbBehavior Abstract Base Class
- Task 05: Unified Orb Scene and Script (Orb must have "orbs" group)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_chain_reaction_behavior.gd`
   - Test finding orbs in radius
   - Test excluding self
   - Test correct radius boundary
2. **Implement minimal code to pass**
   - Create ChainReactionBehavior class
   - Implement execute with radius detection
3. **Refactor while keeping tests green**
   - Ensure efficient radius detection

## Acceptance Criteria

1. **Finds Orbs In Radius**
   - Given ChainReactionBehavior with radius=150.0
   - And orbs at distances 0, 100, 200 from source
   - When execute() is called
   - Then orbs at 0 and 100 are collected, orb at 200 is not

2. **Excludes Self**
   - Given ChainReactionBehavior on source orb
   - When execute() is called
   - Then source orb is not collected (only nearby orbs)

3. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_chain_reaction_behavior.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, chain-reaction
- **Required Skills**: GDScript, Godot Scene Tree
