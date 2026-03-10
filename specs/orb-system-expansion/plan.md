# Orb System Expansion - Implementation Plan

> **Status:** Ready for implementation
> **Source:** design.md, context.md, implementation/plan.md (25-step detailed plan)

---

## Test Strategy

### Unit Tests

| Component | Test File | Key Test Cases |
|-----------|-----------|----------------|
| **OrbData** | `test_orb_data.gd` | Default values, property assignment, serialization |
| **OrbBehavior** | `test_orb_behavior.gd` | Base methods callable, subclass override |
| **ScoreBehavior** | `test_score_behavior.gd` | Base score, multiplier effect, combo effect, double value |
| **TimedModifierBehavior** | `test_timed_modifier_behavior.gd` | Effect applied, correct value, expiration |
| **MovementBehavior** | `test_movement_behavior.gd` | Direction movement, oscillation, spawn delay |
| **ChainReactionBehavior** | `test_chain_reaction_behavior.gd` | Radius detection, self exclusion |
| **LineClearBehavior** | `test_line_clear_behavior.gd` | Vertical/horizontal detection, tolerance |
| **EffectManager** | `test_effect_manager.gd` | Apply/remove/has/get, stacking, expiration, time_scale |
| **OrbSpawner** | `test_orb_spawner.gd` | Weighted selection, max limit enforcement |
| **Orb** | `test_orb.gd` | Setup applies data, spawn animation, collect flow, lifespan |

### Integration Tests

| Scenario | Test File | Purpose |
|----------|-----------|---------|
| **Orb Collection Flow** | `test_orb_collection_flow.gd` | Ball collides → behaviors execute → score added → orb freed |
| **Effect Integration** | `test_effect_integration.gd` | Effects modify ball physics, time_scale |
| **Game Over Cleanup** | `test_game_over_cleanup.gd` | Effects clear, time_scale resets |

### E2E Test Scenario (Manual)

**Prerequisites:** Game running, all 12 orb types in spawn table

**Steps:**
1. Start new game from main menu
2. Play for 2 minutes, collecting various orbs
3. Collect Score Multiplier orb → verify score doubled
4. Collect Slow Fall orb → verify ball falls slower
5. Collect Time Slow orb → verify game slows
6. Collect Burst orb near cluster → verify all nearby orbs collected
7. Collect Line orb → verify column/row cleared with visual effect
8. Let combo expire → verify multiplier resets
9. Trigger game over → verify effects cleared, time normal
10. Verify no console errors throughout

---

## Implementation Steps (TDD Order)

### Phase 1: Core Infrastructure

#### Step 1: Create OrbData Resource Class
**Files:** `scripts/data/orb_data.gd`, `tests/unit/test_orb_data.gd`

**Test First:**
```gdscript
func test_default_values():
    var data = OrbData.new()
    assert_eq(data.display_name, "Orb")
    assert_eq(data.base_score, 1)
    assert_eq(data.lifespan, 30.0)

func test_property_assignment():
    var data = OrbData.new()
    data.display_name = "Test Orb"
    data.base_score = 5
    assert_eq(data.display_name, "Test Orb")
    assert_eq(data.base_score, 5)
```

**Implement:** Create `OrbData` with `@export` properties for display, gameplay, physics, behaviors

**Demo:** `./devscripts/test.sh` passes test_orb_data

---

#### Step 2: Create OrbBehavior Abstract Base Class
**Files:** `scripts/data/behaviors/orb_behavior.gd`, `tests/unit/test_orb_behavior.gd`

**Test First:**
```gdscript
func test_base_execute_callable():
    var behavior = OrbBehavior.new()
    behavior.execute({})  # Should not crash

func test_process_callable():
    var behavior = OrbBehavior.new()
    behavior.process(null, 0.016)  # Should not crash
```

**Implement:** Abstract `OrbBehavior` with `execute()`, `process()`, `on_spawn()` methods

**Demo:** Tests pass, base class instantiable

---

#### Step 3: Create EffectManager Singleton
**Files:** `scripts/effect_manager.gd`, `tests/unit/test_effect_manager.gd`

**Test First:**
```gdscript
func test_apply_effect():
    EffectManager.apply_effect("test", 2.0, 10.0)
    assert_true(EffectManager.has_effect("test"))

func test_get_effect_value():
    EffectManager.apply_effect("test", 2.0, 10.0)
    assert_eq(EffectManager.get_effect_value("test"), 2.0)

func test_effect_expiration():
    EffectManager.apply_effect("test", 1.0, 0.1)
    await get_tree().create_timer(0.2).timeout
    assert_false(EffectManager.has_effect("test"))

func test_stacking_score_multiplier():
    EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
    EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
    assert_eq(EffectManager.get_effect_value("score_multiplier"), 4.0)

func test_time_slow_sets_engine_time_scale():
    EffectManager.apply_effect("time_slow", 0.5, 10.0)
    assert_eq(Engine.time_scale, 0.5)
```

**Implement:**
- `ActiveEffect` inner class
- `apply_effect()`, `remove_effect()`, `has_effect()`, `get_effect_value()`
- Stacking logic for each effect type
- `_process()` for expiration
- Register as autoload in `project.godot`

