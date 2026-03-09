# Detailed Design: AI-Friendly Godot Game Refactor

## Overview

This document defines the architecture for refactoring "Don't Drop the Ball" to be AI-friendly, modular, testable, and extensible. The refactor addresses three main areas: orb system, global state management, and scene coupling, while preserving existing gameplay behavior.

### Goals

1. **Preserve Gameplay**: Game functions identically after refactor
2. **Improve Modularity**: Separate logic from scene glue, reduce coupling
3. **Improve Testability**: Comprehensive unit + integration tests
4. **Enable Extension**: Make future orb types, game modes, environments easy to add
5. **AI-Friendly**: Clear patterns, typed code, easy for AI assistants to modify

### Non-Goals

- Adding new orb types, modes, or content (future work)
- Changing project settings or input mappings
- Modifying assets or visual appearance

---

## Detailed Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR1 | Ball bounces on player head with deflection physics | Must |
| FR2 | Orbs spawn in air and grant score when collected | Must |
| FR3 | Game over when ball touches ground | Must |
| FR4 | Pause/resume functionality works | Must |
| FR5 | Score and high score (PB) tracking | Must |
| FR6 | Sound effects and music play correctly | Must |
| FR7 | Main menu, settings, game over screens work | Must |

### Quality Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| QR1 | New orb types can be added with minimal code changes | High |
| QR2 | Core logic can be unit tested without scenes | High |
| QR3 | Integration tests can verify game scenarios | High |
| QR4 | Global state is managed through proper singletons | High |
| QR5 | No hardcoded node name checks for game logic | Medium |
| QR6 | Code follows consistent naming and typing patterns | Medium |

### Constraint Requirements

| ID | Requirement |
|----|-------------|
| CR1 | All tests must pass via `./devscripts/test.sh` |
| CR2 | Smoke test must pass |
| CR3 | Use typed GDScript throughout |
| CR4 | Keep diffs focused and reviewable |

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      GAME RUNTIME                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Scenes    │  │   Entities  │  │   Systems   │         │
│  │  (Godot)    │◄─┤  (Nodes)    │◄─┤  (Logic)    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│         │                │                │                 │
│         ▼                ▼                ▼                 │
│  ┌─────────────────────────────────────────────────┐       │
│  │              CORE LAYER (Autoloads)             │       │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐    │       │
│  │  │GameState │ │  Events  │ │ ScoreManager │    │       │
│  │  └──────────┘ └──────────┘ └──────────────┘    │       │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐    │       │
│  │  │Constants │ │  Enums   │ │ GameSaves    │    │       │
│  │  └──────────┘ └──────────┘ └──────────────┘    │       │
│  └─────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Dependencies |
|-------|----------------|--------------|
| **Scenes** | Godot scene tree, visual composition | Entities |
| **Entities** | Game objects (Ball, Player, Orbs) | Systems, Core |
| **Systems** | Pure game logic, physics calculations | Core only |
| **Core** | Global state, events, data management | None (bottom layer) |

---

## Components and Interfaces

### Core Layer (Autoloads)

#### 1. GameState (New Singleton)

**Purpose**: Centralized game state management, replaces `PauseEvent.state`

```gdscript
# core/game_state.gd
extends Node
class_name GameState

signal pause_changed(is_paused: bool)
signal game_mode_changed(mode: GameMode)

var is_paused: bool = false:
    set(value):
        if value != is_paused:
            is_paused = value
            pause_changed.emit(value)

var current_mode: GameMode = GameMode.MENU:
    set(value):
        if value != current_mode:
            current_mode = value
            game_mode_changed.emit(value)

func toggle_pause() -> void:
    is_paused = !is_paused

func reset() -> void:
    is_paused = false
    current_mode = GameMode.MENU
```

#### 2. Events (Refactored)

**Purpose**: Global signal bus for cross-system communication

```gdscript
# core/events.gd
extends Node
class_name Events

# Game flow signals
signal game_started
signal game_over(final_score: int)
signal game_restarted

# Score signals
signal score_added(amount: int, source: String)
signal score_changed(new_score: int)

# Orb signals
signal orb_collected(orb_type: StringName, position: Vector2)
signal orb_spawned(orb_type: StringName, position: Vector2)

# UI signals
signal main_button_pressed(button_type: Enums.MainButtonType)
signal world_button_pressed(button_type: Enums.WorldButtonType)
```

