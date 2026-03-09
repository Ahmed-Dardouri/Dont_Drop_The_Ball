# Implementation Plan: AI-Friendly Godot Game Refactor

## Implementation Checklist

Track progress by checking off completed steps:

- [ ] **Phase 1: Core Infrastructure**
  - [ ] Step 1: Create GameState singleton
  - [ ] Step 2: Create ScoreManager singleton
  - [ ] Step 3: Refactor Events to use signals
  - [ ] Step 4: Update pause system to use GameState

- [ ] **Phase 2: Physics Extraction**
  - [ ] Step 5: Create BallPhysics static class
  - [ ] Step 6: Create PlayerPhysics static class
  - [ ] Step 7: Create PlayerInputState class
  - [ ] Step 8: Create physics config resources

- [ ] **Phase 3: Orb System Redesign**
  - [ ] Step 9: Create OrbDefinition resource
  - [ ] Step 10: Create OrbRegistry
  - [ ] Step 11: Create unified Orb base class
  - [ ] Step 12: Create HalfSolidOrb subclass
  - [ ] Step 13: Update OrbSpawner to use registry

- [ ] **Phase 4: Entity Refactoring**
  - [ ] Step 14: Refactor Ball to use BallPhysics
  - [ ] Step 15: Refactor Player to use PlayerPhysics
  - [ ] Step 16: Remove old orb scripts
  - [ ] Step 17: Update collision detection to use groups

- [ ] **Phase 5: Test Expansion**
  - [ ] Step 18: Add comprehensive unit tests
  - [ ] Step 19: Add integration tests
  - [ ] Step 20: Final validation and cleanup

---

## Phase 1: Core Infrastructure

### Step 1: Create GameState Singleton

**Objective**: Replace `PauseEvent.state` static variable with a proper singleton that manages game state with signals.

**Implementation**:
1. Create `scripts/core/game_state.gd` as a new autoload
2. Add `is_paused` property with signal emission
3. Add `current_mode` property for game mode tracking
4. Add `reset()` function for state cleanup
5. Register in `project.godot` as autoload

**Code Structure**:
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

**Test Requirements**:
- Create `tests/unit/test_game_state.gd`
- Test: initial state is correct
- Test: `is_paused` setter emits signal
- Test: `toggle_pause()` works
- Test: `reset()` clears state

**Integration**: Will be used by PauseEvent migration in Step 4

**Demo**: Run game, verify no errors, existing pause functionality still works

---

### Step 2: Create ScoreManager Singleton

**Objective**: Extract score logic from `score_mngr.gd` scene into a pure singleton.

**Implementation**:
1. Create `scripts/core/score_manager.gd` as new autoload
2. Move score tracking logic from `score_mngr.gd`
3. Add signals for score changes
4. Keep `score_mngr.gd` as UI adapter (listens to ScoreManager)
5. Register in `project.godot`

**Code Structure**:
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

**Test Requirements**:
- Create `tests/unit/test_score_manager.gd`
- Test: initial score is 0
- Test: `add_score()` increases score
- Test: high score updates when exceeded
- Test: signals emit correctly
- Test: `reset_score()` works

**Integration**: Update `score_mngr.gd` to listen to ScoreManager signals instead of AddScoreEvent

**Demo**: Play game, collect orbs, verify score updates correctly

---

### Step 3: Refactor Events to Use Signals

**Objective**: Simplify event system to use Godot signals instead of custom dispatching.

**Implementation**:
1. Refactor `addons/dynamic_event_manager/src/Events.gd` to use signals
2. Keep existing event classes as data containers but remove dispatch logic
3. Add typed signals for key events
4. Maintain backward compatibility during transition

