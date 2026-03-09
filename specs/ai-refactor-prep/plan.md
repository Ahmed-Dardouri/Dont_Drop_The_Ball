# Implementation Plan: AI-Friendly Godot Game Refactor

## Test Strategy

### Unit Tests (Pure Logic - No Scene Instantiation)

Unit tests verify isolated component behavior using static functions and pure logic. Following the existing pattern in `test_ball_physics.gd` and `test_player_movement.gd`, we test physics math directly without RigidBody2D scene setup where possible.

| Test File | Test Cases | Coverage Target |
|-----------|------------|-----------------|
| `test_game_state.gd` | initial_state, pause_toggle, pause_signal, mode_change, mode_signal, reset | 100% GameState |
| `test_score_manager.gd` | initial_zero, add_increases, high_score_updates, reset_clears_current, signals_emit | 100% ScoreManager |
| `test_ball_physics.gd` | (update existing) clamp_max_speed, clamp_fall_speed, apply_air_friction, process_velocity, edge_cases | 100% BallPhysics |
| `test_player_physics.gd` | (update existing) can_coyote, has_buffered_jump, calculate_gravity, calculate_horizontal | 100% PlayerPhysics |
| `test_player_input_state.gd` | direction_left, direction_right, direction_release, jump_press, jump_held, reset | 100% PlayerInputState |
| `test_orb_definition.gd` | defaults, custom_values, required_fields | 100% OrbDefinition |
| `test_orb_registry.gd` | register, lookup, unknown_type, weighted_random_distribution, initialize | 100% OrbRegistry |

### Integration Tests (With Scene Components)

Integration tests verify components work together correctly with actual Godot nodes.

| Test File | Test Cases | Coverage Target |
|-----------|------------|-----------------|
| `test_orb_collection_integration.gd` | orb_collects_adds_score, paused_orb_skipped, ball_group_detected | Orb collection flow |
| `test_pause_integration.gd` | pause_freezes_game, pause_signal_propagates | Pause system |
| `test_game_loop.gd` | start_to_game_over, score_persists, high_score_saves | Full game loop |

### E2E Test Scenario (Manual Validation by Validator)

**Scenario:** Complete Game Session

**Steps:**
1. Launch game via `./devscripts/smoke_test.sh`
2. Verify main menu loads without errors
3. Start game (auto or button press based on current flow)
4. Move player left/right using keyboard (A/D or arrows)
5. Jump to bounce ball (Space or W)
6. Collect at least 3 orbs of different types
7. Verify score increases correctly
8. Pause game (Escape or P)
9. Verify game freezes
10. Resume game
11. Allow ball to hit ground
12. Verify game over state
13. Verify score displayed matches collected orbs

**Expected Outcome:** Game plays identically to pre-refactor behavior with all mechanics working.

---

## Implementation Steps (TDD Order)

### Phase 1: Core Infrastructure

#### Step 1: Add GameMode Enum

**Files:**
- `scripts/utils/enums.gd` (modify)

**Tests:** None needed (enum only)

**Implementation:**
```gdscript
# Append to scripts/utils/enums.gd
enum GameMode {
    MENU,       # Main menu, settings, tutorial
    PLAYING,    # Active gameplay
    PAUSED,     # Pause overlay active
    GAME_OVER   # Ball hit ground
}
```

**Success Criteria:**
- [ ] `Enums.GameMode.MENU` exists
- [ ] `./devscripts/test.sh` passes

**Demo:** Verify enum accessible via `Enums.GameMode.MENU`

---

#### Step 2: Create GameState Singleton

**Files:**
- `scripts/core/game_state.gd` (create)
- `project.godot` (add autoload)

**Tests:** `tests/unit/test_game_state.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_game_state.gd
extends GutTest

func test_initial_state() -> void:
    var gs := GameState
    assert_false(gs.is_paused, "Should start unpaused")
    assert_eq(gs.current_mode, Enums.GameMode.MENU, "Should start in MENU mode")

func test_pause_toggle() -> void:
    GameState.is_paused = false
    GameState.toggle_pause()
    assert_true(GameState.is_paused, "Toggle should pause")
    GameState.toggle_pause()
    assert_false(GameState.is_paused, "Toggle should unpause")

func test_pause_signal_emits() -> void:
    GameState.is_paused = false
    var signal_emitted := false
    GameState.pause_changed.connect(func(_v): signal_emitted = true)
    GameState.is_paused = true
    assert_true(signal_emitted, "Should emit pause_changed")

func test_mode_signal_emits() -> void:
    GameState.current_mode = Enums.GameMode.MENU
    var new_mode = null
    GameState.mode_changed.connect(func(v): new_mode = v)
    GameState.current_mode = Enums.GameMode.PLAYING
    assert_eq(new_mode, Enums.GameMode.PLAYING, "Should emit mode_changed")

func test_reset() -> void:
    GameState.is_paused = true
    GameState.current_mode = Enums.GameMode.GAME_OVER
    GameState.reset()
    assert_false(GameState.is_paused, "Reset should clear pause")
    assert_eq(GameState.current_mode, Enums.GameMode.MENU, "Reset should set MENU")
```