#### 3. ScoreManager (Refactored)

**Purpose**: Pure score logic, extracted from scene dependencies

```gdscript
# core/score_manager.gd
extends Node
class_name ScoreManager

var _current_score: int = 0
var _high_score: int = 0

func get_score() -> int:
    return _current_score

func get_high_score() -> int:
    return _high_score

func add_score(amount: int) -> int:
    _current_score += amount
    if _current_score > _high_score:
        _high_score = _current_score
    Events.score_changed.emit(_current_score)
    return _current_score

func reset_score() -> void:
    _current_score = 0
    Events.score_changed.emit(_current_score)

func load_high_score(value: int) -> void:
    _high_score = value
```

### Entity Layer

#### 1. Orb System (Redesigned)

**OrbDefinition** - Resource for orb configuration:

```gdscript
# entities/orb/orb_definition.gd
class_name OrbDefinition extends Resource

@export var type_name: StringName  # "blue", "red", "half_solid"
@export var display_name: String
@export var score_value: int = 1
@export var lifespan_seconds: float = 30.0
@export var scene: PackedScene
@export var sprite_texture: Texture2D
@export var has_physics_body: bool = false  # For half_solid
@export_category("Spawn Settings")
@export var spawn_weight: float = 1.0  # Relative spawn probability
```

**OrbRegistry** - Centralized orb type registration:

```gdscript
# entities/orb/orb_registry.gd
class_name OrbRegistry

static var _definitions: Dictionary = {}
static var _initialized: bool = false

static func initialize() -> void:
    if _initialized:
        return
    register(_create_blue_orb_def())
    register(_create_red_orb_def())
    register(_create_half_solid_orb_def())
    _initialized = true

static func register(def: OrbDefinition) -> void:
    _definitions[def.type_name] = def

static func get_definition(type_name: StringName) -> OrbDefinition:
    return _definitions.get(type_name)

static func get_all_definitions() -> Array[OrbDefinition]:
    var result: Array[OrbDefinition] = []
    for def in _definitions.values():
        result.append(def)
    return result

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

**Orb** - Base orb class:

```gdscript
# entities/orb/orb.gd
class_name Orb extends Node2D

signal collected

@export var definition: OrbDefinition

var _lifetime_timer: Timer
var _is_active: bool = false

func _ready() -> void:
    _setup_timer()
    _setup_visuals()
    _setup_collision()

func _setup_timer() -> void:
    _lifetime_timer = Timer.new()
    _lifetime_timer.one_shot = true
    _lifetime_timer.wait_time = definition.lifespan_seconds
    _lifetime_timer.timeout.connect(queue_free)
    add_child(_lifetime_timer)
    _lifetime_timer.start()

func collect() -> void:
    if _is_active and not GameState.is_paused:
        collected.emit()
        Events.orb_collected.emit(definition.type_name, global_position)
        Events.score_added.emit(definition.score_value, definition.type_name)
        _on_collect()
        queue_free()

func _on_collect() -> void:
    # Override in subclasses for special behavior
    pass

func set_spawn_progress(progress: float) -> void:
    # For spawn animation (0.0 to 1.0)
    modulate.a = progress * 0.75 + 0.25

func activate() -> void:
    _is_active = true
    modulate.a = 1.0
```

**HalfSolidOrb** - Extended orb with physics:

```gdscript
# entities/orb/half_solid_orb.gd
class_name HalfSolidOrb extends Orb

var _physics_body: StaticBody2D

func _ready() -> void:
    super._ready()
    _setup_physics_body()

func _setup_physics_body() -> void:
    _physics_body = $half_static

func _on_collect() -> void:
    # Half solid orbs don't immediately collect, ball bounces first
    pass

func on_ball_collision(ball: Ball) -> void:
    ball.velocity /= 3
```

#### 2. Ball Entity (Refactored)

```gdscript
# entities/ball.gd
class_name Ball extends RigidBody2D

signal hit_ground
signal hit_half_solid

@export var physics_config: BallPhysicsConfig

var velocity: Vector2:
    get: return linear_velocity
    set(value): linear_velocity = value

func _ready() -> void:
    _apply_config()