**Code Structure**:
```gdscript
# addons/dynamic_event_manager/src/Events.gd
extends Node

# Keep existing dispatch for backward compatibility
var events := {}

# New signal-based events
signal game_over(final_score: int)
signal score_added(amount: int)
signal orb_collected(orb_type: StringName)
signal pause_changed(is_paused: bool)

# Existing methods for compatibility
func add_listener(event_class: GDScript, method: Callable) -> void:
    if !events.has(event_class):
        events[event_class] = []
    events[event_class].push_front(method)

func remove_listener(event_class: GDScript, method: Callable) -> void:
    if events.has(event_class) and events[event_class].has(method):
        events[event_class].erase(method)

func invoke(event: Event) -> void:
    var event_class = event.get_script()
    if events.has(event_class):
        var listeners = events[event_class]
        for i in range(listeners.size() - 1, -1, -1):
            await listeners[i].call(event)
```

**Test Requirements**:
- Update `tests/unit/test_events.gd` to test new signals
- Test: signals can be connected and emitted
- Test: existing listener pattern still works

**Integration**: New code uses signals, existing code continues using listener pattern

**Demo**: All existing tests pass, game runs normally

---

### Step 4: Update Pause System to Use GameState

**Objective**: Migrate all pause checking from `PauseEvent.state` to `GameState.is_paused`.

**Implementation**:
1. Update `PauseEvent` to delegate to `GameState`
2. Update all event `invoke()` methods to check `GameState.is_paused`
3. Update `main.gd` pause handler to use `GameState`
4. Add backward compatibility layer

**Code Changes**:
```gdscript
# scripts/events/pause_event.gd
class_name PauseEvent extends Event

var _pause: bool = true

func _init(pause: bool) -> void:
    _pause = pause

static func invoke(pause: bool):
    GameState.is_paused = pause  # Use GameState instead of static var
    Events.invoke(PauseEvent.new(pause))

# For backward compatibility during transition
static var state: bool:
    get: return GameState.is_paused
    set(value): GameState.is_paused = value
```

**Test Requirements**:
- Update `tests/unit/test_pause_state.gd` to use GameState
- Test: GameState.is_paused controls pause correctly
- Test: PauseEvent.state backward compatibility works
- Update integration tests

**Integration**: All systems now check `GameState.is_paused` instead of `PauseEvent.state`

**Demo**: Pause/resume works, score doesn't accumulate when paused

---

## Phase 2: Physics Extraction

### Step 5: Create BallPhysics Static Class

**Objective**: Extract ball physics calculations into a pure, testable static class.

**Implementation**:
1. Create `scripts/systems/physics/ball_physics.gd`
2. Move `clamp_max_speed`, `clamp_fall_speed`, `apply_air_friction` as static functions
3. Create `BallPhysicsConfig` resource for configuration

**Code Structure**:
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
    var result := clamp_max_speed(velocity, config.max_speed)
    result = clamp_fall_speed(result, config.max_fall_speed)
    result = apply_air_friction(result, config.air_friction)
    return result
```

**Test Requirements**:
- Update `tests/unit/test_ball_physics.gd` to test BallPhysics class directly
- Test: all clamp functions work correctly
- Test: `process_velocity` combines all effects
- Test: edge cases (zero values, negative values)

**Integration**: Will be used by Ball entity in Phase 4

**Demo**: Tests pass, logic verified independently of scene

---

### Step 6: Create PlayerPhysics Static Class

**Objective**: Extract player physics calculations into pure static functions.

**Implementation**:
1. Create `scripts/systems/physics/player_physics.gd`
2. Extract coyote time, buffered jump, gravity calculations
3. Create `PlayerPhysicsConfig` resource

**Code Structure**:
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
    if direction != 0.0:
        if abs(current) < config.move_speed:
            return move_toward(current, direction * target_speed, config.initial_acceleration * delta)
        else:
            if sign(current * direction) == -1:
                return 0.0
            return move_toward(current, direction * target_speed, config.acceleration * delta)
    return move_toward(current, 0.0, config.deceleration * delta)
```

**Test Requirements**:
- Update `tests/unit/test_player_movement.gd` to use PlayerPhysics
- Test: coyote time logic
- Test: buffered jump logic
- Test: gravity calculations
- Test: horizontal movement

**Integration**: Will be used by Player entity in Phase 4

**Demo**: Tests pass, physics verified independently

---

