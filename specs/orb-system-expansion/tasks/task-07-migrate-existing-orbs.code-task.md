---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Migrate Existing Orbs to Resources

## Description
Create OrbData resource files for the existing orb types (Blue, Red, Half-Solid) and add the OrbRarity enum to the enums file.

## Background
The current orbs have hardcoded scripts with their properties. We need to create resource files that capture all their properties so they can work with the new unified Orb scene.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Add `OrbRarity` enum to `scripts/utils/enums.gd`:
   ```gdscript
   enum OrbRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }
   ```
2. Create `resources/orbs/` directory
3. Create `resources/orbs/blue_orb.tres`:
   - display_name = "Blue Orb"
   - base_score = 2
   - rarity = COMMON
   - texture = existing blue orb texture
   - ScoreBehavior with score_value = 2
4. Create `resources/orbs/red_orb.tres`:
   - display_name = "Red Orb"
   - base_score = 3
   - rarity = COMMON
   - ScoreBehavior with score_value = 3
5. Create `resources/orbs/half_solid_orb.tres`:
   - display_name = "Half-Solid Orb"
   - base_score = 8
   - rarity = RARE
   - is_half_solid = true
   - ScoreBehavior with score_value = 8

## Dependencies
- Task 01: OrbData Resource Class
- Task 02: OrbBehavior Abstract Base Class
- Task 04: ScoreBehavior
- Task 06: Update OrbSpawner

## Implementation Approach
1. **TDD: Write test first**
   - Test that each resource loads correctly
   - Test that values match expected
2. **Implement**
   - Add OrbRarity enum
   - Create each .tres resource file
3. **Verify**
   - Each resource loads without errors
   - Values are correct

## Acceptance Criteria

1. **OrbRarity Enum Exists**
   - Given enums.gd is loaded
   - When checking for OrbRarity
   - Then enum exists with COMMON, UNCOMMON, RARE values

2. **Blue Orb Resource**
   - Given blue_orb.tres is loaded
   - When properties are checked
   - Then base_score equals 2 and rarity equals COMMON

3. **Red Orb Resource**
   - Given red_orb.tres is loaded
   - When properties are checked
   - Then base_score equals 3 and rarity equals COMMON

4. **Half-Solid Orb Resource**
   - Given half_solid_orb.tres is loaded
   - When properties are checked
   - Then base_score equals 8, rarity equals RARE, is_half_solid equals true

5. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass

## Metadata
- **Complexity**: Low
- **Labels**: migration, resources
- **Required Skills**: GDScript, Godot Resources