func _physics_process(_delta: float) -> void:
    _clamp_velocity()

func _clamp_velocity() -> void:
    if physics_config:
        linear_velocity = BallPhysics.clamp_velocity(
            linear_velocity,
            physics_config.max_speed,
            physics_config.max_fall_speed,
            physics_config.air_friction
        )

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("ground"):
        if not GameState.is_paused:
            hit_ground.emit()
            Events.game_over.emit(ScoreManager.get_score())
    elif body is HalfSolidOrb:
        body.on_ball_collision(self)
        hit_half_solid.emit()
```

#### 3. Player Entity (Refactored)

```gdscript
# entities/player.gd
class_name Player extends RigidBody2D

signal jumped
signal landed

@export var physics_config: PlayerPhysicsConfig

var _input_state: PlayerInputState = PlayerInputState.new()
var _physics_state: PlayerPhysicsState = PlayerPhysicsState.new()

func _ready() -> void:
    _apply_config()

func _physics_process(delta: float) -> void:
    if GameState.is_paused:
        return

    _update_physics_state()
    _apply_movement(delta)
    _apply_gravity(delta)
    _handle_jumping()

func _input(event: InputEvent) -> void:
    _input_state.process_input(event)

func get_move_direction() -> float:
    return _input_state.move_direction
```

### Systems Layer

#### Physics Calculations (Pure Logic)

```gdscript
# systems/physics/ball_physics.gd
class_name BallPhysics

static func clamp_velocity(
    velocity: Vector2,
    max_speed: float,
    max_fall_speed: float,
    air_friction: float
) -> Vector2:
    var result := velocity

    # Clamp max speed
    if max_speed > 0.0:
        var speed := result.length()
        if speed > max_speed:
            result = result.normalized() * max_speed

    # Clamp fall speed
    if max_fall_speed > 0.0 and result.y > max_fall_speed:
        result.y = max_fall_speed

    # Apply air friction
    if air_friction > 0.0:
        result.x *= (1.0 - air_friction / 1000.0)

    return result
```

```gdscript
# systems/physics/player_physics.gd
class_name PlayerPhysics

static func calculate_horizontal_velocity(
    current: float,
    target: float,
    acceleration: float,
    deceleration: float,
    delta: float
) -> float:
    if target != 0.0:
        return move_toward(current, target, acceleration * delta)
    else:
        return move_toward(current, 0.0, deceleration * delta)

static func can_coyote(
    time_left_ground: int,
    current_time: int,
    coyote_timeout: float
) -> bool:
    return current_time < time_left_ground + coyote_timeout

static func has_buffered_jump(
    time_jump_pressed: int,
    current_time: int,
    buffer_timeout: float
) -> bool:
    return current_time < time_jump_pressed + buffer_timeout
```

---

## Data Models

### Configuration Resources

```gdscript
# data/ball_physics_config.gd
class_name BallPhysicsConfig extends Resource

@export var max_speed: float = 900.0
@export var max_fall_speed: float = 500.0
@export var air_friction: float = 9.0
```

```gdscript
# data/player_physics_config.gd
class_name PlayerPhysicsConfig extends Resource

@export var jump_power: int = -700
@export var move_speed: int = 120
@export var move_acceleration: float = 1500.0
@export var move_deceleration: float = 10000.0
@export var coyote_timeout: float = 150.0
@export var jump_buffer_timeout: float = 150.0
@export var fall_acceleration: float = 1800.0
@export var max_fall_speed: float = 800.0
@export var grounding_force: float = 1.5
@export var early_jump_gravity_modifier: float = 3.0
```

### State Classes

```gdscript
# data/player_input_state.gd
class_name PlayerInputState

var move_direction: float = 0.0
var jump_pressed: bool = false
var jump_held: bool = false
var jump_just_pressed: bool = false

func process_input(event: InputEvent) -> void:
    if event.is_action_pressed("Left"):
        move_direction = -1.0
        jump_just_pressed = false
    elif event.is_action_released("Left"):
        if move_direction < 0:
            move_direction = 0.0

    if event.is_action_pressed("Right"):
        move_direction = 1.0
        jump_just_pressed = false
    elif event.is_action_released("Right"):
        if move_direction > 0:
            move_direction = 0.0

    if event.is_action_pressed("Jump"):
        jump_pressed = true
        jump_held = true
        jump_just_pressed = true
    elif event.is_action_released("Jump"):
        jump_held = false
