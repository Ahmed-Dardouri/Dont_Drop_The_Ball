---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Add Collision Infrastructure to GenericOrb (F1 Fix)

## Description
Add Area2D collision infrastructure to GenericOrb so that OrbData-driven orbs can detect collision with the ball. This is a BLOCKING fix - without it, OrbData orbs cannot be collected at all.

## Background
GenericOrb extends Node2D and has no Area2D. Child orbs (BlueOrb, RedOrb, HalfSolidOrb) provide collision via their own Area2D nodes. For the new OrbData path, we need collision without child orbs.

The solution adds an Area2D node to GenericOrb scene, disabled by default, and enables it only when `set_orb_data()` is called.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.2 - GenericOrb)

**Additional References:**
- specs/orb-system-expansion/context.md (F1: Collision Detection)
- scripts/blue_orb.gd (existing Area2D pattern to follow)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Add `DataOrbArea` (Area2D) node to `scenes/generic_orb.tscn`
2. Add `CollisionShape2D` child to DataOrbArea
3. Add `@onready` references in script for data_orb_area and data_orb_collision
4. Add `var _orb_data: OrbData = null` to track OrbData state
5. Add `var _visual_sprite: Sprite2D = null` for OrbData visuals
6. Implement `func set_orb_data(orb_data: OrbData) -> void` that:
   - Stores the OrbData reference
   - Frees child orbs (not needed for OrbData path)
   - Creates a Sprite2D with the OrbData texture
   - Configures collision radius from OrbData.collision_radius
   - Connects body_entered signal to handler
7. Implement `func _on_data_orb_area_body_entered(body: Node2D) -> void` that:
   - Checks if body is in "ball" group
   - Calls `on_orb_collected()` if true
8. Implement `func get_orb_data() -> OrbData` getter for chain collection

## Dependencies
- None (this is the first task)

## Implementation Approach
1. Modify the scene file to add the Area2D structure
2. Add the @onready references and state variables
3. Implement set_orb_data() with sprite creation and collision config
4. Implement the body_entered signal handler
5. Add the getter method
6. Test manually: create a GenericOrb, call set_orb_data(), verify collision shape configured

## Acceptance Criteria

1. **DataOrbArea Added to Scene**
   - Given scenes/generic_orb.tscn is opened
   - When inspecting the scene tree
   - Then DataOrbArea (Area2D) node exists with CollisionShape2D child

2. **set_orb_data Configures Collision**
   - Given a GenericOrb instance
   - When set_orb_data(orb_data) is called with valid OrbData
   - Then data_orb_collision.shape.radius equals orb_data.collision_radius
   - And data_orb_area.monitoring is true
   - And _visual_sprite is created with orb_data.texture

3. **Ball Detection Works**
   - Given a GenericOrb with OrbData set
   - When a body in "ball" group enters the collision area
   - Then on_orb_collected() is called

4. **Old Path Unaffected**
   - Given a GenericOrb without OrbData set (using OrbProps)
   - When the orb is used in gameplay
   - Then DataOrbArea remains disabled and old collision path works

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests pass (./devscripts/test.sh exits 0)

## Metadata
- **Complexity**: Medium
- **Labels**: collision, infrastructure, blocking
- **Required Skills**: Godot 4 scene editing, Area2D signals
