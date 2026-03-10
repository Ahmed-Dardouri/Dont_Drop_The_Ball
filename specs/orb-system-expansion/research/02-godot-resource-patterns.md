# Research: Godot Resource & Data-Driven Patterns

## Custom Resources in Godot 4

Resources are data containers that can be saved/loaded independently. They're ideal for:
- Item definitions
- Character stats
- Level configurations
- **Orb configurations**

## Basic Custom Resource Pattern

```gdscript
# orb_data.gd
class_name OrbData extends Resource

@export var display_name: String = "Orb"
@export var texture: Texture2D
@export var base_score: int = 1
@export var lifespan: float = 30.0
@export var rarity: Enums.OrbRarity = Enums.OrbRarity.COMMON
@export var behaviors: Array[OrbBehavior] = []
```

## Behavior Resource Pattern

For extensible behaviors, use abstract base + concrete implementations:

```gdscript
# orb_behavior.gd
class_name OrbBehavior extends Resource

## Called when orb is collected. Override in subclasses.
func execute(orb: Node, context: Dictionary) -> void:
    pass

## Called each frame while orb is active (for movement behaviors)
func process(orb: Node, delta: float) -> void:
    pass
```

```gdscript
# behaviors/score_behavior.gd
class_name ScoreBehavior extends OrbBehavior

@export var score_value: int = 1

func execute(_orb: Node, _context: Dictionary) -> void:
    AddScoreEvent.invoke(score_value)
```

```gdscript
# behaviors/timed_modifier_behavior.gd
class_name TimedModifierBehavior extends OrbBehavior

@export var modifier_type: String = "score_multiplier"
@export var modifier_value: float = 2.0
@export var duration: float = 45.0

func execute(_orb: Node, _context: Dictionary) -> void:
    EffectManager.apply_effect(modifier_type, modifier_value, duration)
```

## Resource Inheritance Pattern

Behaviors can inherit from each other:

```gdscript
class_name MovementBehavior extends OrbBehavior

@export var speed: float = 50.0
@export var direction: Vector2 = Vector2.RIGHT

# DrifterMovement extends MovementBehavior with horizontal drift
```

## Godot 4 Export Annotations

```gdscript
@export var simple_value: int                    # Basic export
@export var with_default: String = "default"     # With default
@export_range(0, 100) var percentage: float = 50.0  # Range constraint
@export_enum("A", "B", "C") var choice: String = "A"  # Enum dropdown
@export var behavior: OrbBehavior  # Resource reference
@export var behaviors: Array[OrbBehavior] = []  # Array of resources
```

## Creating Resources in Editor

1. Create script extending Resource
2. Add `class_name` for type registration
3. In FileSystem dock: Right-click → New Resource → Select type
4. Configure in Inspector
5. Save as .tres file

## Loading Resources at Runtime

```gdscript
# Direct load
var orb_data = load("res://data/orbs/blue_orb.tres")

# From array property (set in editor)
@export var orb_pool: Array[OrbData] = []

# Instantiate scene with data
var orb = orb_scene.instantiate()
orb.setup(orb_data)
```

## Best Practices

1. **Single Responsibility** - Each Resource defines one concept
2. **Composability** - Combine behaviors via arrays
3. **No Logic in Resources** - Keep logic in scripts, data in resources
4. **Validation** - Use @export_range, @export_enum for constraints
5. **Defaults** - Provide sensible defaults for all properties

## Anti-Patterns to Avoid

1. **Storing functions in Resources** - Use signals/callbacks instead
2. **Circular dependencies** - Don't reference scenes from Resources
3. **God classes** - Don't make one mega-OrbData with 50 properties