**Implementation:**
```gdscript
# scripts/core/game_state.gd
extends Node
class_name GameState

signal pause_changed(is_paused: bool)
signal mode_changed(new_mode: Enums.GameMode)

var is_paused: bool = false:
    set(value):
        if value != is_paused:
            is_paused = value
            pause_changed.emit(value)

var current_mode: Enums.GameMode = Enums.GameMode.MENU:
    set(value):
        if value != current_mode:
            current_mode = value
            mode_changed.emit(value)

func toggle_pause() -> void:
    is_paused = !is_paused

func reset() -> void:
    is_paused = false
    current_mode = Enums.GameMode.MENU
```

**project.godot addition:**
```
GameState="*res://scripts/core/game_state.gd"
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes
- [ ] `./devscripts/smoke_test.sh` passes

**Demo:** `GameState.is_paused = true` works without errors

---

#### Step 3: Create ScoreManager Singleton

**Files:**
- `scripts/core/score_manager.gd` (create)
- `project.godot` (add autoload)

**Tests:** `tests/unit/test_score_manager.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_score_manager.gd
extends GutTest

func before_each() -> void:
    ScoreManager.reset_score()

func test_initial_score_zero() -> void:
    assert_eq(ScoreManager.get_score(), 0, "Initial score should be 0")

func test_add_score_increases() -> void:
    var result := ScoreManager.add_score(10)
    assert_eq(ScoreManager.get_score(), 10, "Score should increase")
    assert_eq(result, 10, "add_score should return new score")

func test_add_score_accumulates() -> void:
    ScoreManager.add_score(5)
    ScoreManager.add_score(3)
    assert_eq(ScoreManager.get_score(), 8, "Score should accumulate")

func test_high_score_updates() -> void:
    ScoreManager.set_high_score(0)
    ScoreManager.add_score(100)
    assert_eq(ScoreManager.get_high_score(), 100, "High score should update")

func test_high_score_not_updated_when_lower() -> void:
    ScoreManager.set_high_score(200)
    ScoreManager.add_score(50)
    assert_eq(ScoreManager.get_high_score(), 200, "High score should remain")

func test_reset_clears_current() -> void:
    ScoreManager.add_score(100)
    ScoreManager.reset_score()
    assert_eq(ScoreManager.get_score(), 0, "Reset should clear current")
    assert_eq(ScoreManager.get_high_score(), 100, "Reset should NOT clear high score")

func test_score_signal_emits() -> void:
    var emitted_value := -1
    ScoreManager.score_changed.connect(func(v): emitted_value = v)
    ScoreManager.add_score(42)
    assert_eq(emitted_value, 42, "Should emit score_changed")
```

**Implementation:**
```gdscript
# scripts/core/score_manager.gd
extends Node
class_name ScoreManager

signal score_changed(new_score: int)
signal high_score_changed(new_high: int)

var _current_score: int = 0
var _high_score: int = 0

func get_score() -> int:
    return _current_score

func get_high_score() -> int:
    return _high_score

func add_score(amount: int) -> int:
    _current_score += amount
    score_changed.emit(_current_score)
    if _current_score > _high_score:
        _high_score = _current_score
        high_score_changed.emit(_high_score)
    return _current_score

func reset_score() -> void:
    _current_score = 0
    score_changed.emit(_current_score)

func set_high_score(value: int) -> void:
    _high_score = value
    high_score_changed.emit(_high_score)
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** `ScoreManager.add_score(10)` returns 10

---

#### Step 4: Create Physics Config Resources

**Files:**
- `scripts/data/ball_physics_config.gd` (create)
- `scripts/data/player_physics_config.gd` (create)

