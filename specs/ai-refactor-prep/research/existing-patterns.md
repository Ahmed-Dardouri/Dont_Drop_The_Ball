# Existing Patterns Research

## Codebase Overview

**Engine:** Godot 4.4
**Language:** GDScript
**Structure:** Flat `scripts/` with `utils/` subfolder, `scenes/` for .tscn files
**Test Framework:** GUT (Godot Unit Testing)

### File Counts
- Scripts: 41 .gd files
- Tests: 9 test files (7 unit, 2 integration)
- Scenes: 24 .tscn files

---

## Autoload Structure (from project.godot:18-24)

```
PhantomCameraManager - res://addons/phantom_camera/scripts/managers/phantom_camera_manager.gd
Events              - res://addons/dynamic_event_manager/src/event_manager.gd
Constants           - res://scripts/utils/Constants.gd
GameSaveMngr        - res://scripts/utils/game_save_mngr.gd
Variables           - res://scripts/utils/variables.gd
```

---

## Event System Pattern (from addons/dynamic_event_manager/src/event_manager.gd)

### Registration
```gdscript
# From scripts/main.gd:106-109
Events.add_listener(ReplayEvent, replay_handler)
Events.add_listener(PauseEvent, handle_pause)
Events.add_listener(ButtonEvent, handle_buttons)
```

### Invocation Pattern
```gdscript
# From scripts/events/pause_event.gd:11-13
static func invoke(pause : bool):
    state = pause
    Events.invoke(PauseEvent.new(pause))
```

### Event Class Structure
```gdscript
# From addons/dynamic_event_manager/src/Event.gd:16
class_name Event extends RefCounted
```

### Key Events in Codebase
- `PauseEvent` - static `state` variable for pause state
- `GameOverEvent` - triggers game over
- `AddScoreEvent` - adds score (checks `PauseEvent.state`)
- `OrbCollectedEvent` - fired when orb collected
- `MoveEvent` - player input movement
- `ButtonEvent` - UI button presses
- `ReplayEvent` - replay game

---

## Collision Detection Pattern (PROBLEM: Hardcoded Names)

### Ball → Ground Check (scripts/ball.gd:48-55)
```gdscript
func _on_body_entered(body: Node) -> void:
    if body.name == "ground_static" && !game_over:  # PROBLEM: hardcoded name
        game_over = true
        GameOverEvent.invoke()
        PauseEvent.invoke(true)
        SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)
    elif body.name == "half_static":  # PROBLEM: hardcoded name
        linear_velocity = linear_velocity/3
```

### Orb → Ball Check (scripts/blue_orb.gd:24-26)
```gdscript
func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":  # PROBLEM: hardcoded name
        orb_collected()
```

### Node Names in Scenes
- `scripts/ball.gd:49` checks `body.name == "ground_static"`
- `scenes/ground.tscn:9` defines node: `[node name="ground_static" parent="." ...]`
- `scripts/ball.gd:54` checks `body.name == "half_static"`
- `scenes/half_solid_orb.tscn:20` defines node: `[node name="half_static" type="StaticBody2D" ...]`
- `scenes/ball.tscn:16` defines node: `[node name="ball" type="RigidBody2D" ...]`

---

## Score Flow (Current Architecture)

```
Ball collides with Orb
    ↓
Orb calls OrbCollectedEvent.invoke(props)  [blue_orb.gd:19, red_orb.gd:18, half_solid_orb.gd:20]
    ↓
orb_mngr.gd handles event  [scripts/orb_mngr.gd:13-22]
    ↓
orb_mngr calls AddScoreEvent.invoke(score)  [scripts/orb_mngr.gd:26,30,34]
    ↓
AddScoreEvent checks PauseEvent.state  [scripts/events/add_score_event.gd:9-11]
    ↓
score_mngr.gd handles event, updates UI  [scripts/score_mngr.gd:22-24]
```

---

## Physics Constants Pattern (scripts/utils/Constants.gd)

### Player Constants (lines 4-19)
```gdscript
var player_keyboard_move_power : int = 500
var player_jump_power : int = -700
var player_initial_move_speed : int = 120
var player_coyote_timeout : float = 150.0
var player_jump_buffer_timeout : float = 150.0
var player_grounding_force : float = 1.5
var player_fall_acceleration : float = 1800.0
var player_max_fall_speed : float = 800
var player_Jump_ended_early_gravity_modifier : float = 3.0
var player_move_acceleration : float = 1500
var player_initial_move_acceleration : float = 2000
var player_move_deceleration : float = 10000
var player_stop_on_ceiled : bool = false
var player_mass_const : float = 100.0
var player_gravity : float = 1.0
```

### Ball Constants (lines 23-27)
```gdscript
var ball_max_speed := 900.0
var ball_fall_speed := 500.0
var ball_air_friction := 9
```

### Orb Constants (lines 31-39)
```gdscript
var orb_lifespan_blue = 30
var orb_lifespan_red = 30
var orb_lifespan_half_solid = 18

var orb_score_blue = 2
var orb_score_red = 3
var orb_score_half_solid = 8
```

