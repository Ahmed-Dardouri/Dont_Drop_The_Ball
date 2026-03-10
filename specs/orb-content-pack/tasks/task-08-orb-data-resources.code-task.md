---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Orb Data Resources

## Description
Create 8 OrbData resource files (.tres) that define each new orb type with its behaviors, score, rarity, and other properties. These resources will be loaded by the spawn system to instantiate orbs in-game.

## Background
OrbData is a Godot Resource that defines orb properties and behaviors. Each orb type is a separate .tres file that can be loaded and instantiated. The behaviors created in Tasks 2-7 are combined here to create functional orb definitions.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Sections 5 and 6)
- Plan: specs/orb-content-pack/plan.md (Step 8)

**Additional References:**
- Existing orb resource files for format reference
- scripts/data/orb_data.gd (OrbData structure)
- All behavior classes from Tasks 2-7

## Technical Requirements

Create 8 resource files in `resources/orbs/`:

1. **burst_orb.tres** - RARE, score 8
   - ScoreBehavior(8)
   - ChainReactionBehavior(150)

2. **vertical_line_orb.tres** - RARE, score 5
   - ScoreBehavior(5)
   - LineClearBehavior(VERTICAL, 20)

3. **horizontal_line_orb.tres** - RARE, score 5
   - ScoreBehavior(5)
   - LineClearBehavior(HORIZONTAL, 20)

4. **slow_fall_orb.tres** - UNCOMMON, score 2
   - ScoreBehavior(2)
   - TimedModifierBehavior("slow_fall", 0.5, 45)

5. **sticky_head_orb.tres** - UNCOMMON, score 3
   - ScoreBehavior(3)
   - StickyHeadBehavior(0.5, 15.0)

6. **double_value_orb.tres** - UNCOMMON, score 1
   - ScoreBehavior(1)
   - TimedModifierBehavior("double_value", 1, -1)

7. **combo_starter_orb.tres** - RARE, score 3
   - ScoreBehavior(3)
   - TimedModifierBehavior("combo_chain", 1, 10)

8. **drifter_orb.tres** - UNCOMMON, score 2
   - ScoreBehavior(2)
   - MovementBehavior(HORIZONTAL_OSCILLATE, 75, 2)

## Dependencies
- Task 2: ScoreBehavior
- Task 3: TimedModifierBehavior
- Task 4: ChainReactionBehavior
- Task 5: LineClearBehavior
- Task 6: MovementBehavior
- Task 7: StickyHeadBehavior
- scripts/data/orb_data.gd (OrbData class)
- Existing texture resources (or placeholders)

## Implementation Approach
1. **Check existing orb resources**
   - Read existing .tres files to understand format
2. **Create each resource file**
   - Define OrbData with proper class_name reference
   - Attach appropriate behaviors
   - Set rarity, score, texture
3. **Verify loading**
   - Ensure each resource can be loaded without errors

## Acceptance Criteria

1. **All Resources Created**
   - Given the task is complete
   - When checking resources/orbs/
   - Then 8 new .tres files exist

2. **Resources Loadable**
   - Given the resource files are created
   - When loading each resource in Godot
   - Then no errors occur

3. **Behaviors Attached**
   - Given each orb resource
   - When inspecting the behaviors array
   - Then the correct behaviors are attached with correct parameters

4. **Existing Tests Pass**
   - Given the new resources
   - When running existing orb loading tests
   - Then no regressions occur

## Metadata
- **Complexity**: Low
- **Labels**: resources, orb-data, tres, configuration
- **Required Skills**: GDScript, Godot resources, Godot editor