**Tests:** `tests/unit/test_physics_configs.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_physics_configs.gd
extends GutTest

func test_ball_physics_config_defaults() -> void:
    var config := BallPhysicsConfig.new()
    assert_eq(config.max_speed, 900.0, "Default max_speed")
    assert_eq(config.max_fall_speed, 500.0, "Default max_fall_speed")
    assert_eq(config.air_friction, 9.0, "Default air_friction")

func test_ball_physics_config_custom() -> void:
    var config := BallPhysicsConfig.new()
    config.max_speed = 1000.0
    config.max_fall_speed = 600.0
    config.air_friction = 5.0
    assert_eq(config.max_speed, 1000.0, "Custom max_speed")

func test_player_physics_config_defaults() -> void:
    var config := PlayerPhysicsConfig.new()
    assert_eq(config.jump_power, -700, "Default jump_power")
    assert_eq(config.move_speed, 120, "Default move_speed")
    assert_almost_eq(config.coyote_timeout, 150.0, 0.1, "Default coyote_timeout")
```

**Implementation:**
```gdscript
# scripts/data/ball_physics_config.gd
class_name BallPhysicsConfig extends Resource

@export var max_speed: float = 900.0
@export var max_fall_speed: float = 500.0
@export var air_friction: float = 9.0

# scripts/data/player_physics_config.gd
class_name PlayerPhysicsConfig extends Resource

@export var jump_power: int = -700
@export var move_speed: int = 120
@export var acceleration: float = 1500.0
@export var initial_acceleration: float = 2000.0
@export var deceleration: float = 10000.0
@export var coyote_timeout: float = 150.0
@export var jump_buffer_timeout: float = 150.0
@export var fall_acceleration: float = 1800.0
@export var max_fall_speed: float = 800.0
@export var grounding_force: float = 1.5
@export var early_jump_gravity_modifier: float = 3.0
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** Can create config instances with defaults

---

#### Step 5: Create BallPhysics Static Class

**Files:**
- `scripts/systems/physics/ball_physics.gd` (create)

**Tests:** Update `tests/unit/test_ball_physics.gd`

**Test Cases (add to existing):**
```gdscript
# Add to tests/unit/test_ball_physics.gd

func test_static_clamp_max_speed() -> void:
    var result := BallPhysics.clamp_max_speed(Vector2(1000, 0), 900.0)
    assert_almost_eq(result.x, 900.0, 0.1, "Static clamp_max_speed")

func test_static_process_velocity() -> void:
    var config := BallPhysicsConfig.new()
    var result := BallPhysics.process_velocity(Vector2(1000, 600), config)
    # Should clamp both speed (1000 -> 900) and fall (600 -> 500)
    assert_almost_eq(result.length(), 900.0, 1.0, "Process velocity should clamp")
```

**Implementation:**
```gdscript
# scripts/systems/physics/ball_physics.gd
class_name BallPhysics

static func clamp_max_speed(velocity: Vector2, max_speed: float) -> Vector2:
    if max_speed > 0.0:
        var speed := velocity.length()
        if speed > max_speed:
            return velocity.normalized() * max_speed
    return velocity

static func clamp_fall_speed(velocity: Vector2, max_fall_speed: float) -> Vector2:
    var result := velocity
    if max_fall_speed > 0.0 and result.y > max_fall_speed:
        result.y = max_fall_speed
    return result

static func apply_air_friction(velocity: Vector2, friction: float) -> Vector2:
    var result := velocity
    if friction > 0.0:
        result.x *= (1.0 - friction / 1000.0)
    return result

static func process_velocity(velocity: Vector2, config: BallPhysicsConfig) -> Vector2:
    if config == null:
        return velocity
    var result := clamp_max_speed(velocity, config.max_speed)
    result = clamp_fall_speed(result, config.max_fall_speed)
    result = apply_air_friction(result, config.air_friction)
    return result
```

**Success Criteria:**
- [ ] All BallPhysics tests pass
- [ ] `./devscripts/test.sh` passes

**Demo:** `BallPhysics.clamp_max_speed(Vector2(1000, 0), 900.0)` returns clamped vector

---

#### Step 6: Create PlayerPhysics Static Class

**Files:**
- `scripts/systems/physics/player_physics.gd` (create)

**Tests:** Update `tests/unit/test_player_movement.gd`

**Test Cases (add to existing):**
```gdscript
# Add to tests/unit/test_player_movement.gd

func test_static_can_coyote() -> void:
    assert_true(PlayerPhysics.can_coyote(1000, 1100, 150.0), "Within window")
    assert_false(PlayerPhysics.can_coyote(1000, 1200, 150.0), "Outside window")

