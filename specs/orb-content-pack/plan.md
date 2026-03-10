# Implementation Plan - Orb Content Pack

## Overview

This plan implements 8 new orb types using the existing OrbData/OrbBehavior/EffectManager systems. The approach follows TDD: write failing tests first, then implement behaviors to make them pass.

---

## Test Strategy

### Unit Tests (Isolated Component Behavior)

#### test_score_behavior.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| base_score_awarded | ScoreBehavior with base_score=5 | execute() with context | ScoreManager.add_score(5) called |
| double_value_applied | double_value effect active, base_score=3 | execute() | Score doubled to 6 |
| score_multiplier_applied | score_multiplier=2x, base_score=5 | execute() | Score is 10 |
| combined_multipliers | double_value + score_multiplier=2x | execute() | Score is base * 2 * 2 |

#### test_chain_reaction_behavior.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| orbs_in_radius_cleared | 3 orbs within 150px, 1 outside | execute() | 3 orbs collected, 1 not |
| self_not_collected | Source orb in radius | execute() | Source orb NOT collected |
| empty_radius | No orbs in scene | execute() | No crash, no-op |
| custom_radius | radius=50, orb at 75px | execute() | Orb NOT collected |

#### test_line_clear_behavior.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| vertical_clear | 3 orbs with same X within 20px | execute(VERTICAL) | 3 orbs collected |
| horizontal_clear | 3 orbs with same Y within 20px | execute(HORIZONTAL) | 3 orbs collected |
| tolerance_respected | orb at 25px offset, tolerance=20 | execute() | Orb NOT collected |
| self_excluded | Source orb on line | execute() | Source NOT collected |

#### test_movement_behavior.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| horizontal_oscillation | pattern=HORIZONTAL, amplitude=75 | process(1.0s) | orb.x = initial + sin(TAU) * 75 |
| vertical_oscillation | pattern=VERTICAL, amplitude=50 | process(1.0s) | orb.y = initial + sin(TAU) * 50 |
| speed_affects_cycle | speed=2, process(0.5s) | Same position as speed=1, process(1.0s) |
| initial_position_captured | First process() call | _initial_position set |

#### test_timed_modifier_behavior.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| effect_applied | effect_id="slow_fall", value=0.5, duration=45 | execute() | EffectManager.has_effect("slow_fall") |
| empty_effect_id_skipped | effect_id="" | execute() | No effect applied |
| value_passed_correctly | value=0.3 | execute() | get_effect_value returns 0.3 |

#### test_sticky_head_behavior.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| effect_applied | StickyHeadBehavior(0.5, 15.0) | execute() | EffectManager.has_effect("sticky_head") |
| damping_value_correct | damping=0.5 | execute() | get_effect_value("sticky_head") == 0.5 |
| duration_correct | duration=15.0 | execute() | Effect expires after 15s |

#### test_ball_sticky_head_integration.gd
| Test Case | Given | When | Then |
|-----------|-------|------|------|
| velocity_dampened_on_player_collision | sticky_head active, ball hits player | _on_body_entered(player) | linear_velocity.y *= 0.5 |
| no_dampen_without_effect | No sticky_head, ball hits player | _on_body_entered(player) | velocity unchanged |
| no_dampen_on_non_player | sticky_head active, ball hits ground | _on_body_entered(ground) | Only game_over logic |

### Integration Tests (Components Working Together)

| Test | Description | Expected Result |
|------|-------------|-----------------|
| burst_orb_chain | Spawn burst orb + 5 orbs in radius | Collect burst -> all 5 collected |
| line_orb_clear | Spawn line orb + 3 aligned orbs | Collect line orb -> 3 cleared |
| drifter_movement | Spawn drifter orb, wait 2s | Position changed horizontally |
| effect_duration | Collect slow_fall orb, wait 46s | Effect expired |

### E2E Test Scenario (Manual Verification)

**Complete Orb Pack Verification:**
1. Start game in test mode
2. Force-spawn each orb type one at a time
3. Collect each orb and verify its effect
4. Confirm all 8 orb types function correctly
5. Verify no crashes or unexpected behavior

---

## Implementation Steps (TDD Order)

