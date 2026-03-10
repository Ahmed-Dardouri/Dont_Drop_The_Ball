---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Update Spawn Table

## Description
Configure the spawn table with all 12 orb types and their appropriate weights for balanced gameplay.

## Background
The spawn table determines which orbs appear and how frequently. Weights control the relative probability of each orb spawning. The weights should provide good gameplay balance with common orbs appearing frequently and rare orbs appearing less often.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Configure spawn entries in OrbSpawner with the following weights:

| Orb | Weight |
|-----|--------|
| Blue | 100 |
| Red | 80 |
| Half-Solid | 20 |
| Score Multiplier | 40 |
| Slow Fall | 40 |
| Double Value | 40 |
| Time Slow | 20 |
| Combo Starter | 20 |
| Drifter | 40 |
| Burst | 20 |
| Vertical Line | 20 |
| Horizontal Line | 20 |

2. Total weight = 460
3. Verify all orb resources are referenced correctly

## Dependencies
- Task 06: Update OrbSpawner
- Task 07: Migrate Existing Orbs to Resources
- Tasks 14-22: All new orb resources

## Implementation Approach
1. **Configure spawn entries**
   - Create OrbSpawnEntry for each orb
   - Set appropriate weights
2. **Test**
   - Run game for extended period
   - Verify distribution is reasonable
3. **Manual demo**
   - Play 5 minutes, verify all orb types appear

## Acceptance Criteria

1. **All Orbs Configured**
   - Given the spawn table
   - When checked
   - Then all 12 orb types have entries

2. **Weights Correct**
   - Given the spawn table
   - When weights are checked
   - Then Blue=100, Red=80, Half-Solid=20, etc.

3. **All Orbs Spawn**
   - Given game running for 5 minutes
   - When playing normally
   - Then all 12 orb types appear at least once

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass

## Metadata
- **Complexity**: Low
- **Labels**: configuration, spawn-table
- **Required Skills**: GDScript, Game Balance