func test_static_calculate_gravity_grounded() -> void:
    var config := PlayerPhysicsConfig.new()
    var result := PlayerPhysics.calculate_gravity(0.0, true, false, config, 0.016)
    assert_almost_eq(result, config.grounding_force, 0.1, "Grounded should apply grounding force")

func test_static_calculate_gravity_falling() -> void:
    var config := PlayerPhysicsConfig.new()
    var result := PlayerPhysics.calculate_gravity(100.0, false, false, config, 0.016)
    assert_gt(result, 100.0, "Falling should increase Y velocity")
```

**Implementation:**
```gdscript
# scripts/systems/physics/player_physics.gd
class_name PlayerPhysics

static func can_coyote(time_left_ground: int, current_time: int, timeout_ms: float) -> bool:
    return current_time < time_left_ground + int(timeout_ms)

static func has_buffered_jump(time_pressed: int, current_time: int, timeout_ms: float) -> bool:
    return current_time < time_pressed + int(timeout_ms)

static func calculate_gravity(
    current_velocity_y: float,
    is_grounded: bool,
    ended_jump_early: bool,
    config: PlayerPhysicsConfig,
    delta: float
) -> float:
    if config == null:
        return current_velocity_y

    if is_grounded and current_velocity_y >= 0:
        return config.grounding_force

    var gravity := config.fall_acceleration
    if ended_jump_early and current_velocity_y < 0:
        gravity *= config.early_jump_gravity_modifier

    return move_toward(current_velocity_y, config.max_fall_speed, gravity * delta)

static func calculate_horizontal_velocity(
    current: float,
    direction: float,
    target_speed: float,
    config: PlayerPhysicsConfig,
    delta: float
) -> float:
    if config == null:
        return current

    if direction != 0.0:
        if abs(current) < config.move_speed:
            return move_toward(current, direction * target_speed, config.initial_acceleration * delta)
        else:
            if sign(current * direction) == -1:
                return 0.0
            return move_toward(current, direction * target_speed, config.acceleration * delta)
    return move_toward(current, 0.0, config.deceleration * delta)
```

**Success Criteria:**
- [ ] All PlayerPhysics tests pass
- [ ] `./devscripts/test.sh` passes

**Demo:** `PlayerPhysics.can_coyote()` returns correct boolean

---

#### Step 7: Create PlayerInputState Class

**Files:**
- `scripts/systems/input/player_input_state.gd` (create)

**Tests:** `tests/unit/test_player_input_state.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_player_input_state.gd
extends GutTest

var _input_state: PlayerInputState

func before_each() -> void:
    _input_state = PlayerInputState.new()

func test_initial_state() -> void:
    assert_eq(_input_state.move_direction, 0.0, "Initial direction 0")
    assert_false(_input_state.jump_held, "Initial jump_held false")
    assert_false(_input_state.jump_just_pressed, "Initial jump_just_pressed false")

func test_reset() -> void:
    _input_state.move_direction = 1.0
    _input_state.jump_held = true
    _input_state.reset()
    assert_eq(_input_state.move_direction, 0.0, "Reset clears direction")
    assert_false(_input_state.jump_held, "Reset clears jump_held")
```

**Implementation:**
```gdscript
# scripts/systems/input/player_input_state.gd
class_name PlayerInputState

var move_direction: float = 0.0
var jump_held: bool = false
var jump_just_pressed: bool = false
var last_jump_time: int = 0

func process_input(event: InputEvent) -> void:
    jump_just_pressed = false

    if event.is_action_pressed("Left"):
        move_direction = -1.0
    elif event.is_action_released("Left"):
        if move_direction < 0:
            move_direction = 0.0

    if event.is_action_pressed("Right"):
        move_direction = 1.0
    elif event.is_action_released("Right"):
        if move_direction > 0:
            move_direction = 0.0

    if event.is_action_pressed("Jump"):
        jump_held = true
        jump_just_pressed = true
        last_jump_time = Time.get_ticks_msec()
    elif event.is_action_released("Jump"):
        jump_held = false

func reset() -> void:
    move_direction = 0.0
    jump_held = false
    jump_just_pressed = false
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** InputState tracks direction changes

---

#### Step 8: Create OrbDefinition Resource

**Files:**
- `scripts/entities/orb/orb_definition.gd` (create)

