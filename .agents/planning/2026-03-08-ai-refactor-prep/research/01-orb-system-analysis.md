# Research: Orb System Deep Dive

## Current Architecture

### Orb Type Hierarchy

```
GenericOrb (container/selector)
├── BlueOrb (child node)
├── RedOrb (child node)
└── HalfSolidOrb (child node)
```

### Scene Structure

1. **generic_orb.tscn**: Container scene with ALL three orb types as child nodes
   - Has a Timer for spawn animation
   - References blue_orb.tscn, red_orb.tscn, half_solid_orb.tscn
   - `set_type(props)` determines which child orb to use
   - Non-selected child orbs are `queue_free()`'d

2. **Individual orb scenes**: blue_orb.tscn, red_orb.tscn, half_solid_orb.tscn
   - Each has its own script (blue_orb.gd, red_orb.gd, half_solid_orb.gd)
   - Nearly identical structure with minor variations

### Code Duplication Analysis

All three orb scripts share this common pattern:

```gdscript
# Common to all:
@onready var orb_sprite: Sprite2D
@onready var timer: Timer
var _props: OrbProps = null
var _lifespan: int = Constants.orb_lifespan_XXX

func _ready():
    _props_init()
    update_orb()

func orb_collected():
    OrbCollectedEvent.invoke(_props)
    SoundPlayEvent.invoke(...)
    queue_free()

func _on_area_2d_body_entered(body):
    if body.name == "ball":
        orb_collected()

func setup_timer(): ...
func _on_timeout(): queue_free()
func _props_init(): _props = OrbProps.new(); _props.Type = XXX
func set_sprite_opacity(value): ...
func set_collision_enable(value): ...
```

### Variations Between Orb Types

| Aspect | BlueOrb | RedOrb | HalfSolidOrb |
|--------|---------|--------|--------------|
| Lifespan | 30s | 30s | 18s |
| Score | 2 | 3 | 8 |
| Collision | Area2D | Area2D | Area2D + StaticBody2D |
| Visual | Single sprite | Single sprite | Two sprites (collect + solid) |
| Special | None | None | Ball bounces off (velocity/3) |

### Current Issues

1. **Massive Code Duplication**: ~80% identical code across 3 orb classes
2. **Wasteful Scene Instantiation**: GenericOrb loads ALL orb types, then deletes 2 of them
3. **Hardcoded Type Mapping**: `orb_mngr.gd` has match statement for scoring
4. **Tight Coupling**: Orbs directly reference `Constants`, `Enums`, event classes
5. **Inconsistent Naming**: `half_solid_orb` uses snake_case in scene but scripts vary

### Extension Pain Points

Adding a new orb type currently requires:
1. Creating new orb script (copy-paste from existing)
2. Creating new orb scene
3. Adding to generic_orb.tscn as child
4. Modifying GenericOrb.converge_orb() with new case
5. Adding new enum to OrbType
6. Adding lifespan constant to Constants.gd
7. Adding score constant to Constants.gd
8. Adding score case to orb_mngr.gd

### Recommended Refactor Direction

**Pattern: Strategy/Template with Composition**

```gdscript
# Base orb class with common behavior
class_name OrbBase
extends Node2D

var props: OrbDefinition  # Data-driven properties
var lifespan: float
var score_value: int

func collect():
    OrbCollectedEvent.invoke(props)
    SoundPlayEvent.invoke(...)
    queue_free()

# Specific behaviors as composition
class_name OrbBehavior
func on_collect() -> void: pass
func on_spawn() -> void: pass
func on_tick(delta: float) -> void: pass
```

**Data-driven OrbDefinition resource:**
```gdscript
class_name OrbDefinition extends Resource
@export var type: Enums.OrbType
@export var lifespan: float
@export var score_value: int
@export var scene: PackedScene
@export var behavior_script: GDScript  # Optional custom behavior
```
