# Orb System Expansion - Implementation Plan (MINIMUM VIABLE)

> **Approach:** Bridge Pattern (preserve old, add new)
> **Generated:** 2026-03-10 (Planner Phase - REVISED for Minimum Integration)
> **Design Confidence:** 95%
> **Objective:** Get ONE new orb type spawning and collectible

---

## Current Implementation State

### ✅ Already Complete (Verified in Code)
| Component | Evidence |
|-----------|----------|
| GenericOrb F1 (Collision) | `scripts/generic_orb.gd:6-7,79-87,148-154` |
| GenericOrb F2 (Process Loop) | `scripts/generic_orb.gd:42-56` |
| GenericOrb.set_orb_data() | `scripts/generic_orb.gd:62-91` |
| GenericOrb.on_orb_collected() | `scripts/generic_orb.gd:158-168` |
| OrbData Resource | `scripts/data/orb_data.gd` |
| OrbBehavior Base | `scripts/data/behaviors/orb_behavior.gd` |
| ScoreBehavior | `scripts/data/behaviors/score_behavior.gd` |
| TimedModifierBehavior | `scripts/data/behaviors/timed_modifier_behavior.gd` |
| EffectManager | Singleton registered |
| F1/F2 Tests | 241 tests passing |

### ❌ Blocking Runtime Integration
| Component | File |
|-----------|------|
| OrbAdapter utility | `scripts/utils/orb_adapter.gd` (MISSING) |
| Test orb resource | `resources/orbs/test_orb.tres` (MISSING) |
| OrbSpawner bridge | `scripts/orb_spawner.gd` (NEEDS orb_data_array) |

---

## Test Strategy (Minimum)

### Unit Tests

| Test File | Test Cases |
|-----------|------------|
| `test_orb_adapter.gd` | `test_create_orb_from_data_returns_generic_orb`, `test_created_orb_has_orb_data_set`, `test_null_data_returns_null` |
| `test_orb_spawner_orb_data.gd` | `test_orb_data_array_export_exists`, `test_combined_pool_selection`, `test_debug_force_orb_type` |

### Integration Test

| Test File | Test Cases |
|-----------|------------|
| `test_orb_spawner_bridge.gd` | `test_spawns_orb_props_orbs_unchanged`, `test_spawns_orb_data_orbs_via_adapter` |

### E2E Manual Verification Scenario

**Scenario:** Player collects a test orb and verifies score is awarded

**Prerequisites:**
1. Game runs without errors
2. `debug_force_orb_type` export available in OrbSpawner

**Steps:**
1. In Godot editor, open scene with OrbSpawner
2. Set `debug_force_orb_type` to "Test Orb"
3. Add `test_orb.tres` to `orb_data_array` in OrbSpawner
4. Run game (F5)
5. Wait for orb to spawn
6. Verify orb has blue_ball texture (reused)
7. Guide ball to collect orb
8. Verify score increases
9. Verify collection sound plays

**Success Criteria:**
- Test orb spawns with correct visual
- Test orb is collectible by ball
- Score is awarded on collection
- No runtime errors
- Existing blue/red/half-solid orbs still work
- `./devscripts/test.sh` exits 0

---

## Implementation Steps (TDD Order)

### Step 1: Create OrbAdapter Utility

**Files:**
- `scripts/utils/orb_adapter.gd` (CREATE)
- `tests/unit/test_orb_adapter.gd` (CREATE)

**TDD Flow:**
1. Write test: `test_create_orb_from_data_returns_generic_orb`
2. Write test: `test_created_orb_has_orb_data_set`
3. Write test: `test_null_data_returns_null`
4. Implement OrbAdapter to pass tests

**API:**
```gdscript
class_name OrbAdapter

## Creates a configured GenericOrb from OrbData.
## Returns null if orb_data is null.
static func create_orb_from_data(generic_orb_scene: PackedScene, orb_data: OrbData) -> GenericOrb:
    if generic_orb_scene == null or orb_data == null:
        return null

    var orb: GenericOrb = generic_orb_scene.instantiate()
    orb.set_orb_data(orb_data)
    return orb
```

**Tests that pass after this step:**
- `test_orb_adapter.gd` - All 3 tests pass

**Demo:** Can create GenericOrb from OrbData via adapter

---

### Step 2: Modify OrbSpawner for Bridge Integration

**Files:**
- `scripts/orb_spawner.gd` (MODIFY)
- `tests/unit/test_orb_spawner_orb_data.gd` (CREATE)

**Changes:**
1. Add `@export var orb_data_array: Array[OrbData] = []`
2. Add `@export var debug_force_orb_type: String = ""`
3. Modify `_spawn_from_props()` to select from combined pool
4. Add `_get_rarity_weight(rarity: OrbRarity) -> int` helper
5. Add `_weighted_select(pool: Array) -> Dictionary` helper

**TDD Flow:**
1. Write test: `test_orb_data_array_export_exists`
2. Write test: `test_combined_pool_includes_orb_data`
3. Write test: `test_debug_force_orb_type_overrides_selection`
4. Write test: `test_empty_pool_returns_null`
5. Implement changes to pass tests

