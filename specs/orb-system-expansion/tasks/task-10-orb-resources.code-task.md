---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Orb Resource Files

## Description
Create the 8 OrbData resource files (.tres) that define the new orb types with their behaviors.

## Background
OrbData resources are the content definitions for new orb types. Each resource specifies display name, score, rarity, texture, and behaviors. These are the actual "game content" that makes the new orbs real.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 4 - Data Models)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 10)
- scripts/data/orb_data.gd (OrbData resource structure)
- sprites/ directory (available textures)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/` directory
2. Create 8 orb resource files:
   - `burst_orb.tres` - BurstBehavior
   - `vertical_line_orb.tres` - LineClearBehavior (VERTICAL)
   - `horizontal_line_orb.tres` - LineClearBehavior (HORIZONTAL)
   - `slow_fall_orb.tres` - TimedModifierBehavior (slow_fall effect)
   - `sticky_head_orb.tres` - TimedModifierBehavior (sticky_head effect)
   - `double_value_orb.tres` - TimedModifierBehavior (double_value effect)
   - `combo_starter_orb.tres` - ComboStarterBehavior
   - `drifter_orb.tres` - MovementBehavior + ScoreBehavior
3. Each resource must have:
   - display_name (unique identifier)
   - base_score (appropriate for rarity)
   - rarity (COMMON/UNCOMMON/RARE)
   - texture (reuse existing with color modulate if needed)
   - behaviors array (configured behavior resources)

## Dependencies
- task-04-burst-behavior
- task-05-line-clear-behavior
- task-06-movement-behavior
- task-07-combo-starter-behavior

## Implementation Approach
1. Create resources/orbs/ directory
2. Create each .tres file with proper OrbData format
3. Configure behaviors inline or as separate .tres files
4. Use existing sprites (blue_ball.png, red_ball.png, etc.) with modulate colors
5. Test by loading in editor and verifying properties

## Acceptance Criteria

1. **All 8 Resources Created**
   - Given resources/orbs/ directory
   - When listing files
   - Then 8 .tres files exist with correct names

2. **Burst Orb Configuration**
   - Given burst_orb.tres
   - When inspected
   - Then display_name = "BurstOrb"
   - And behaviors contains BurstBehavior with radius=150

3. **Line Clear Orbs Configuration**
   - Given vertical_line_orb.tres and horizontal_line_orb.tres
   - When inspected
   - Then direction is VERTICAL or HORIZONTAL respectively

4. **Timed Effect Orbs Configuration**
   - Given slow_fall_orb.tres, sticky_head_orb.tres, double_value_orb.tres
   - When inspected
   - Then behaviors contain TimedModifierBehavior with appropriate effect_id

5. **Drifter Orb Configuration**
   - Given drifter_orb.tres
   - When inspected
   - Then behaviors contains both MovementBehavior and ScoreBehavior

6. **Resources Load in Editor**
   - Given the .tres files
   - When opening in Godot editor
   - Then all resources load without errors

## Metadata
- **Complexity**: Low
- **Labels**: resources, content, orb-definitions
- **Required Skills**: Godot resource editing, .tres format