**Tests:** `tests/unit/test_orb_definition.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_orb_definition.gd
extends GutTest

func test_defaults() -> void:
    var def := OrbDefinition.new()
    assert_eq(def.score_value, 1, "Default score")
    assert_almost_eq(def.lifespan_seconds, 30.0, 0.1, "Default lifespan")
    assert_almost_eq(def.spawn_weight, 1.0, 0.1, "Default weight")

func test_custom_values() -> void:
    var def := OrbDefinition.new()
    def.type_name = &"test"
    def.display_name = "Test Orb"
    def.score_value = 10
    def.lifespan_seconds = 15.0
    def.spawn_weight = 0.5

    assert_eq(def.type_name, &"test", "Custom type_name")
    assert_eq(def.score_value, 10, "Custom score")
```

**Implementation:**
```gdscript
# scripts/entities/orb/orb_definition.gd
class_name OrbDefinition extends Resource

@export var type_name: StringName
@export var display_name: String
@export var score_value: int = 1
@export var lifespan_seconds: float = 30.0
@export var scene: PackedScene
@export var sprite_texture: Texture2D
@export var has_physics_body: bool = false
@export_category("Spawn Settings")
@export var spawn_weight: float = 1.0
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** Can create OrbDefinition with custom values

---

#### Step 9: Create OrbRegistry

**Files:**
- `scripts/entities/orb/orb_registry.gd` (create)

**Tests:** `tests/unit/test_orb_registry.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_orb_registry.gd
extends GutTest

func before_each() -> void:
    OrbRegistry.reset()

func test_initialize_registers_defaults() -> void:
    OrbRegistry.initialize()
    assert_ne(OrbRegistry.get_definition(&"blue"), null, "Blue orb registered")
    assert_ne(OrbRegistry.get_definition(&"red"), null, "Red orb registered")
    assert_ne(OrbRegistry.get_definition(&"half_solid"), null, "Half solid registered")

func test_unknown_type_returns_null() -> void:
    OrbRegistry.initialize()
    var def := OrbRegistry.get_definition(&"unknown")
    assert_null(def, "Unknown type should return null")

func test_register_custom() -> void:
    var def := OrbDefinition.new()
    def.type_name = &"custom"
    def.score_value = 99
    OrbRegistry.register(def)
    var retrieved := OrbRegistry.get_definition(&"custom")
    assert_eq(retrieved.score_value, 99, "Custom orb registered")

func test_get_all_definitions() -> void:
    OrbRegistry.initialize()
    var all := OrbRegistry.get_all_definitions()
    assert_gt(all.size(), 0, "Should have definitions")
```

**Implementation:**
```gdscript
# scripts/entities/orb/orb_registry.gd
class_name OrbRegistry

static var _definitions: Dictionary = {}
static var _initialized: bool = false

static func reset() -> void:
    _definitions.clear()
    _initialized = false

static func initialize() -> void:
    if _initialized:
        return
    _register_defaults()
    _initialized = true

static func _register_defaults() -> void:
    var blue := OrbDefinition.new()
    blue.type_name = &"blue"
    blue.display_name = "Blue Orb"
    blue.score_value = 2
    blue.lifespan_seconds = 30.0
    blue.spawn_weight = 1.0
    blue.has_physics_body = false
    register(blue)

    var red := OrbDefinition.new()
    red.type_name = &"red"
    red.display_name = "Red Orb"
    red.score_value = 3
    red.lifespan_seconds = 30.0
    red.spawn_weight = 1.0
    red.has_physics_body = false
    register(red)

    var half := OrbDefinition.new()
    half.type_name = &"half_solid"
    half.display_name = "Half Solid Orb"
    half.score_value = 8
    half.lifespan_seconds = 18.0
    half.spawn_weight = 0.5
    half.has_physics_body = true
    register(half)

static func register(def: OrbDefinition) -> void:
    if def == null or def.type_name == null:
        push_error("OrbRegistry: Cannot register null or typeless definition")
        return
    _definitions[def.type_name] = def

static func get_definition(type_name: StringName) -> OrbDefinition:
    if not _definitions.has(type_name):
        push_warning("Unknown orb type: " + str(type_name))
        return null
    return _definitions[type_name]

static func get_all_definitions() -> Array:
    return _definitions.values()

static func get_weighted_random() -> OrbDefinition:
    if _definitions.is_empty():
        initialize()

    var total_weight := 0.0
    for def in _definitions.values():
        total_weight += def.spawn_weight

    if total_weight <= 0.0:
        return null

    var roll := randf() * total_weight
    var accumulated := 0.0

    for def in _definitions.values():
        accumulated += def.spawn_weight
        if roll <= accumulated:
            return def

    return _definitions.values()[0] if _definitions.size() > 0 else null
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** `OrbRegistry.get_weighted_random()` returns valid definition