**Modified _spawn_from_props():**
```gdscript
func _spawn_from_props() -> Node:
    # Build combined pool
    var pool: Array = []

    for props: OrbProps in orb_props:
        pool.append({"source": props, "is_data": false})

    for data: OrbData in orb_data_array:
        pool.append({"source": data, "is_data": true})

    if pool.is_empty():
        return null

    # Debug override
    if not debug_force_orb_type.is_empty():
        for entry in pool:
            if entry.is_data and entry.source.display_name == debug_force_orb_type:
                return OrbAdapter.create_orb_from_data(generic_orb_scene, entry.source)
        return null  # Forced type not found

    # Random selection
    var selected: Dictionary = pool[randi() % pool.size()]
    if selected.is_data:
        return OrbAdapter.create_orb_from_data(generic_orb_scene, selected.source)
    else:
        return create_orb_copy(selected.source)
```

**Tests that pass after this step:**
- `test_orb_spawner_orb_data.gd` - All 4 tests pass

**Demo:** Spawner produces both OrbProps and OrbData orbs

---

### Step 3: Create Test Orb Resource

**Files:**
- `resources/orbs/test_orb.tres` (CREATE)
- `resources/orbs/score_behavior.tres` (CREATE - embedded behavior)

**Test Orb Properties:**
```ini
[gd_resource type="OrbData" format=3 uid="..."]

[resource]
display_name = "Test Orb"
texture = ExtResource("1_blueball")  # res://sprites/blue_ball.png
scale = Vector2(1, 1)
base_score = 5
lifespan = 30.0
rarity = 0  # COMMON
collision_radius = 32.0
is_half_solid = false
spawn_animation_duration = 1.5
behaviors/0 = SubResource("ScoreBehavior_1")

[sub_resource type="ScoreBehavior" id="ScoreBehavior_1"]
behavior_id = "score"
base_score = 5
```

**Note:** Since .tres files are Godot-specific format, create them via script or manual editor work.

**Tests that pass after this step:**
- Existing tests still pass

**Demo:** Test orb resource can be loaded and has correct properties

---

### Step 4: Integration Test

**Files:**
- `tests/integration/test_orb_spawner_bridge.gd` (CREATE)

**TDD Flow:**
1. Write test: `test_spawns_orb_props_orbs_unchanged`
2. Write test: `test_spawns_orb_data_orbs_via_adapter`
3. Run all tests

**Demo:** Full bridge flow works end-to-end

---

### Step 5: Validation

**Tasks:**
1. Run `./devscripts/test.sh` - must exit 0
2. Manual verification:
   - Add test_orb.tres to OrbSpawner's orb_data_array
   - Set debug_force_orb_type = "Test Orb"
   - Run game
   - Verify orb spawns with blue_ball texture
   - Collect orb with ball
   - Verify score increases by 5
3. Verify existing blue/red/half-solid orbs still work

**Demo:** Complete working system

---

## File Summary

### Files to Create
| File | Purpose |
|------|---------|
| `scripts/utils/orb_adapter.gd` | Bridge utility for OrbData → GenericOrb |
| `resources/orbs/test_orb.tres` | Test orb definition |
| `tests/unit/test_orb_adapter.gd` | Adapter unit tests |
| `tests/unit/test_orb_spawner_orb_data.gd` | Spawner unit tests |
| `tests/integration/test_orb_spawner_bridge.gd` | Integration tests |

### Files to Modify
| File | Changes |
|------|---------|
| `scripts/orb_spawner.gd` | Add orb_data_array, debug_force_orb_type, combined pool selection |

### Files Unchanged
- `scripts/generic_orb.gd` (F1/F2 already complete)
- `scripts/data/orb_data.gd` (exists)
- `scripts/data/behaviors/orb_behavior.gd` (exists)
- `scripts/data/behaviors/score_behavior.gd` (exists)
- `scripts/blue_orb.gd`, `red_orb.gd`, `half_solid_orb.gd` (unchanged)

---

## Why This Is Minimum

1. **One orb type only** - Test orb with existing ScoreBehavior
2. **No new behaviors** - Reuse existing ScoreBehavior
3. **No new textures** - Reuse sprites/blue_ball.png
4. **Minimal spawner changes** - Just add array export and selection logic
5. **OrbAdapter is essential** - Required bridge between OrbData and GenericOrb

---

## Success Criteria

- [ ] OrbAdapter utility created with tests
- [ ] OrbSpawner has orb_data_array export
- [ ] Test orb resource created
- [ ] `./devscripts/test.sh` exits 0
- [ ] Test orb spawns in-game
- [ ] Test orb is collectible
- [ ] Score is awarded on collection
- [ ] Existing orbs still work

---

## Handoff

**Event:** `plan.ready`
**Payload:** `steps: 5, tests: 7, e2e: manual verification checklist`
**Next:** Task Writer converts steps to code tasks with Given-When-Then criteria