### Step 7: Create PlayerInputState Class

**Objective**: Extract input state tracking into a dedicated class.

**Implementation**:
1. Create `scripts/systems/input/player_input_state.gd`
2. Track move direction, jump state, etc.
3. Process input events and update state

**Code Structure**:
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

**Test Requirements**:
- Create `tests/unit/test_player_input_state.gd`
- Test: direction updates on input
- Test: jump state tracking
- Test: `jump_just_pressed` clears after read

**Integration**: Will be used by Player entity

**Demo**: Input state tracked correctly, can be tested without scene

---

### Step 8: Create Physics Config Resources

**Objective**: Create resource files for physics configuration.

**Implementation**:
1. Create `scripts/data/ball_physics_config.gd`
2. Create `scripts/data/player_physics_config.gd`
3. Create default resource files in `resources/`

**Code Structure**:
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

**Test Requirements**:
- Create `tests/unit/test_physics_configs.gd`
- Test: configs have valid default values
- Test: configs can be modified

**Integration**: Used by Ball and Player entities

**Demo**: Configs load correctly, can be modified in editor

---

## Phase 3: Orb System Redesign

### Step 9: Create OrbDefinition Resource

**Objective**: Create data-driven orb definition resource.

**Implementation**:
1. Create `scripts/entities/orb/orb_definition.gd`
2. Define all orb properties as exports
3. Create default definitions for existing orb types

**Code Structure**:
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

**Test Requirements**:
- Create `tests/unit/test_orb_definition.gd`
- Test: default values
- Test: can create definitions for each type
- Test: spawn weight affects selection

**Integration**: Used by OrbRegistry

**Demo**: Can create new orb definitions in editor

---

### Step 10: Create OrbRegistry

**Objective**: Centralized registry for orb types with weighted random selection.

**Implementation**:
1. Create `scripts/entities/orb/orb_registry.gd`
2. Implement registration and lookup
3. Implement weighted random selection
4. Initialize with default orb types

**Code Structure**:
```gdscript
# scripts/entities/orb/orb_registry.gd
class_name OrbRegistry

static var _definitions: Dictionary = {}
static var _initialized: bool = false

static func initialize() -> void:
    if _initialized:
        return
    _register_defaults()
    _initialized = true

static func _register_defaults() -> void:
    # Blue orb
    var blue := OrbDefinition.new()
    blue.type_name = &"blue"
    blue.display_name = "Blue Orb"
    blue.score_value = 2
    blue.lifespan_seconds = 30.0
    blue.spawn_weight = 1.0
    blue.has_physics_body = false
    register(blue)

    # Red orb
    var red := OrbDefinition.new()
    red.type_name = &"red"
    red.display_name = "Red Orb"
    red.score_value = 3
    red.lifespan_seconds = 30.0
    red.spawn_weight = 1.0
    red.has_physics_body = false
    register(red)

    # Half solid orb
    var half := OrbDefinition.new()
    half.type_name = &"half_solid"
    half.display_name = "Half Solid Orb"
    half.score_value = 8
    half.lifespan_seconds = 18.0
    half.spawn_weight = 0.5
    half.has_physics_body = true
    register(half)

static func register(def: OrbDefinition) -> void:
    _definitions[def.type_name] = def

static func get_definition(type_name: StringName) -> OrbDefinition:
    if not _definitions.has(type_name):
        push_warning("Unknown orb type: " + str(type_name))
        return null
    return _definitions[type_name]

static func get_all_definitions() -> Array:
    return _definitions.values()

static func get_weighted_random() -> OrbDefinition:
    var total_weight := 0.0
    for def in _definitions.values():
        total_weight += def.spawn_weight

    var roll := randf() * total_weight
    var accumulated := 0.0

    for def in _definitions.values():
        accumulated += def.spawn_weight
        if roll <= accumulated:
            return def

    return _definitions.values()[0]
```

**Test Requirements**:
- Create `tests/unit/test_orb_registry.gd`
- Test: registration works
- Test: lookup returns correct definition
- Test: weighted random distributes correctly