---

#### Step 10: Migrate PauseEvent to GameState

**Files:**
- `scripts/events/pause_event.gd` (modify)

**Tests:** Update `tests/unit/test_pause_state.gd`

**Test Cases (update existing):**
```gdscript
# Update tests/unit/test_pause_state.gd
extends GutTest

func test_pause_event_delegates_to_game_state() -> void:
    GameState.is_paused = false
    PauseEvent.invoke(true)
    assert_true(GameState.is_paused, "PauseEvent should update GameState")

func test_backward_compat_state_getter() -> void:
    GameState.is_paused = true
    assert_true(PauseEvent.state, "PauseEvent.state should reflect GameState")
```

**Implementation:**
```gdscript
# scripts/events/pause_event.gd (modify)
class_name PauseEvent extends Event

var _pause: bool = true

func _init(pause: bool) -> void:
    _pause = pause

static func invoke(pause: bool) -> void:
    GameState.is_paused = pause
    Events.invoke(PauseEvent.new(pause))

# Backward compatibility
static var state: bool:
    get: return GameState.is_paused
    set(value): GameState.is_paused = value
```

**Success Criteria:**
- [ ] All tests pass
- [ ] Existing pause functionality preserved
- [ ] `./devscripts/test.sh` passes
- [ ] `./devscripts/smoke_test.sh` passes

**Demo:** Pause/resume works identically to before

---

#### Step 11: Add Groups to Entities

**Files:**
- `scripts/ball.gd` (modify - add to "ball" group in _ready)
- `scenes/ground.tscn` (modify - add "ground" group)

**Tests:** None needed (group membership is runtime)

**Implementation:**
```gdscript
# In scripts/ball.gd _ready():
func _ready() -> void:
    add_to_group("ball")
    # ... existing code
```

```
# In scenes/ground.tscn [node] line:
[node name="ground_static" type="StaticBody2D" groups=["ground"]]
```

**Success Criteria:**
- [ ] Ball is in "ball" group
- [ ] Ground is in "ground" group
- [ ] `./devscripts/test.sh` passes
- [ ] `./devscripts/smoke_test.sh` passes

**Demo:** `ball.is_in_group("ball")` returns true

---

#### Step 12: Update Ball Collision to Use Groups

**Files:**
- `scripts/ball.gd` (modify collision handler)

**Tests:** Update `tests/unit/test_ball_physics.gd` if needed

**Implementation:**
```gdscript
# In scripts/ball.gd _on_body_entered:
func _on_body_entered(body: Node) -> void:
    if game_over:
        return

    if body.is_in_group("ground"):
        game_over = true
        hit_ground.emit()
        Events.game_over.emit(ScoreManager.get_score())
        GameState.is_paused = true
        SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)
    elif body is HalfSolidOrb or body.is_in_group("half_solid"):
        linear_velocity = linear_velocity / 3
```

**Success Criteria:**
- [ ] Ball detects ground via group
- [ ] Game over triggers correctly
- [ ] `./devscripts/test.sh` passes
- [ ] `./devscripts/smoke_test.sh` passes

**Demo:** Ball hitting ground triggers game over

---

#### Step 13: Create Unified Orb Class

**Files:**
- `scripts/entities/orb/orb.gd` (create)

**Tests:** `tests/unit/test_orb.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_orb.gd
extends GutTest

func test_orb_requires_definition() -> void:
    var orb := Orb.new()
    # Without definition, orb should handle gracefully
    add_child_autofree(orb)
    await get_tree().process_frame
    assert_true(orb.is_inside_tree(), "Orb should handle missing definition")

func test_collect_adds_score() -> void:
    ScoreManager.reset_score()
    var def := OrbDefinition.new()
    def.type_name = &"test"
    def.score_value = 10

    var orb := Orb.new()
    orb.definition = def
    orb._is_active = true  # Bypass spawn animation
    add_child_autofree(orb)

    orb.collect()
    assert_eq(ScoreManager.get_score(), 10, "Collect should add score")

func test_collect_blocked_when_paused() -> void:
    ScoreManager.reset_score()
    GameState.is_paused = true

    var def := OrbDefinition.new()
    def.type_name = &"test"
    def.score_value = 10

    var orb := Orb.new()
    orb.definition = def
    orb._is_active = true
    add_child_autofree(orb)

    orb.collect()
    assert_eq(ScoreManager.get_score(), 0, "Paused orb should not collect")

    GameState.is_paused = false
```

