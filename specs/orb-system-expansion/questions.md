# Orb System Expansion - Clarification Questions

## Question 1 (2026-03-10)

**Context:** The orb system expansion has extensive planning complete:
- Requirements, design, and 24-step implementation plan exist
- Tasks 01-03 (OrbData, OrbBehavior, EffectManager) are completed
- Task 04 (ScoreBehavior) is pending

**Question:** The prompt mentions "Step 2" - but Step 2 (OrbBehavior) is already completed. Could you clarify:

1. **Are you referring to Phase 2** (Unified Orb Scene, Steps 5-7)?
2. **Or is "Step 2" a different milestone** not captured in the existing plan?
3. **Or should I continue from Task 04** (ScoreBehavior) which is the next pending item?

**Why this matters:** The existing plan is comprehensive and ready for implementation. I want to ensure I'm refining the right requirements rather than duplicating work already done.

---

## Answer 1 (2026-03-10)

**Answer:** Continue with **Task 04 (ScoreBehavior)**, which corresponds to **Step 3** in the implementation plan.

**Reasoning:**
1. The implementation plan uses sequential Step numbering (1-25), but tasks were completed out of order for practical reasons
2. Step 3 (ScoreBehavior) was deferred because it depends on EffectManager (Step 4), which is now complete
3. The current completed state is: Steps 1, 2, 4 ✅ → Step 3 is the logical next task
4. Phase 2 (Unified Orb Scene, Steps 5-7) depends on having ScoreBehavior working first

**Mapping Clarification:**
| Task # | Step # | Description | Status |
|--------|--------|-------------|--------|
| Task 01 | Step 1 | OrbData Resource | ✅ |
| Task 02 | Step 2 | OrbBehavior Base | ✅ |
| Task 04 | Step 3 | ScoreBehavior | 🔄 NEXT |
| Task 03 | Step 4 | EffectManager | ✅ |

**Recommendation:** Proceed with Task 04 (ScoreBehavior) implementation following the existing code-task file at `specs/orb-system-expansion/tasks/task-04-score-behavior.code-task.md`.

---

## Question 2 (2026-03-10)

**Context:** The objective has shifted from "continue architecture work" to "finish the integration so actual new orbs appear in gameplay." The previous run created infrastructure (OrbData, OrbBehavior, EffectManager) but did not connect it to the actual game. There are now two parallel systems:
- **Old system:** OrbProps + GenericOrb (child orbs: BlueOrb, RedOrb, HalfSolidOrb) - WORKING
- **New system:** OrbData + behaviors - NOT CONNECTED

The original detailed design calls for:
1. Creating a NEW unified Orb scene (`scenes/orb.tscn`)
2. Deleting the old orb scenes/scripts
3. Full migration to OrbData

The new objective constraints say:
- "Do not do another large refactor"
- "Prefer finishing and integrating the existing new system"

**Question:** For the integration approach, should I:

**Option A: Bridge existing GenericOrb to support OrbData** (minimal change)
- Modify GenericOrb to accept EITHER OrbProps (old) OR OrbData (new)
- Keep existing BlueOrb/RedOrb/HalfSolidOrb child scenes working
- Add code path to execute OrbData behaviors when present
- New orb types use the OrbData path

**Option B: Follow original plan with new unified Orb scene** (bigger change, cleaner result)
- Create new `scenes/orb.tscn` with OrbData-driven script
- Migrate spawner to use new Orb scene
- Keep old scenes as fallback until migration complete
- Eventually delete old scenes

**Why this matters:** Option A is faster and lower risk but creates a hybrid system. Option B is cleaner but requires more changes. The choice affects:
- How many files need modification
- Test coverage requirements
- Debug complexity
- Future maintenance burden

---

## Answer 2 (2026-03-10)

**Recommendation: Option A (Bridge existing GenericOrb)**

### Rationale

1. **Constraint alignment:** Objective explicitly states "Do not do another large refactor" and "Prefer finishing and integrating the existing new system."

2. **Lower risk profile:** Old system works. Bridging allows new orbs to work without risking existing gameplay.

3. **Incremental migration path:** Add new orbs immediately while keeping old orbs stable, then migrate old orbs to OrbData later if desired.

4. **Minimal file changes:** Bridge requires ~3-4 files vs Option B's 8-10 files + scene restructuring.