**Integration**: Called by OrbSpawner

**Demo**: Registry initialized, can select random orbs

---

### Step 11: Create Unified Orb Base Class

**Objective**: Create single Orb base class that replaces BlueOrb, RedOrb scripts.

**Implementation**:
1. Create `scripts/entities/orb/orb.gd`
2. Handle common orb behavior (lifetime, collection, spawn animation)
3. Use OrbDefinition for configuration
4. Create new `scenes/orb.tscn` scene

**Code Structure**:
```gdscript
# scripts/entities/orb/orb.gd
class_name Orb extends Node2D

signal collected

@export var definition: OrbDefinition

var _lifetime_timer: Timer
var _spawn_timer: Timer
var _visual: Node2D
var _collision: Area2D
var _is_active: bool = false
var _spawn_duration: float = 1.5

func _ready() -> void:
    if definition == null:
        push_error("Orb requires a definition")
        return

    _setup_components()
    _setup_spawn_animation()
    _setup_lifetime()

func _setup_components() -> void:
    # Set up visual and collision based on definition
    pass

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
    _enable_collision(true)

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
    Events.orb_collected.emit(definition.type_name)
    queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("ball"):
        collect()

func _enable_collision(enabled: bool) -> void:
    if _collision:
        _collision.monitoring = enabled
        _collision.monitorable = enabled
```

**Test Requirements**:
- Create `tests/unit/test_orb.gd`
- Test: orb initializes with definition
- Test: spawn animation progresses
- Test: collect adds score
- Test: collect blocked when paused

**Integration**: Will replace BlueOrb, RedOrb in scenes

**Demo**: Spawn orb, verify spawn animation and collection

---

### Step 12: Create HalfSolidOrb Subclass

**Objective**: Create HalfSolidOrb that extends Orb with physics body behavior.

**Implementation**:
1. Create `scripts/entities/orb/half_solid_orb.gd` extending Orb
2. Add physics body component
3. Handle ball collision differently (bounce + collect)
4. Create `scenes/half_solid_orb.tscn`

**Code Structure**:
```gdscript
# scripts/entities/orb/half_solid_orb.gd
class_name HalfSolidOrb extends Orb

var _physics_body: StaticBody2D
var _was_hit: bool = false

func _ready() -> void:
    super._ready()
    _setup_physics_body()

func _setup_physics_body() -> void:
    # Physics body created in scene or dynamically
    _physics_body = get_node_or_null("physics_body")

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("ball"):
        if not _was_hit:
            # First hit: bounce the ball
            _was_hit = true
            _on_ball_collision(body)
        else:
            # Second hit: collect
            collect()

func _on_ball_collision(ball: Node2D) -> void:
    if ball.has_method("apply_bounce"):
        ball.apply_bounce(0.33)  # Reduce velocity to 1/3
    elif "linear_velocity" in ball:
        ball.linear_velocity /= 3
```

**Test Requirements**:
- Create `tests/unit/test_half_solid_orb.gd`
- Test: first collision bounces ball
- Test: second collision collects orb
- Test: physics body present

**Integration**: Used in scenes for half-solid orb type

**Demo**: Ball bounces off half-solid orb, then can collect

---

### Step 13: Update OrbSpawner to Use Registry

**Objective**: Refactor OrbSpawner to use OrbRegistry instead of direct scene references.

**Implementation**:
1. Update `scripts/orb_spawner.gd` to use `OrbRegistry.get_weighted_random()`
2. Remove dependency on specific orb scenes
3. Simplify spawning logic

