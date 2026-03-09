# Research: Godot 4 Best Practices for Extensibility

## Recommended Architecture Patterns

### 1. Composition Over Inheritance

**Problem**: Deep inheritance hierarchies become brittle
**Solution**: Use composition with small, focused components

```gdscript
# Instead of: BlueOrb, RedOrb, HalfSolidOrb inheriting from Orb
# Use: Single Orb class with composed behaviors

class_name Orb
extends Area2D

@export var definition: OrbDefinition  # Data
@export var behavior: OrbBehavior       # Logic

# Different behaviors can be swapped
class_name ScoreBehavior extends OrbBehavior
func on_collect(orb: Orb):
    ScoreManager.add_score(orb.definition.score)

class_name BounceBehavior extends OrbBehavior
func on_collision(orb: Orb, body: Node2D):
    body.velocity /= 3
```

### 2. Resource-Based Definitions

**Pattern**: Use `Resource` subclasses for data definitions

```gdscript
# orb_definition.gd
class_name OrbDefinition extends Resource

@export var type: StringName
@export var display_name: String
@export var score_value: int = 1
@export var lifespan_seconds: float = 30.0
@export var scene: PackedScene
@export var behavior: GDScript  # Custom behavior class
@export var sprite: Texture2D
@export var collision_shape: Shape2D
```

**Benefits**:
- Easy to create new types in editor
- Can be saved as .tres files
- Hot-reloadable during development
- Version controllable (text format)

### 3. Singleton/Autoload Pattern

**For Global State Management**:

```gdscript
# game_state.gd (Autoload)
extends Node

signal pause_changed(is_paused: bool)
signal score_changed(new_score: int)

var is_paused: bool = false:
    set(value):
        if value != is_paused:
            is_paused = value
            pause_changed.emit(value)

var score: int = 0:
    set(value):
        var old = score
        score = value
        if old != score:
            score_changed.emit(value)

func reset():
    is_paused = false
    score = 0
```

**Benefits over static variables**:
- Proper signal emission
- Easier to debug
- Clean reset capability
- Testable

### 4. Signal-Based Communication

**Instead of global event bus for everything**:

```gdscript
# Prefer local signals where possible
class_name Orb extends Area2D
signal collected(orb: Orb)

# Consumer connects directly
orb.collected.connect(_on_orb_collected)
```

**Use autoload signals for truly global events**:

```gdscript
# events.gd (Autoload)
extends Node

signal game_started
signal game_over(final_score: int)
signal pause_toggled(is_paused: bool)
```

### 5. Factory Pattern for Object Creation

```gdscript
# orb_factory.gd
class_name OrbFactory

static var _definitions: Dictionary = {}

static func register(definition: OrbDefinition) -> void:
    _definitions[definition.type] = definition

static func create(type: StringName) -> Orb:
    if not _definitions.has(type):
        push_error("Unknown orb type: " + str(type))
        return null

    var def := _definitions[type]
    var orb: Orb = def.scene.instantiate()
    orb.definition = def

    if def.behavior:
        orb.behavior = def.behavior.new()

    return orb
```

### 6. State Machine Pattern

**For Game/Player States**:

```gdscript
# state_machine.gd
class_name StateMachine extends Node

@export var initial_state: NodePath

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_machine = self

    if initial_state:
        current_state = get_node(initial_state)
        current_state.enter()

func change_state(state_name: String) -> void:
    if not states.has(state_name):
        return
    current_state.exit()
    current_state = states[state_name]
    current_state.enter()
```

### 7. Dependency Injection via Exports

**Instead of hardcoding node paths**:

```gdscript
# Bad
@onready var player = $"/root/main/world/player"

# Good
@export var player: Node2D
# Or with type safety
@export var player: PhysicsPlayer
```

### 8. Group-Based Queries

**Instead of name checking**:

```gdscript
# Bad
if body.name == "ball":
    ...

# Good - add to group in editor or code
if body.is_in_group("ball"):
    ...

# Or type checking
if body is Ball:
    ...
```

## Recommended Architecture for This Project

### Proposed Structure

```
scripts/
├── core/                    # Core systems (autoload-ready)
│   ├── game_state.gd        # Global state singleton
│   ├── events.gd            # Global signals
│   └── score_manager.gd     # Scoring logic (pure)
│
├── entities/                # Game entities
│   ├── orb/
│   │   ├── orb.gd           # Base orb class
│   │   ├── orb_definition.gd # Resource for orb data
│   │   └── behaviors/       # Orb behavior components
│   │       ├── score_behavior.gd
│   │       └── bounce_behavior.gd
│   ├── ball.gd              # Ball entity
│   └── player.gd            # Player entity
│
├── systems/                 # Game systems
│   ├── orb_spawner.gd       # Orb spawning
│   └── physics/             # Pure physics logic
│       ├── ball_physics.gd
│       └── player_physics.gd
│
└── utils/
    ├── constants.gd         # Game constants
    └── enums.gd             # Type enumerations
```

### Key Patterns to Implement

1. **OrbDefinition Resource**: Data-driven orb configurations
2. **GameState Singleton**: Replace PauseEvent.state static
3. **Pure Logic Classes**: Extract physics math from nodes
4. **Factory Pattern**: Orb creation via factory
5. **Behavior Components**: Pluggable orb behaviors

## Testing Benefits

These patterns enable:

1. **Unit Tests**: Pure logic classes with no scene dependencies
2. **Mock Injection**: Swap behaviors for testing
3. **State Isolation**: Clean singleton reset between tests
4. **Fast Iteration**: Modify data without code changes