### Step 1: Player Group Fix (Prerequisite)
**Files:** `scripts/physics_player.gd`
**Tests:** `test_player_in_group.gd` (new)

**Changes:**
```gdscript
# In physics_player.gd _ready():
func _ready() -> void:
    add_to_group("player")  # ADD THIS LINE - CRITICAL for sticky_head
    load_constants()
    # ...
```

**Test to pass:**
```gdscript
func test_player_in_player_group():
    var player = physics_player.new()
    add_child(player)
    assert_true(player.is_in_group("player"), "Player should be in 'player' group")
```

**Demo:** Player can be identified via `is_in_group("player")`

---

### Step 2: ScoreBehavior Implementation
**Files:**
- Create: `scripts/data/behaviors/score_behavior.gd`
- Create: `tests/unit/test_score_behavior.gd`

**Implementation:**
```gdscript
class_name ScoreBehavior extends OrbBehavior

@export var base_score: int = 1

func execute(context: Dictionary) -> void:
    var score: int = base_score

    # Apply double value if active
    if EffectManager.has_effect("double_value"):
        score *= 2

    # Apply score multiplier if active
    var multiplier: Variant = EffectManager.get_effect_value("score_multiplier")
    if multiplier != null:
        score = int(score * float(multiplier))

    ScoreManager.add_score(score)
```

**Tests to pass:**
- base_score_awarded
- double_value_applied
- score_multiplier_applied
- combined_multipliers

**Demo:** Can award base score and apply multipliers

---

### Step 3: TimedModifierBehavior Implementation
**Files:**
- Create: `scripts/data/behaviors/timed_modifier_behavior.gd`
- Create: `tests/unit/test_timed_modifier_behavior.gd`

**Implementation:**
```gdscript
class_name TimedModifierBehavior extends OrbBehavior

@export var effect_id: String = ""
@export var value: float = 1.0
@export var duration: float = 10.0

func execute(context: Dictionary) -> void:
    if effect_id.is_empty():
        return
    EffectManager.apply_effect(effect_id, value, duration, context.get("orb"))
```

**Tests to pass:**
- effect_applied
- empty_effect_id_skipped
- value_passed_correctly

**Demo:** Can apply slow_fall, double_value, combo_chain effects

---

### Step 4: ChainReactionBehavior Implementation
**Files:**
- Create: `scripts/data/behaviors/chain_reaction_behavior.gd`
- Create: `tests/unit/test_chain_reaction_behavior.gd`

**Implementation:**
```gdscript
class_name ChainReactionBehavior extends OrbBehavior

@export var radius: float = 150.0

func execute(context: Dictionary) -> void:
    var source_orb: Node = context.get("orb")
    if source_orb == null or not source_orb.is_inside_tree():
        return

    var all_orbs: Array = source_orb.get_tree().get_nodes_in_group("orbs")

    for orb in all_orbs:
        if orb == source_orb:
            continue
        if not orb.is_inside_tree():
            continue
        if orb.global_position.distance_to(source_orb.global_position) <= radius:
            if orb.has_method("collect"):
                orb.collect()
```

**Tests to pass:**
- orbs_in_radius_cleared
- self_not_collected
- empty_radius
- custom_radius

**Demo:** Burst orb clears nearby orbs

---

### Step 5: LineClearBehavior Implementation
**Files:**
- Create: `scripts/data/behaviors/line_clear_behavior.gd`
- Create: `tests/unit/test_line_clear_behavior.gd`

**Implementation:**
```gdscript
class_name LineClearBehavior extends OrbBehavior

enum LineDirection { VERTICAL, HORIZONTAL }

@export var direction: LineDirection = LineDirection.VERTICAL
@export var tolerance: float = 20.0

func execute(context: Dictionary) -> void:
    var source_orb: Node = context.get("orb")
    if source_orb == null or not source_orb.is_inside_tree():
        return

    var all_orbs: Array = source_orb.get_tree().get_nodes_in_group("orbs")
    var source_pos: Vector2 = source_orb.global_position

    for orb in all_orbs:
        if orb == source_orb:
            continue
        if not orb.is_inside_tree():
            continue

        var orb_pos: Vector2 = orb.global_position
        var matches: bool = false

        match direction:
            LineDirection.VERTICAL:
                matches = abs(orb_pos.x - source_pos.x) < tolerance
            LineDirection.HORIZONTAL:
                matches = abs(orb_pos.y - source_pos.y) < tolerance

        if matches and orb.has_method("collect"):
            orb.collect()
```

