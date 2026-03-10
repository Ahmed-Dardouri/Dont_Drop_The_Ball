---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Create Test Orb Resource

## Description
Create a single test orb resource file (.tres) that defines a simple collectible orb using the existing ScoreBehavior.

## Background
To verify the bridge integration works, we need ONE test orb resource. This orb will:
- Use the existing ScoreBehavior (no new behaviors needed)
- Reuse an existing texture (sprites/blue_ball.png)
- Have simple properties for easy verification

This is the MINIMUM viable orb content - just enough to prove the system works.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 4 - Data Models)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 3)
- scripts/data/orb_data.gd (OrbData resource structure)
- scripts/data/behaviors/score_behavior.gd (existing behavior to reuse)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/` directory
2. Create `resources/orbs/test_orb.tres` with:
   - display_name: "Test Orb"
   - texture: res://sprites/blue_ball.png (reuse existing)
   - scale: Vector2(1, 1)
   - base_score: 5
   - lifespan: 30.0
   - rarity: 0 (COMMON)
   - collision_radius: 32.0
   - is_half_solid: false
   - spawn_animation_duration: 1.5
   - behaviors: [ScoreBehavior with base_score=5]

## Dependencies
- None (ScoreBehavior already exists)

## Implementation Approach
1. Create resources/orbs/ directory
2. Create test_orb.tres using Godot editor or direct file creation
3. Verify resource loads in editor without errors
4. Verify ScoreBehavior is properly attached

## Acceptance Criteria

1. **Directory Created**
   - Given the project structure
   - When listing directories
   - Then resources/orbs/ exists

2. **Resource File Exists**
   - Given resources/orbs/ directory
   - When listing files
   - Then test_orb.tres exists

3. **Correct Properties**
   - Given test_orb.tres is loaded
   - When inspecting properties
   - Then display_name = "Test Orb"
   - And base_score = 5
   - And collision_radius = 32.0

4. **ScoreBehavior Attached**
   - Given test_orb.tres is loaded
   - When inspecting behaviors array
   - Then ScoreBehavior is present with base_score = 5

5. **Resource Loads in Editor**
   - Given the .tres file
   - When opening in Godot editor
   - Then resource loads without errors
   - And texture preview shows blue_ball.png

6. **Can Be Added to Spawner**
   - Given an OrbSpawner node in a scene
   - When dragging test_orb.tres to orb_data_array
   - Then the resource is accepted and displayed

## Metadata
- **Complexity**: Low
- **Labels**: resources, content, mvp, test-orb
- **Required Skills**: Godot resource editing, .tres format
