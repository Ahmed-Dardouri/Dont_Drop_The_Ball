---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Integration Test - Full Chain Collection Flow

## Description
Write integration tests that verify the complete chain collection flow from behavior execution to score awarding.

## Background
Unit tests cover individual behaviors in isolation. Integration tests verify that behaviors work correctly with the full system including GenericOrb, OrbAdapter, and the event system.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 6 - Testing Strategy)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 11)
- tests/unit/ directory (existing test patterns)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `tests/integration/test_chain_collection.gd`
2. Test cases:
   - `test_burst_collects_nearby_orbs`: Create GenericOrb with BurstBehavior, add nearby orbs, verify collection
   - `test_line_clear_collects_line_orbs`: Create GenericOrb with LineClearBehavior, verify line collection
   - `test_collected_orbs_award_full_score`: Verify AddScoreEvent is invoked with correct total

## Dependencies
- task-04-burst-behavior
- task-05-line-clear-behavior
- task-08-orb-adapter
- task-01-generic-orb-collision (for on_orb_collected flow)

## Implementation Approach
1. Set up test scene with multiple orbs
2. Create orb with BurstBehavior and trigger collection
3. Verify nearby orbs are freed
4. Verify AddScoreEvent received correct score
5. Repeat for LineClearBehavior

## Acceptance Criteria

1. **Burst Collects Nearby**
   - Given a GenericOrb with BurstBehavior at center
   - And 3 other orbs within burst radius
   - And 1 orb outside burst radius
   - When on_orb_collected() is triggered
   - Then 3 nearby orbs are freed
   - And 1 distant orb remains

2. **Line Clear Collects Line**
   - Given a GenericOrb with LineClearBehavior (VERTICAL)
   - And orbs in vertical column and outside column
   - When on_orb_collected() is triggered
   - Then only orbs in vertical column are freed

3. **Score Awarded Correctly**
   - Given orbs worth 50 total score will be collected
   - When chain collection occurs
   - Then AddScoreEvent.invoke(50) is called

4. **Integration Tests Pass**
   - Given the implementation is complete
   - When running ./devscripts/test.sh
   - Then all integration tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: testing, integration, chain-reaction
- **Required Skills**: GUT testing framework, Godot scene manipulation