**Implementation:**
```gdscript
# scripts/entities/orb/orb.gd
class_name Orb extends Node2D

signal collected

@export var definition: OrbDefinition

var _lifetime_timer: Timer
var _spawn_timer: Timer
var _is_active: bool = false
var _spawn_duration: float = 1.5

func _ready() -> void:
    add_to_group("orbs")

    if definition == null:
        push_error("Orb requires a definition")
        return

    _setup_spawn_animation()
    _setup_lifetime()

func _setup_spawn_animation() -> void:
    _spawn_timer = Timer.new()
    _spawn_timer.one_shot = true
    _spawn_timer.wait_time = _spawn_duration
    _spawn_timer.timeout.connect(_on_spawn_complete)
    add_child(_spawn_timer)
    _spawn_timer.start()

    modulate.a = 0.0

func _process(_delta: float) -> void:
    if not _is_active and _spawn_timer:
        var progress := 1.0 - (_spawn_timer.time_left / _spawn_duration)
        modulate.a = progress * 0.75

func _on_spawn_complete() -> void:
    _is_active = true
    modulate.a = 1.0

func _setup_lifetime() -> void:
    _lifetime_timer = Timer.new()
    _lifetime_timer.one_shot = true
    _lifetime_timer.wait_time = definition.lifespan_seconds
    _lifetime_timer.timeout.connect(queue_free)
    add_child(_lifetime_timer)
    _lifetime_timer.start()

func collect() -> void:
    if not _is_active or GameState.is_paused:
        return

    collected.emit()
    ScoreManager.add_score(definition.score_value)
    queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("ball"):
        collect()
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** Orb spawn animation and collection work

---

#### Step 14: Create HalfSolidOrb Subclass

**Files:**
- `scripts/entities/orb/half_solid_orb.gd` (create)

**Tests:** `tests/unit/test_half_solid_orb.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_half_solid_orb.gd
extends GutTest

func test_first_hit_bounces() -> void:
    var orb := HalfSolidOrb.new()
    var def := OrbDefinition.new()
    def.type_name = &"half_solid"
    orb.definition = def
    orb._is_active = true
    add_child_autofree(orb)

    assert_false(orb._was_hit, "Should start not hit")

    # Simulate ball collision
    var ball := RigidBody2D.new()
    ball.linear_velocity = Vector2(300, 600)
    add_child_autofree(ball)

    orb._on_body_entered(ball)

    assert_true(orb._was_hit, "Should be hit after first collision")
    assert_almost_eq(ball.linear_velocity.x, 100.0, 1.0, "Ball should bounce")

func test_second_hit_collects() -> void:
    ScoreManager.reset_score()
    var orb := HalfSolidOrb.new()
    var def := OrbDefinition.new()
    def.type_name = &"half_solid"
    def.score_value = 8
    orb.definition = def
    orb._is_active = true
    orb._was_hit = true  # Already hit once
    add_child_autofree(orb)

    var ball := RigidBody2D.new()
    ball.add_to_group("ball")
    add_child_autofree(ball)

    orb._on_body_entered(ball)

    assert_eq(ScoreManager.get_score(), 8, "Second hit should collect")
```

**Implementation:**
```gdscript
# scripts/entities/orb/half_solid_orb.gd
class_name HalfSolidOrb extends Orb

var _was_hit: bool = false

func _ready() -> void:
    super._ready()
    add_to_group("half_solid")

func _on_body_entered(body: Node2D) -> void:
    if not body.is_in_group("ball"):
        return

    if not _was_hit:
        _was_hit = true
        _on_ball_collision(body)
    else:
        collect()

func _on_ball_collision(ball: Node2D) -> void:
    if "linear_velocity" in ball:
        ball.linear_velocity /= 3
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes

**Demo:** Ball bounces off half-solid orb, then collects on second hit

---

#### Step 15: Update OrbSpawner to Use Registry

**Files:**
- `scripts/orb_spawner.gd` (modify)

**Tests:** `tests/unit/test_orb_spawner.gd`

**Test Cases (write first):**
```gdscript
# tests/unit/test_orb_spawner.gd
extends GutTest

func test_spawner_initializes_registry() -> void:
    var spawner := OrbSpawner.new()
    add_child_autofree(spawner)
    await get_tree().process_frame

    assert_true(OrbRegistry._initialized, "Spawner should initialize registry")

func test_spawn_uses_registry() -> void:
    OrbRegistry.initialize()
    var spawner := OrbSpawner.new()
    add_child_autofree(spawner)

    # Verify orbs are spawned from registry definitions
    var def := OrbRegistry.get_weighted_random()
    assert_ne(def, null, "Registry should return definition")
```