**Code Structure**:
```gdscript
# scripts/orb_spawner.gd (refactored)
extends Node2D
class_name OrbSpawner

@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10

var _timer: Timer

func _ready() -> void:
    OrbRegistry.initialize()
    _setup_timer()

func _setup_timer() -> void:
    _timer = Timer.new()
    _timer.wait_time = spawn_interval
    _timer.autostart = true
    _timer.timeout.connect(_on_timeout)
    add_child(_timer)

func _on_timeout() -> void:
    if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
        return

    var def := OrbRegistry.get_weighted_random()
    if def == null:
        return

    var orb := _create_orb(def)
    orb.global_position = _get_random_position()
    add_child(orb)

func _create_orb(def: OrbDefinition) -> Orb:
    var orb: Orb
    if def.has_physics_body:
        orb = HalfSolidOrb.new()
    else:
        orb = Orb.new()
    orb.definition = def
    orb.add_to_group("orbs")
    return orb

func _get_random_position() -> Vector2:
    return Vector2(
        randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
        randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
    )
```

**Test Requirements**:
- Create `tests/unit/test_orb_spawner.gd`
- Test: spawns orbs from registry
- Test: respects max_orbs limit
- Test: weighted selection works

**Integration**: Replaces existing orb spawning logic

**Demo**: Orbs spawn correctly with proper weights

---

## Phase 4: Entity Refactoring

### Step 14: Refactor Ball to Use BallPhysics

**Objective**: Update Ball to use BallPhysics class and config resource.

**Implementation**:
1. Update `scripts/ball.gd` to use `BallPhysics.process_velocity()`
2. Load `BallPhysicsConfig` from resource or defaults
3. Add ball to "ball" group

**Code Structure**:
```gdscript
# scripts/ball.gd (refactored)
extends RigidBody2D
class_name Ball

@export var physics_config: BallPhysicsConfig

signal hit_ground
signal hit_half_solid

var _game_over: bool = false

func _ready() -> void:
    add_to_group("ball")
    if physics_config == null:
        physics_config = BallPhysicsConfig.new()
        physics_config.max_speed = Constants.ball_max_speed
        physics_config.max_fall_speed = Constants.ball_fall_speed
        physics_config.air_friction = Constants.ball_air_friction

func _physics_process(_delta: float) -> void:
    linear_velocity = BallPhysics.process_velocity(linear_velocity, physics_config)

func _on_body_entered(body: Node) -> void:
    if _game_over:
        return

    if body.is_in_group("ground"):
        _game_over = true
        hit_ground.emit()
        Events.game_over.emit(ScoreManager.get_score())
        GameState.is_paused = true
    elif body is HalfSolidOrb:
        body._on_ball_collision(self)

func apply_bounce(multiplier: float) -> void:
    linear_velocity *= multiplier

func reset() -> void:
    _game_over = false
```

**Test Requirements**:
- Update `tests/unit/test_ball_physics.gd` to verify integration
- Test: Ball uses BallPhysics correctly
- Test: collision detection works with groups

**Integration**: Ball now uses extracted physics

**Demo**: Ball physics unchanged, game plays normally

---

### Step 15: Refactor Player to Use PlayerPhysics

**Objective**: Update Player to use PlayerPhysics and PlayerInputState.

**Implementation**:
1. Update `scripts/physics_player.gd` to use extracted classes
2. Load `PlayerPhysicsConfig` from resource
3. Use `PlayerInputState` for input handling