**Demo:**
```gdscript
EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
print(EffectManager.has_effect("score_multiplier"))  # true
```

---

#### Step 4: Create ScoreBehavior
**Files:** `scripts/data/behaviors/score_behavior.gd`, `tests/unit/test_score_behavior.gd`

**Test First:**
```gdscript
func test_base_score():
    var behavior = ScoreBehavior.new()
    behavior.score_value = 5
    # Mock context, execute, verify AddScoreEvent fired with 5

func test_with_score_multiplier():
    EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
    var behavior = ScoreBehavior.new()
    behavior.score_value = 5
    # Execute, verify AddScoreEvent fired with 10

func test_with_double_value_consumed():
    EffectManager.apply_effect("double_value", true, -1.0)
    var behavior = ScoreBehavior.new()
    behavior.score_value = 5
    # Execute, verify AddScoreEvent fired with 10
    # Verify double_value effect removed
```

**Implement:** `ScoreBehavior` with `score_value`, applies multipliers and double value

**Demo:** Create test orb, collect, verify score with/without multipliers

---

### Phase 2: Unified Orb Scene

#### Step 5: Create Unified Orb Scene and Script
**Files:** `scripts/orb.gd`, `scenes/orb.tscn`, `tests/unit/test_orb.gd`

**Test First:**
```gdscript
func test_setup_applies_data():
    var orb = Orb.new()
    var data = OrbData.new()
    data.display_name = "Test"
    orb.setup(data)
    assert_eq(orb.orb_data, data)

func test_collect_fires_event():
    var orb = _spawn_orb()
    # Listen for OrbCollectedEvent
    orb.collect()
    # Verify event fired

func test_spawn_animation():
    var orb = _spawn_orb()
    assert_true(orb._is_spawning)
    assert_eq(orb.sprite.modulate.a, 0.0)
```

**Implement:**
- Node structure: Node2D > Sprite2D, Area2D > CollisionShape2D, StaticBody2D, Timer
- `setup()`, `_apply_data()`, `collect()`
- Spawn animation in `_process()`
- Half-solid collision handling

**Demo:** Spawn orb in test scene, watch fade-in, simulate ball collision

---

#### Step 6: Update OrbSpawner
**Files:** `scripts/data/orb_spawn_entry.gd`, `scripts/orb_spawner.gd`, `tests/unit/test_orb_spawner.gd`

**Test First:**
```gdscript
func test_weighted_selection():
    var spawner = OrbSpawner.new()
    # Add entries with weights 100 and 50
    # Run selection 1000 times
    # Verify ratio approximately 2:1

func test_max_orbs_limit():
    var spawner = OrbSpawner.new()
    spawner.max_orbs = 3
    # Spawn 5 times
    # Verify only 3 orbs exist
```

**Implement:**
- `OrbSpawnEntry` resource with `orb_data` and `weight`
- Weighted random selection in `_select_orb_data()`
- Max orbs check before spawn

**Demo:** Configure spawn table, run scene, verify distribution

---

#### Step 7: Migrate Existing Orbs to Resources
**Files:** `resources/orbs/*.tres`, `resources/behaviors/*.tres`

**Prerequisite:** Add `OrbRarity` enum to `scripts/utils/enums.gd`

**Create:**
- `blue_orb.tres`: score=2, rarity=COMMON
- `red_orb.tres`: score=3, rarity=COMMON
- `half_solid_orb.tres`: score=8, rarity=RARE, is_half_solid=true

**Test:** Each resource loads, values correct

**Demo:** Configure spawner with migrated orbs, play game, verify parity

---

### Phase 3: Cleanup & Validation

#### Step 8: Delete Old Files
**Delete:**
- `scripts/generic_orb.gd`, `blue_orb.gd`, `red_orb.gd`, `half_solid_orb.gd`
- `scripts/utils/orb_properties.gd`
- `scenes/generic_orb.tscn`, `blue_orb.tscn`, `red_orb.tscn`, `half_solid_orb.tscn`

**Test:** `./devscripts/test.sh` passes, `./devscripts/smoke_test.sh` passes

**Demo:** Full game session, no errors

---

#### Step 9: Integration Test - Gameplay Parity
**Files:** `tests/integration/test_orb_parity.gd`

**Test:**
- Blue orb scores 2
- Red orb scores 3
- Half-solid reduces ball velocity to 1/3
- Orb expires after lifespan

**Demo:** Compare to pre-migration gameplay

---

### Phase 4: New Orb Behaviors

#### Step 10: Create TimedModifierBehavior
**Files:** `scripts/data/behaviors/timed_modifier_behavior.gd`, `tests/unit/test_timed_modifier_behavior.gd`

**Test First:**
```gdscript
func test_effect_applied():
    var behavior = TimedModifierBehavior.new()
    behavior.effect_id = "test_effect"
    behavior.effect_value = 2.0
    behavior.duration = 10.0
    behavior.execute({})
    assert_true(EffectManager.has_effect("test_effect"))
```

**Demo:** Create orb with TimedModifier, collect, verify effect active

---