### Loading Pattern (scripts/physics_player.gd:217-236)
```gdscript
func load_constants():
    keyboard_move_power = Constants.player_keyboard_move_power
    jump_power = Constants.player_jump_power
    # ... etc

func apply_constants():
    mass = mass_const
    gravity_scale = gravity
```

---

## Orb System Current Architecture

### OrbTypes Enum (scripts/utils/enums.gd:9-13)
```gdscript
enum OrbType {
    RED,
    BLUE,
    HALF_SOLID
}
```

### OrbProps Resource (scripts/utils/orb_properties.gd:1-3)
```gdscript
class_name OrbProps extends Resource
@export var Type : Enums.OrbType = Enums.OrbType.BLUE
```

### Orb Hierarchy (scenes/generic_orb.tscn)
```
generic_orb (Node2D, GenericOrb script)
├── Timer (1.5s spawn animation)
└── child_orbs (Node2D)
    ├── blue_orb (BlueOrb)
    ├── red_orb (RedOrb)
    └── half_solid_orb (HalfSolidOrb)
```

### Orb Selection Pattern (scripts/generic_orb.gd:27-40)
```gdscript
func converge_orb(type: Enums.OrbType):
    match type:
        Enums.OrbType.BLUE:
            _child_orb = blue_orb
        Enums.OrbType.RED:
            _child_orb = red_orb
        Enums.OrbType.HALF_SOLID:
            _child_orb = half_solid_orb

    for child in child_orbs.get_children():
        if child != _child_orb:
            child.queue_free()  # Remove unused orb types
```

### OrbSpawner (scripts/orb_spawner.gd:22-43)
- Already uses groups: `get_tree().get_nodes_in_group("orbs")`
- Uses `OrbProps` array for weighted selection
- Creates `GenericOrb` instances from scene reference

---

## Testing Patterns (from tests/)

### GUT Configuration (.gutconfig.json:1-8)
```json
{
  "dirs": ["res://tests/"],
  "include_subdirs": true,
  "prefix": "test_",
  "suffix": ".gd",
  "log_level": 2,
  "should_exit": true
}
```

### Test Structure (from tests/unit/test_ball_physics.gd)
```gdscript
extends GutTest

func before_each() -> void:
    # Setup

func test_clamp_max_speed_no_clamp_when_under_limit() -> void:
    # Test logic
    assert_eq(actual, expected, "message")
```

### Test Helper Pattern (from tests/unit/test_player_movement.gd:6-26)
- Mirror logic from source in helper functions
- Test pure logic without scene instantiation
- Use constants validation tests

---

## Scene Management Pattern (scripts/main.gd)

### Scene Switching (lines 112-127)
```gdscript
func switch_scene(scene: Enums.MainScene):
    _current_scene = scene
    hide_scenes()
    match _current_scene:
        Enums.MainScene.WORLD_BUILDER:
            world_builder.visible = true
        Enums.MainScene.MAIN_MENU:
            main_menu.visible = true
        # ...
```

### World Reload (lines 27-52)
- Uses queue_free() + add_child() pattern
- Requires multiple `await Engine.get_main_loop().process_frame` calls

---

## Naming Conventions

### Consistent Patterns
- Class files: snake_case.gd
- Class names: PascalCase (class_name)
- Functions: snake_case
- Variables: snake_case
- Private vars: _snake_case
- Constants autoload: PascalCase properties (not actual GDScript const)

### Inconsistencies Found
- `physics_player.gd:18`: `Jump_ended_early_gravity_modifier` (PascalCase in variable)
- `physics_player.gd:35`: `_JumpHeld` (PascalCase private var)
- `scripts/utils/Constants.gd`: file is PascalCase.gd but should be snake_case.gd per Godot convention

---

## Key Integration Points Summary

| Component | File | Dependencies |
|-----------|------|--------------|
| Ball | `scripts/ball.gd` | Constants, GameOverEvent, PauseEvent, SoundPlayEvent |
| Player | `scripts/physics_player.gd` | Constants, MoveEvent, Events listener |
| BlueOrb | `scripts/blue_orb.gd` | Constants, OrbCollectedEvent, SoundPlayEvent |
| RedOrb | `scripts/red_orb.gd` | Constants, OrbCollectedEvent, SoundPlayEvent |
| HalfSolidOrb | `scripts/half_solid_orb.gd` | Constants, OrbCollectedEvent, SoundPlayEvent |
| GenericOrb | `scripts/generic_orb.gd` | OrbProps, child orb scenes |
| OrbSpawner | `scripts/orb_spawner.gd` | OrbProps, GenericOrb scene |
| ScoreMngr | `scripts/score_mngr.gd` | AddScoreEvent, GameLoadEvent, Variables |
| OrbMngr | `scripts/orb_mngr.gd` | OrbCollectedEvent, AddScoreEvent, Constants |
| Main | `scripts/main.gd` | ReplayEvent, PauseEvent, ButtonEvent |
