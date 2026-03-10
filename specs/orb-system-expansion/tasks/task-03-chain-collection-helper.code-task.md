---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Add Chain Collection Helper (F3 Fix)

## Description
Add a static `collect_orb()` helper to OrbBehavior base class that enables BurstBehavior and LineClearBehavior to collect other orbs and award their score.

## Background
Chain-reaction behaviors (Burst, LineClear) need to collect nearby orbs and award score. The helper must work for both OrbData orbs (via get_orb_data()) and OrbProps orbs (via get_orb_props()) to support the bridge architecture.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.4 - Static Helper)

**Additional References:**
- specs/orb-system-expansion/context.md (F3: Chain Collection Protocol)
- scripts/data/behaviors/orb_behavior.gd (base class to modify)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Add to `scripts/data/behaviors/orb_behavior.gd`:
   ```gdscript
   static func collect_orb(target: Node, score_multiplier: float = 1.0) -> int
   ```
2. The helper must:
   - Try to get score from OrbData via `target.get_orb_data()`
   - Fall back to OrbProps via `target.get_orb_props()` if OrbData not available
   - Use fixed scores for old orb types: BLUE=10, RED=25, default=10
   - Call `SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)`
   - Call `target.queue_free()` to remove the orb
   - Return the score value (after multiplier applied)

## Dependencies
- task-01-generic-orb-collision (requires get_orb_data() method)

## Implementation Approach
1. Open scripts/data/behaviors/orb_behavior.gd
2. Add the static collect_orb function
3. Implement OrbData path score extraction
4. Implement OrbProps fallback score extraction
5. Add sound event and queue_free
6. Write a simple test to verify function works

## Acceptance Criteria

1. **Collects OrbData Orbs**
   - Given a target node with get_orb_data() returning valid OrbData
   - When collect_orb(target, 1.0) is called
   - Then orb_data.base_score is returned
   - And target.queue_free() is called
   - And SoundPlayEvent is invoked

2. **Collects OrbProps Orbs**
   - Given a target node with get_orb_props() returning valid OrbProps
   - When collect_orb(target, 1.0) is called
   - Then appropriate fixed score is returned (10 for BLUE, 25 for RED)
   - And target.queue_free() is called

3. **Score Multiplier Applied**
   - Given a target with base_score of 10
   - When collect_orb(target, 2.0) is called
   - Then 20 is returned

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests pass (./devscripts/test.sh exits 0)

## Metadata
- **Complexity**: Low
- **Labels**: chain-collection, helper, bridge
- **Required Skills**: GDScript static functions, Node methods