**Code Structure**:
```gdscript
# scripts/physics_player.gd (refactored)
extends RigidBody2D
class_name Player

@export var physics_config: PlayerPhysicsConfig

var _input_state: PlayerInputState
var _is_grounded: bool = false
var _time_left_ground: int = 0
var _ended_jump_early: bool = false
var _coyote_usable: bool = false
var _buffered_jump_usable: bool = false
var _frame_velocity: Vector2 = Vector2.ZERO

@onready var _ground_cast: RayCast2D = $groundcast
@onready var _ceiling_cast: RayCast2D = $ceilingcast

func _ready() -> void:
    _input_state = PlayerInputState.new()
    if physics_config == null:
        physics_config = PlayerPhysicsConfig.new()
        _load_config_from_constants()

func _input(event: InputEvent) -> void:
    _input_state.process_input(event)

func _physics_process(delta: float) -> void:
    if GameState.is_paused:
        return

    _update_grounded()
    _handle_gravity(delta)
    _handle_jumping()
    _handle_movement(delta)
    _apply_velocity()

func _update_grounded() -> void:
    var was_grounded := _is_grounded
    _is_grounded = _ground_cast.is_colliding()

    if was_grounded and not _is_grounded:
        _time_left_ground = Time.get_ticks_msec()
        _coyote_usable = true
    elif not was_grounded and _is_grounded:
        _ended_jump_early = false

func _handle_gravity(delta: float) -> void:
    _frame_velocity.y = PlayerPhysics.calculate_gravity(
        _frame_velocity.y,
        _is_grounded,
        _ended_jump_early,
        physics_config,
        delta
    )

func _handle_jumping() -> void:
    if _input_state.jump_held and not _ended_jump_early and not _is_grounded and _frame_velocity.y < 0:
        _ended_jump_early = true

    if _input_state.jump_just_pressed:
        if _is_grounded or PlayerPhysics.can_coyote(_time_left_ground, Time.get_ticks_msec(), physics_config.coyote_timeout):
            _execute_jump()

func _execute_jump() -> void:
    _ended_jump_early = false
    _frame_velocity.y = physics_config.jump_power

func _handle_movement(delta: float) -> void:
    var target_speed := physics_config.move_speed
    _frame_velocity.x = PlayerPhysics.calculate_horizontal_velocity(
        _frame_velocity.x,
        _input_state.move_direction,
        target_speed,
        physics_config,
        delta
    )

func _apply_velocity() -> void:
    linear_velocity = _frame_velocity

func _load_config_from_constants() -> void:
    physics_config.jump_power = Constants.player_jump_power
    physics_config.move_speed = Constants.player_initial_move_speed
    physics_config.acceleration = Constants.player_move_acceleration
    physics_config.initial_acceleration = Constants.player_initial_move_acceleration
    physics_config.deceleration = Constants.player_move_deceleration
    physics_config.coyote_timeout = Constants.player_coyote_timeout
    physics_config.jump_buffer_timeout = Constants.player_jump_buffer_timeout
    physics_config.fall_acceleration = Constants.player_fall_acceleration
    physics_config.max_fall_speed = Constants.player_max_fall_speed
    physics_config.grounding_force = Constants.player_grounding_force
    physics_config.early_jump_gravity_modifier = Constants.player_Jump_ended_early_gravity_modifier
```

**Test Requirements**:
- Update `tests/unit/test_player_movement.gd` to verify integration
- Test: Player uses PlayerPhysics correctly
- Test: input state drives movement

**Integration**: Player now uses extracted physics and input

**Demo**: Player movement unchanged, game plays normally

---

### Step 16: Remove Old Orb Scripts

**Objective**: Remove deprecated orb scripts after new system is verified working.

**Implementation**:
1. Verify all orb functionality works with new Orb/HalfSolidOrb classes
2. Delete `scripts/blue_orb.gd`
3. Delete `scripts/red_orb.gd`
4. Delete `scripts/half_solid_orb.gd` (old version)
5. Delete `scripts/generic_orb.gd`
6. Delete associated old scenes
7. Update any remaining references

**Test Requirements**:
- Run full test suite
- Manual playtest all orb types

**Integration**: Old code removed, only new system remains

**Demo**: Game runs normally, all tests pass

---

### Step 17: Update Collision Detection to Use Groups

**Objective**: Replace hardcoded node name checks with group-based detection.

**Implementation**:
1. Add "ground" group to ground objects
2. Add "ball" group to Ball (done in Step 14)
3. Update all collision handlers to use `is_in_group()`

**Files to Update**:
- `scripts/ball.gd` - check `body.is_in_group("ground")`
- `scripts/entities/orb/orb.gd` - check `body.is_in_group("ball")`
- Scene files - add groups to appropriate nodes

**Test Requirements**:
- Update collision tests to verify group-based detection
- Test: ball detects ground via group
- Test: orbs detect ball via group

**Integration**: All collision detection uses groups

**Demo**: Game plays normally with group-based detection

---

## Phase 5: Test Expansion

### Step 18: Add Comprehensive Unit Tests

**Objective**: Ensure all new classes have thorough unit test coverage.