### Bridge Architecture

```
OrbSpawner
    ├── OrbProps[] (old path) → GenericOrb → BlueOrb/RedOrb/HalfSolidOrb (UNCHANGED)
    └── OrbData[] (new path) → OrbAdapter → GenericOrb → execute behaviors
```

### Key Changes

1. **OrbAdapter utility** - Converts OrbData to OrbProps for spawner, stores OrbData reference for behavior execution
2. **GenericOrb** - Add optional `orb_data: OrbData` field; execute behaviors when present, else use existing path
3. **OrbSpawner** - Add `orb_data_array: Array[OrbData]` export, select from combined pool
4. **Orb resources** - Create `.tres` files in `resources/orbs/`

### Files Changed

| File | Change | Lines |
|------|--------|-------|
| `scripts/generic_orb.gd` | Add OrbData support | ~15 |
| `scripts/orb_spawner.gd` | Add OrbData array support | ~20 |
| `scripts/utils/orb_adapter.gd` | NEW adapter | ~30 |
| `resources/orbs/*.tres` | NEW orb definitions | N/A |

### Confidence: 85%

Satisfies all constraints:
- No large refactor ✓
- Preserves existing gameplay ✓
- Enables new orbs to spawn and work ✓
- Reversible if needed ✓
- Validates with ./devscripts/test.sh ✓

---

## Question 3 (2026-03-10) - CRITICAL: Collision Detection Gap

**Context:** The Design Critic identified a blocking implementation gap in the bridge design.

**Code Evidence:**
- `GenericOrb` (lines 1-77) extends `Node2D` and has **no Area2D node**
- Child orbs like `BlueOrb` have `$Area2D` with collision detection
- Design says "Skip child orb setup" when `_orb_data` is set
- Without a child orb, there is NO collision detection at all

**The Problem:**
```
Old path: GenericOrb → BlueOrb → Area2D → collision → orb_collected() ✓
New path: GenericOrb (with _orb_data) → ??? → NO COLLISION → behaviors never execute ✗
```

**Question:** How should OrbData orbs detect collision with the ball?

**Option A: Add Area2D to GenericOrb** (minimal change)
- Add an Area2D + CollisionShape2D as children of GenericOrb scene
- When `_orb_data` is set, use this Area2D (configure radius from `orb_data.collision_radius`)
- When `_props` is used, keep Area2D disabled (child orbs handle collision)
- Requires: Edit `scenes/generic_orb.tscn` + ~10 lines in `generic_orb.gd`

**Option B: Create a new "DataOrb" child scene**
- Create `scenes/data_orb.tscn` with just Sprite2D + Area2D + CollisionShape2D
- When `_orb_data` is set, instantiate data_orb as the child instead of blue/red/half_solid
- Keeps GenericOrb scene unchanged, but adds a new scene file
- Requires: New scene file + ~15 lines in `generic_orb.gd`

**Option C: Use a completely separate scene for OrbData orbs**
- Create `scenes/orb_data.tscn` extending Area2D directly
- OrbSpawner chooses between `generic_orb_scene` (old) and `orb_data_scene` (new)
- Cleanest separation but requires more scene management
- Requires: New scene file + changes to OrbSpawner

**Why this matters:** Without collision detection, OrbData orbs are completely non-functional. This is a blocking issue that must be resolved before any implementation can proceed.

---

## Answer 3 (2026-03-10)

**Recommendation: Option A (Add Area2D to GenericOrb)**

### Research Analysis

**Scene Structure Evidence:**
```
generic_orb.tscn:
  Node2D (generic_orb) ← GenericOrb.gd, NO Area2D
    └── Timer
    └── Node2D (child_orbs)
        └── blue_orb (instance) ← Has Area2D + CollisionShape2D
        └── red_orb (instance) ← Has Area2D + CollisionShape2D
        └── half_solid_orb (instance) ← Has Area2D + CollisionShape2D
```

**Collision Flow Today:**
1. GenericOrb picks ONE child orb based on OrbProps.Type
2. Unused child orbs are freed via `queue_free()` in `converge_orb()`
3. The remaining child orb's Area2D detects ball collision
4. Child orb calls `orb_collected()` → `OrbCollectedEvent.invoke(_props)`

**The Gap:**
When `_orb_data` is set, the design says "Skip child orb setup" which means:
- No child orb → No Area2D → No collision detection → Behaviors never execute