**Tests to pass:**
- vertical_clear
- horizontal_clear
- tolerance_respected
- self_excluded

**Demo:** Line orbs clear aligned orbs

---

### Step 6: MovementBehavior Implementation
**Files:**
- Create: `scripts/data/behaviors/movement_behavior.gd`
- Create: `tests/unit/test_movement_behavior.gd`

**Implementation:**
```gdscript
class_name MovementBehavior extends OrbBehavior

enum MovementPattern { HORIZONTAL_OSCILLATE, VERTICAL_OSCILLATE }

@export var pattern: MovementPattern = MovementPattern.HORIZONTAL_OSCILLATE
@export var amplitude: float = 75.0
@export var speed: float = 2.0  # cycles per second

var _initial_position: Vector2 = Vector2.ZERO
var _time_elapsed: float = 0.0
var _initialized: bool = false

func process(orb: Node, delta: float) -> void:
    if orb == null:
        return

    if not _initialized:
        _initial_position = orb.global_position
        _initialized = true

    _time_elapsed += delta

    match pattern:
        MovementPattern.HORIZONTAL_OSCILLATE:
            var offset: float = sin(_time_elapsed * speed * TAU) * amplitude
            orb.global_position.x = _initial_position.x + offset
        MovementPattern.VERTICAL_OSCILLATE:
            var offset: float = sin(_time_elapsed * speed * TAU) * amplitude
            orb.global_position.y = _initial_position.y + offset
```

**Tests to pass:**
- horizontal_oscillation
- vertical_oscillation
- speed_affects_cycle
- initial_position_captured

**Demo:** Drifter orb moves in sine wave pattern

---

### Step 7: StickyHeadBehavior + Ball Integration
**Files:**
- Create: `scripts/data/behaviors/sticky_head_behavior.gd`
- Create: `tests/unit/test_sticky_head_behavior.gd`
- Create: `tests/unit/test_ball_sticky_head_integration.gd`
- Modify: `scripts/ball.gd`

**Behavior Implementation:**
```gdscript
class_name StickyHeadBehavior extends OrbBehavior

@export var damping_factor: float = 0.5  # 50% bounce velocity
@export var duration: float = 15.0  # 15-20 seconds

func execute(context: Dictionary) -> void:
    EffectManager.apply_effect("sticky_head", damping_factor, duration, context.get("orb"))
```

**Ball Modification:**
```gdscript
# In ball.gd _on_body_entered(body):
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("ground") && !game_over:
        game_over = true
        GameOverEvent.invoke()
        PauseEvent.invoke(true)
        SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)
    elif body.is_in_group("half_solid"):
        linear_velocity = linear_velocity/3

    # NEW: Apply sticky head dampening on player collision
    if body.is_in_group("player") and EffectManager.has_effect("sticky_head"):
        var damping: float = EffectManager.get_effect_value("sticky_head")
        linear_velocity.y *= damping  # e.g., 0.5 = 50% slower bounce
```

**Tests to pass:**
- effect_applied (behavior test)
- damping_value_correct (behavior test)
- velocity_dampened_on_player_collision (integration test)
- no_dampen_without_effect (integration test)
- no_dampen_on_non_player (integration test)

**Demo:** Ball bounces with reduced velocity when sticky_head is active

---

### Step 8: Orb Data Resources
**Files:**
- Create: `resources/orbs/burst_orb.tres`
- Create: `resources/orbs/vertical_line_orb.tres`
- Create: `resources/orbs/horizontal_line_orb.tres`
- Create: `resources/orbs/slow_fall_orb.tres`
- Create: `resources/orbs/sticky_head_orb.tres`
- Create: `resources/orbs/double_value_orb.tres`
- Create: `resources/orbs/combo_starter_orb.tres`
- Create: `resources/orbs/drifter_orb.tres`

**Note:** These are .tres resource files that reference OrbData and behavior resources.