**Implementation**:
1. Review all test files for coverage gaps
2. Add edge case tests
3. Add tests for error conditions
4. Ensure all tests can run without scene instantiation

**Tests to Add/Update**:
- `test_game_state.gd` - all state transitions
- `test_score_manager.gd` - edge cases
- `test_ball_physics.gd` - all physics functions
- `test_player_physics.gd` - all physics functions
- `test_player_input_state.gd` - all input scenarios
- `test_orb_registry.gd` - registration, selection
- `test_orb.gd` - spawn, collect, lifetime
- `test_half_solid_orb.gd` - bounce behavior

**Test Requirements**:
- All tests pass
- No test uses scene instantiation (pure unit tests)
- Coverage > 90% of new code

**Demo**: Run `./devscripts/test.sh` - all pass

---

### Step 19: Add Integration Tests

**Objective**: Test game scenarios with actual scene instantiation.

**Implementation**:
1. Create integration test scenes
2. Test full game loops
3. Test edge cases with real components

**Tests to Create**:
- `test_orb_collection_integration.gd` - spawn orb, collect, verify score
- `test_game_loop.gd` - start, play, game over
- `test_pause_integration.gd` - pause mid-game, verify state

**Code Structure**:
```gdscript
# tests/integration/test_orb_collection_integration.gd
extends GutTest

func test_orb_collection_adds_score():
    TestUtils.reset_global_state()

    # Create orb
    var def := OrbRegistry.get_definition(&"blue")
    var orb := Orb.new()
    orb.definition = def
    add_child_autofree(orb)

    # Collect it
    var initial_score := ScoreManager.get_score()
    orb.collect()
    await get_tree().process_frame

    assert_eq(ScoreManager.get_score(), initial_score + def.score_value)

func test_paused_orb_not_collected():
    TestUtils.reset_global_state()
    GameState.is_paused = true

    var def := OrbRegistry.get_definition(&"blue")
    var orb := Orb.new()
    orb.definition = def
    add_child_autofree(orb)

    var initial_score := ScoreManager.get_score()
    orb.collect()

    assert_eq(ScoreManager.get_score(), initial_score)
```

**Test Requirements**:
- All integration tests pass
- Tests use actual scene components
- Tests clean up properly

**Demo**: Run integration tests - all pass

---

### Step 20: Final Validation and Cleanup

**Objective**: Verify entire refactor is complete and working.

**Implementation**:
1. Run full test suite
2. Run smoke test
3. Manual playtest all features
4. Clean up any temporary code
5. Update documentation

**Checklist**:
- [ ] `./devscripts/test.sh` exits 0
- [ ] `./devscripts/smoke_test.sh` exits 0
- [ ] Game plays normally
- [ ] All orb types work
- [ ] Pause/resume works
- [ ] Score tracking works
- [ ] Sound works
- [ ] No console errors

**Test Requirements**:
- All automated tests pass
- Manual testing complete

**Demo**: Complete game works as before, with cleaner architecture

---

## Summary

### What Was Changed

| Area | Changes |
|------|---------|
| **Core** | New GameState, ScoreManager singletons; Events refactored |
| **Physics** | BallPhysics, PlayerPhysics extracted as pure logic |
| **Orbs** | OrbDefinition resources, OrbRegistry, unified Orb class |
| **Entities** | Ball, Player use extracted physics; collision uses groups |
| **Tests** | Comprehensive unit + integration tests |

### What Was Preserved

- All gameplay mechanics
- All visual/audio behavior
- All UI functionality
- Save/load system

### Extension Points Now Available

1. **New Orb Types**: Add to OrbRegistry with definition
2. **New Game Modes**: Use GameState.current_mode
3. **Physics Variants**: Create new config resources
4. **Custom Behaviors**: Extend Orb class

### Future Expansion Hooks

- `OrbDefinition.spawn_weight` for rarity
- `OrbDefinition.has_physics_body` for solid orbs
- `GameState.current_mode` for mode-specific logic
- `PlayerPhysicsConfig` for difficulty variants