#### Step 11: Create MovementBehavior
**Files:** `scripts/data/behaviors/movement_behavior.gd`, `tests/unit/test_movement_behavior.gd`

**Test First:**
```gdscript
func test_orb_moves():
    var behavior = MovementBehavior.new()
    behavior.speed = 50.0
    var orb = _create_mock_orb()
    var start_pos = orb.global_position
    behavior.process(orb, 1.0)
    assert_ne(orb.global_position, start_pos)

func test_oscillation():
    var behavior = MovementBehavior.new()
    behavior.oscillate = true
    behavior.oscillate_distance = 100.0
    # Run multiple process calls
    # Verify direction reverses at boundary
```

**Demo:** Watch Drifter orb oscillate

---

#### Step 12: Create ChainReactionBehavior
**Files:** `scripts/data/behaviors/chain_reaction_behavior.gd`, `tests/unit/test_chain_reaction_behavior.gd`

**Test First:**
```gdscript
func test_finds_orbs_in_radius():
    var behavior = ChainReactionBehavior.new()
    behavior.radius = 150.0
    # Place orbs at 0, 100, 200 distance
    # Execute behavior
    # Verify 0 and 100 collected, 200 not

func test_excludes_self():
    # Verify source orb not collected
```

**Demo:** Spawn cluster, collect burst, watch chain reaction

---

#### Step 13: Create LineClearBehavior
**Files:** `scripts/data/behaviors/line_clear_behavior.gd`, `tests/unit/test_line_clear_behavior.gd`

**Test First:**
```gdscript
func test_vertical_line():
    var behavior = LineClearBehavior.new()
    behavior.direction = LineClearBehavior.LineDirection.VERTICAL
    # Place orbs at same X, different Y
    # Execute behavior
    # Verify all collected

func test_tolerance():
    var behavior = LineClearBehavior.new()
    behavior.tolerance = 20.0
    # Place orb at X+25
    # Verify NOT collected
```

**Demo:** Collect line orb, watch visual effect and clear

---

### Phase 5: First Orb Pack (9 New Orbs)

Each orb follows the same pattern: Create resource, configure behaviors, test.

| Step | Orb | Behaviors | Score | Rarity |
|------|-----|-----------|-------|--------|
| 14 | Score Multiplier | Score(3) + TimedModifier(score_multiplier, 2.0, 45s) | 3 | UNCOMMON |
| 15 | Slow Fall | Score(2) + TimedModifier(slow_fall, 0.5, 45s) + Ball integration | 2 | UNCOMMON |
| 16 | Double Value | Score(1) + TimedModifier(double_value, true, -1s) | 1 | UNCOMMON |
| 17 | Time Slow | Score(5) + TimedModifier(time_slow, 0.5, 10s) | 5 | RARE |
| 18 | Combo Starter | Score(3) + TimedModifier(combo_chain, 0, 10s) | 3 | RARE |
| 19 | Drifter | Score(2) + Movement(50, oscillate) | 2 | UNCOMMON |
| 20 | Burst | Score(8) + ChainReaction(150) | 8 | RARE |
| 21 | Vertical Line | Score(5) + LineClear(VERTICAL) | 5 | RARE |
| 22 | Horizontal Line | Score(5) + LineClear(HORIZONTAL) | 5 | RARE |

**Step 15 Special:** Update `scripts/ball.gd` to poll EffectManager for slow_fall

```gdscript
func _physics_process(delta):
    _apply_effect_modifiers()
    # ... rest of physics

func _apply_effect_modifiers():
    if EffectManager.has_effect("slow_fall"):
        fall_speed = base_fall_speed * EffectManager.get_effect_value("slow_fall")
    else:
        fall_speed = base_fall_speed
```

---

### Phase 6: Final Validation

#### Step 23: Update Spawn Table
**Configure weights:**

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

**Demo:** Play 5 minutes, verify all orb types appear

---

#### Step 24: Final Validation
**Automated:**
```bash
./devscripts/import.sh
./devscripts/test.sh
./devscripts/smoke_test.sh
```

**Manual Checklist:**
- [ ] Game boots without errors
- [ ] All 12 orb types spawn
- [ ] Score tracking correct
- [ ] Effect stacking works
- [ ] Effects expire on time
- [ ] Effects clear on game over
- [ ] Time slow affects game speed
- [ ] Slow fall affects ball physics
- [ ] Line orbs clear correctly
- [ ] Burst orb clears radius
- [ ] Drifter orb moves
- [ ] Combo chain multiplies score
- [ ] Double value works one-time
- [ ] No console errors

---

## Success Criteria

| Criterion | Verification |
|-----------|--------------|
| All unit tests pass | `./devscripts/test.sh` exits 0 |
| Smoke test passes | `./devscripts/smoke_test.sh` exits 0 |
| All 12 orbs functional | Manual E2E test |
| No console errors | Manual verification |
| Gameplay parity maintained | Comparison to pre-migration |
| Code coverage maintained | GUT test runner output |

---

## Handoff

**Event:** `plan.ready`
**Payload:** `steps: 24, tests: 15+, e2e: manual verification checklist`
**Next:** Task Writer converts steps to code tasks with Given-When-Then criteria