### Option Comparison

| Aspect | Option A (Add to GenericOrb) | Option B (DataOrb child) | Option C (Separate scene) |
|--------|------------------------------|--------------------------|---------------------------|
| Files changed | 2 (scene + script) | 3 (scene + script + new scene) | 3+ (spawner changes) |
| Code complexity | Low (conditional enable) | Medium (child selection) | High (dual paths) |
| Risk to old system | None (disabled when using old path) | None | None |
| Pattern consistency | Single container | Follows child pattern | Breaks pattern |
| Future flexibility | High | Medium | Low |

### Recommended Implementation

**1. Modify `scenes/generic_orb.tscn`:**
```
[node name="generic_orb" type="Node2D"]
  [node name="Timer" ...]
  [node name="child_orbs" ...]
+ [node name="DataOrbArea" type="Area2D"]
+   [node name="CollisionShape2D" type="CollisionShape2D"]
```

**2. Modify `scripts/generic_orb.gd`:**
```gdscript
@onready var data_orb_area: Area2D = $DataOrbArea
@onready var data_orb_collision: CollisionShape2D = $DataOrbArea/CollisionShape2D
var _orb_data: OrbData = null

func _ready() -> void:
    # Existing setup
    update_orb()
    init_timer()
    disable_child_orb()
    # NEW: Disable data orb area by default
    data_orb_area.monitoring = false

func set_orb_data(orb_data: OrbData) -> void:
    _orb_data = orb_data
    # Configure collision from OrbData
    var shape := CircleShape2D.new()
    shape.radius = orb_data.collision_radius
    data_orb_collision.shape = shape
    data_orb_area.monitoring = true
    # Create visual sprite from OrbData.texture
    _create_orb_sprite(orb_data)

func _on_data_orb_area_body_entered(body: Node2D) -> void:
    if body.name == "ball" and _orb_data != null:
        _on_orb_collected()

func _on_orb_collected() -> void:
    if _orb_data != null:
        var context := {"orb": self, "orb_data": _orb_data}
        for behavior: OrbBehavior in _orb_data.behaviors:
            behavior.execute(context)
        SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
        queue_free()
```

### Confidence: 90%

**Why high confidence:**
1. Minimal change - adds 2 nodes to scene, ~20 lines to script
2. Old path unaffected - Area2D stays disabled when using OrbProps
3. No collision conflicts - child orbs are freed when using OrbData path
4. Follows Godot patterns - Area2D + body_entered signal is standard

**Remaining work (F2, F3 from Design Critic):**
- F2 (Behavior process integration) - Add `_process()` loop for MovementBehavior
- F3 (Chain collection) - Define `_collect_orb()` helper in behaviors

These are **not blocking** and can be addressed in implementation after F1 is resolved.

---

## Question 4 (2026-03-10) - MVP Bridge Complete: What's Next?

**Context:** The MVP bridge integration is complete:
- ✅ OrbAdapter utility created
- ✅ GenericOrb supports OrbData with collision
- ✅ OrbSpawner has `orb_data_array` and `debug_force_orb_type`
- ✅ test_orb.tres resource created
- ✅ 267 tests passing

**What remains from original requirements:**
- ❌ 8 new orb types (Burst, Vertical Line, Horizontal Line, Slow Fall, Sticky Head, Double Value, Combo Starter, Drifter)
- ❌ New behavior classes (BurstBehavior, LineClearBehavior, MovementBehavior, ComboStarterBehavior)
- ❌ In-game manual verification of the bridge

**Question:** What should be the priority for the next phase?

**Option A: Manual Verification First** (safest)
- Verify the bridge works in-game with test_orb.tres before building more on top
- Low risk: catch any integration issues early
- Time: ~10 minutes in Godot editor

**Option B: Implement New Orb Types** (more features)
- Implement the 4 new behavior classes + 8 orb resource files
- Builds on potentially unverified foundation
- Time: 2-3 hours of implementation

**Option C: Consider MVP Complete, Archive Project** (closure)
- The bridge infrastructure is done and tested
- New orb types can be added incrementally later
- Document the manual verification steps and close the loop

**Why this matters:** Option A validates the work before expansion. Option B adds features on untested ground. Option C acknowledges the infrastructure is complete and moves on.