**Implementation:**
```gdscript
# In scripts/orb_spawner.gd, update spawning logic:
func _ready() -> void:
    OrbRegistry.initialize()
    # ... existing timer setup

func _on_timeout() -> void:
    if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
        return

    var def := OrbRegistry.get_weighted_random()
    if def == null:
        return

    var orb: Orb
    if def.has_physics_body:
        orb = HalfSolidOrb.new()
    else:
        # For now, keep using existing GenericOrb pattern
        # This will be updated in Phase 4 when we remove old orb scripts
        orb = generic_orb_scene.instantiate()
        orb.set_meta("orb_type", def.type_name)

    if orb:
        orb.definition = def
        orb.global_position = _get_random_position()
        add_child(orb)
```

**Success Criteria:**
- [ ] All test cases pass
- [ ] `./devscripts/test.sh` passes
- [ ] `./devscripts/smoke_test.sh` passes

**Demo:** Orbs spawn correctly with registry definitions

---

### Phase 2: Integration Tests

#### Step 16: Create Orb Collection Integration Test

**Files:**
- `tests/integration/test_orb_collection_integration.gd` (create)

**Test Cases:**
```gdscript
# tests/integration/test_orb_collection_integration.gd
extends GutTest

func test_orb_collects_and_adds_score() -> void:
    OrbRegistry.initialize()
    ScoreManager.reset_score()
    GameState.is_paused = false

    var def := OrbRegistry.get_definition(&"blue")
    var orb := Orb.new()
    orb.definition = def
    orb._is_active = true  # Bypass spawn animation
    add_child_autofree(orb)

    var initial_score := ScoreManager.get_score()
    orb.collect()
    await get_tree().process_frame

    assert_eq(ScoreManager.get_score(), initial_score + def.score_value)

func test_paused_orb_not_collected() -> void:
    OrbRegistry.initialize()
    ScoreManager.reset_score()
    GameState.is_paused = true

    var def := OrbRegistry.get_definition(&"blue")
    var orb := Orb.new()
    orb.definition = def
    orb._is_active = true
    add_child_autofree(orb)

    var initial_score := ScoreManager.get_score()
    orb.collect()

    assert_eq(ScoreManager.get_score(), initial_score)

    GameState.is_paused = false
```

**Success Criteria:**
- [ ] Integration test passes
- [ ] `./devscripts/test.sh` passes

---

#### Step 17: Final Validation

**Files:** None (validation only)

**Validation Commands:**
```bash
./devscripts/import.sh
./devscripts/smoke_test.sh
./devscripts/test.sh
```

**Manual Checklist:**
- [ ] Game launches without errors
- [ ] Player movement works (left/right/jump)
- [ ] Ball bounces correctly
- [ ] All orb types spawn
- [ ] Blue orbs collect and add 2 points
- [ ] Red orbs collect and add 3 points
- [ ] Half-solid orbs bounce ball first, collect second (8 points)
- [ ] Pause/resume works
- [ ] Game over triggers when ball hits ground
- [ ] Score persists correctly
- [ ] No console errors or warnings

**Success Criteria:**
- [ ] All automated tests pass
- [ ] Manual E2E scenario complete
- [ ] `./devscripts/test.sh` exits 0

---

## Summary

### Test Coverage Goals

| Component | Unit Tests | Integration Tests |
|-----------|------------|-------------------|
| GameState | 5 tests | Via pause test |
| ScoreManager | 7 tests | Via orb collection |
| BallPhysics | 15 tests | Via game loop |
| PlayerPhysics | 10 tests | Via game loop |
| PlayerInputState | 5 tests | - |
| OrbDefinition | 2 tests | - |
| OrbRegistry | 4 tests | Via orb spawning |
| Orb | 3 tests | 2 integration tests |
| HalfSolidOrb | 2 tests | Via game loop |

### Implementation Order Summary

1. **Phase 1a (Foundation):** GameMode enum → GameState → ScoreManager
2. **Phase 1b (Config):** Physics configs → BallPhysics → PlayerPhysics → PlayerInputState
3. **Phase 1c (Orb System):** OrbDefinition → OrbRegistry → Orb → HalfSolidOrb
4. **Phase 1d (Migration):** PauseEvent → Groups → Ball collision
5. **Phase 2 (Validation):** Integration tests → Final validation

Each step follows TDD: write tests first, implement, verify tests pass.
