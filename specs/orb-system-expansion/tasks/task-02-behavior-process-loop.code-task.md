---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Add Behavior Process Loop (F2 Fix)

## Description
Add a `_process()` override in GenericOrb that calls `behavior.process()` for each behavior in OrbData. This enables MovementBehavior and other per-frame behaviors to function.

## Background
MovementBehavior needs per-frame updates via its `process(orb, delta)` method. Currently, GenericOrb's `_process()` only handles spawn animation. We need to extend it to iterate through OrbData behaviors and call their process() method.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.2 - GenericOrb F2 Fix)

**Additional References:**
- specs/orb-system-expansion/context.md (F2: Behavior Process Loop)
- scripts/data/behaviors/orb_behavior.gd (OrbBehavior.process signature)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `_process(delta: float)` in GenericOrb to:
   - Keep existing spawn animation for OrbProps path
   - Handle spawn animation for OrbData path (using _visual_sprite opacity)
   - After spawn animation complete, iterate through `_orb_data.behaviors`
   - Call `behavior.process(self, delta)` for each behavior
2. Add spawn progress tracking for OrbData path if not already present

## Dependencies
- task-01-generic-orb-collision (requires _orb_data variable)

## Implementation Approach
1. Review current `_process()` implementation
2. Add conditional logic for OrbData vs OrbProps paths
3. Implement behavior iteration loop
4. Handle spawn animation for OrbData path (fade in _visual_sprite)
5. Test manually: set OrbData with MovementBehavior, verify process() is called

## Acceptance Criteria

1. **Process Routes to Behaviors**
   - Given a GenericOrb with OrbData containing behaviors
   - When _process(delta) is called after spawn animation completes
   - Then behavior.process(self, delta) is called for each behavior

2. **OrbProps Path Unchanged**
   - Given a GenericOrb using OrbProps (no OrbData)
   - When _process(delta) is called
   - Then existing spawn animation logic works unchanged

3. **Spawn Animation Works for OrbData**
   - Given a GenericOrb with OrbData
   - When spawn animation is in progress
   - Then _visual_sprite.modulate.a increases from 0 to 1

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests pass (./devscripts/test.sh exits 0)

## Metadata
- **Complexity**: Low
- **Labels**: process-loop, behaviors, infrastructure
- **Required Skills**: GDScript _process override
