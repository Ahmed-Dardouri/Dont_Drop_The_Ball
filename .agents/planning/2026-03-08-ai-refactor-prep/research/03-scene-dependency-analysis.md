# Research: Scene Dependency Analysis

## Current Autoload Configuration

From `project.godot`:

| Autoload | Path | Purpose |
|----------|------|---------|
| `PhantomCameraManager` | `addons/phantom_camera/...` | Camera system |
| `Events` | `addons/dynamic_event_manager/...` | Event bus |
| `Constants` | `scripts/utils/Constants.gd` | Game constants |
| `GameSaveMngr` | `scripts/utils/game_save_mngr.gd` | Save/load |
| `Variables` | `scripts/utils/variables.gd` | Runtime variables |

## Scene Tree Structure

```
main.tscn (Main Scene)
├── world_builder (WorldBuilder scene)
│   ├── game_over_screen
│   ├── pause_screen
│   ├── hud
│   │   └── score_label, pb_label
│   └── world (World scene)
│       ├── ball
│       ├── PhysicsPlayer
│       ├── PhantomCamera2D
│       ├── const_objs (ground, walls)
│       └── mode_objs
│           ├── orb_mngr
│           ├── orb_spawner
│           └── sound_mngr
├── main_menu
├── settings_menu
├── Camera2D
└── PhantomCamera2D
```

## Node Path Dependencies (@onready)

### High Coupling Scripts

#### physics_player.gd
```gdscript
@onready var ground_cast := $groundcast
@onready var ceiling_cast := $ceilingcast
```
**Coupling**: Requires specific child nodes for raycasting

#### ball.gd
```gdscript
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
```
**Coupling**: Requires ShapeCast2D child

#### blue_orb.gd / red_orb.gd / half_solid_orb.gd
```gdscript
@onready var orb_sprite: Sprite2D = $orb_sprite
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer
```
**Coupling**: Requires specific node hierarchy

#### sound_mngr.gd
```gdscript
@onready var music_player: AudioStreamPlayer2D = $music_player
@onready var sfx_player: AudioStreamPlayer2D = $sfx_player
```
**Coupling**: Requires audio player children

#### hud.gd
```gdscript
@onready var score_label: Label = $MarginContainer/HBoxContainer/score_label
@onready var pb_label: Label = $MarginContainer/HBoxContainer/pb_label
```
**Coupling**: Requires specific UI hierarchy

#### main.gd
```gdscript
@onready var world_builder: Node2D = $world_builder
@onready var phantom_camera_2d: PhantomCamera2D = $PhantomCamera2D
@onready var main_menu: Control = $main_menu
@onready var settings_menu: Control = $settings_menu
@onready var camera_2d: Camera2D = $Camera2D
```
**Coupling**: Heavy coupling to main scene structure

### Global Dependencies (Non-Scene)

Scripts that depend on autoloads/singletons:

| Script | Depends On |
|--------|------------|
| Almost all | `Events`, `Constants`, `Enums` |
| score_mngr.gd | `Variables` |
| game_save_mngr.gd | `SavedGame` (resource) |
| Many event files | `PauseEvent.state` (static) |

### Hardcoded Name Checks

Several scripts check node names as strings:

```gdscript
# ball.gd
if body.name == "ground_static" && !game_over:
    ...
elif body.name == "half_static":
    ...

# blue_orb.gd, red_orb.gd, half_solid_orb.gd
if body.name == "ball":
    orb_collected()
```

**Problem**: Fragile to scene changes, not type-safe

### Scene Instantiation Patterns

#### orb_spawner.gd
```gdscript
@export var generic_orb_scene: PackedScene

func create_orb_copy(props: OrbProps) -> Node:
    var orb_cpy = generic_orb_scene.instantiate()
    orb_cpy.set_type(props)
    return orb_cpy
```
**Pattern**: Good - uses exported PackedScene reference

#### main.gd (world reloading)
```gdscript
var _scene_path := "res://scenes/world_builder.tscn"

func _reload_world():
    var new_scene = load(_scene_path).instantiate()
    # ... remove old, add new
```
**Pattern**: Hardcoded path - could use exported reference

### Decoupling Opportunities

1. **Export Node References**: Replace some `@onready` with `@export` for flexibility
   ```gdscript
   # Instead of
   @onready var ground_cast := $groundcast
   # Use
   @export var ground_cast: RayCast2D
   ```

2. **Interface/Groups for Collision Detection**:
   ```gdscript
   # Instead of name check
   if body.name == "ball":
   # Use groups
   if body.is_in_group("ball"):
   # Or type check
   if body is Ball:
   ```

3. **Dependency Injection for Testing**:
   ```gdscript
   # Allow injection for tests
   var _ground_cast: RayCast2D
   func get_ground_cast() -> RayCast2D:
       return _ground_cast if _ground_cast else $groundcast
   ```

4. **Scene References via Export**:
   ```gdscript
   # Instead of hardcoded path
   @export var world_scene: PackedScene
   ```

## Test Infrastructure Coupling

Current tests avoid scene instantiation where possible:

```gdscript
# test_ball_physics.gd
func _create_ball_test_script() -> GDScript:
    var script = GDScript.new()
    script.source_code = """..."""  # Inline script duplication
    script.reload()
    return script
```

**Issue**: Tests duplicate logic to avoid scene dependencies

**Solution**: Extract pure logic classes that can be tested independently