```

### Enums

```gdscript
# core/enums.gd
class_name Enums

enum GameMode {
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

enum MainButtonType {
    PLAY,
    SETTINGS,
    BACK,
    EXIT
}

enum WorldButtonType {
    MAIN_MENU,
    BACK,
    REPLAY
}
```

---

## Error Handling

### Validation Strategy

1. **Type Safety**: Use static typing throughout, let GDScript catch type errors
2. **Null Checks**: Use `@export` for required dependencies, validate in `_ready()`
3. **State Validation**: GameState ensures valid state transitions
4. **Resource Validation**: OrbRegistry validates definitions at startup

### Error Patterns

```gdscript
# Graceful degradation
func get_definition(type_name: StringName) -> OrbDefinition:
    if not _definitions.has(type_name):
        push_warning("Unknown orb type: " + str(type_name))
        return _definitions.values()[0] if _definitions.size() > 0 else null
    return _definitions[type_name]
```

```gdscript
# State assertion
func _ready() -> void:
    assert(definition != null, "Orb requires a definition")
    _setup()
```

---

## Testing Strategy

### Unit Tests (No Scene Dependencies)

| Test File | What It Tests |
|-----------|---------------|
| `test_ball_physics.gd` | BallPhysics static functions |
| `test_player_physics.gd` | PlayerPhysics static functions |
| `test_score_manager.gd` | ScoreManager logic |
| `test_orb_definition.gd` | OrbDefinition resource |
| `test_orb_registry.gd` | OrbRegistry lookup/weighting |
| `test_game_state.gd` | GameState transitions |
| `test_player_input_state.gd` | Input state tracking |

### Integration Tests (Scene-Based)

| Test File | What It Tests |
|-----------|---------------|
| `test_orb_collection.gd` | Full orb collection flow |
| `test_ball_collision.gd` | Ball physics in scene |
| `test_game_flow.gd` | Start → Play → Game Over flow |
| `test_pause_resume.gd` | Pause state affects game |
| `test_score_accumulation.gd` | Score through multiple orbs |

### Test Utilities

```gdscript
# tests/test_utils.gd
class_name TestUtils

static func reset_global_state() -> void:
    GameState.is_paused = false
    GameState.current_mode = Enums.GameMode.MENU
    ScoreManager.reset_score()

static func wait_frames(tree: SceneTree, frames: int) -> void:
    for i in frames:
        await tree.process_frame
```

---

## Appendices

### A. Technology Choices

| Choice | Rationale |
|--------|-----------|
| **Resource for configs** | Serializable, editor-friendly, hot-reloadable |
| **Static functions for physics** | Pure, testable, no state dependencies |
| **Signals over direct calls** | Loose coupling, easier to extend |
| **Singleton for global state** | Clean access, proper lifecycle |
| **Composition for orbs** | Flexible, avoids deep inheritance |

### B. Research Findings Summary

1. **Orb duplication**: ~80% duplicate code across 3 orb classes
2. **Global state**: `PauseEvent.state` creates hidden coupling
3. **Scene coupling**: Hardcoded node names and paths
4. **Test gaps**: Logic duplicated in tests rather than testing actual code

### C. Alternative Approaches Considered

| Approach | Why Not Chosen |
|----------|----------------|
| **Full data-driven (JSON)** | Over-engineering for current scope |
| **ECS architecture** | Too much rework for a 2D casual game |
| **Keep current event system** | Doesn't solve global state issue |
| **Plugin system** | Premature - no mod support needed yet |

### D. Migration Path

The refactor will be done in systematic phases:

1. **Phase 1**: Core infrastructure (GameState, ScoreManager, Events refactor)
2. **Phase 2**: Physics extraction (pure logic classes)
3. **Phase 3**: Orb system redesign (OrbDefinition, OrbRegistry, Orb class)
4. **Phase 4**: Scene updates (wire new components)
5. **Phase 5**: Test expansion (unit + integration)

Each phase maintains working game state and passing tests.

---

## Design Approval

- [ ] Design reviewed and approved
- [ ] Ready to proceed to implementation planning