**Tests to pass:** Existing orb loading tests should continue to work

**Demo:** All 8 orb types can be loaded as resources

---

### Step 9: Spawn System Integration
**Files:**
- Modify: `scripts/orb_spawner.gd` (or equivalent spawning system)

**Changes:** Add new orb types to spawn table with appropriate weights/rarity.

**Tests to pass:** Integration test that verifies each orb type can be spawned

**Demo:** All 8 orb types appear in-game during gameplay

---

### Step 10: Final Validation
**Command:** `./devscripts/test.sh`

**Success Criteria:**
- All unit tests pass
- All integration tests pass
- No regressions in existing tests
- Test script exits 0

**Manual Verification Steps:** (See Section 10 of design.md)

---

## Success Criteria Summary

| Step | Deliverable | Tests Pass | Demo Available |
|------|-------------|------------|----------------|
| 1 | Player group fix | test_player_in_group | Player identifiable |
| 2 | ScoreBehavior | test_score_behavior (4 tests) | Score with multipliers |
| 3 | TimedModifierBehavior | test_timed_modifier_behavior (3 tests) | Effects applied |
| 4 | ChainReactionBehavior | test_chain_reaction_behavior (4 tests) | Burst orb works |
| 5 | LineClearBehavior | test_line_clear_behavior (4 tests) | Line orbs work |
| 6 | MovementBehavior | test_movement_behavior (4 tests) | Drifter moves |
| 7 | StickyHeadBehavior + Ball | test_sticky_head_behavior (3 tests) + integration (3 tests) | Sticky bounce |
| 8 | Orb resources | Existing tests | 8 orb resources |
| 9 | Spawn integration | Integration tests | Orbs spawn in-game |
| 10 | Final validation | ./devscripts/test.sh exits 0 | All orbs playable |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Player group fix breaks existing code | Step 1 is isolated, easy to revert |
| Behavior tests need mock orb nodes | Use GUT's add_child/auto_free patterns |
| Chain reaction causes infinite loop | Skip source orb, check is_inside_tree() |
| Movement behavior affects collision | Use global_position, not position |
| Sticky head affects other collisions | Only apply on player collision check |

---

## Dependencies Between Steps

```
Step 1 (Player Group) ──────────────────────────────────┐
                                                         │
Step 2 (ScoreBehavior) ──────────────────────────────────┤
                                                         │
Step 3 (TimedModifierBehavior) ──────────────────────────┤
                                                         │
Step 4 (ChainReactionBehavior) ──────────────────────────┤
                                                         │
Step 5 (LineClearBehavior) ──────────────────────────────┤
                                                         │
Step 6 (MovementBehavior) ───────────────────────────────┤
                                                         │
Step 7 (StickyHead + Ball) ──────────────────────────────┤  ← Requires Step 1
                                                         │
Step 8 (Orb Resources) ──────────────────────────────────┤  ← Requires Steps 2-7
                                                         │
Step 9 (Spawn Integration) ──────────────────────────────┤  ← Requires Step 8
                                                         │
Step 10 (Final Validation) ──────────────────────────────┘  ← Requires all
```

---

## File Summary

### New Files (17 files)
```
scripts/data/behaviors/
├── score_behavior.gd
├── timed_modifier_behavior.gd
├── chain_reaction_behavior.gd
├── line_clear_behavior.gd
├── movement_behavior.gd
└── sticky_head_behavior.gd

tests/unit/
├── test_score_behavior.gd
├── test_timed_modifier_behavior.gd
├── test_chain_reaction_behavior.gd
├── test_line_clear_behavior.gd
├── test_movement_behavior.gd
├── test_sticky_head_behavior.gd
├── test_ball_sticky_head_integration.gd
└── test_player_in_group.gd

resources/orbs/
├── burst_orb.tres
├── vertical_line_orb.tres
├── horizontal_line_orb.tres
├── slow_fall_orb.tres
├── sticky_head_orb.tres
├── double_value_orb.tres
├── combo_starter_orb.tres
└── drifter_orb.tres
```

### Modified Files (2 files)
```
scripts/ball.gd              # Add sticky_head effect handling
scripts/physics_player.gd    # Add to "player" group
```
