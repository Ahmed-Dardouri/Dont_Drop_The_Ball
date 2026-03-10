# Implementation Plan: Orb System Expansion

## Progress Checklist

### Phase 1: Core Infrastructure
- [ ] Step 1: Create OrbData resource class
- [ ] Step 2: Create OrbBehavior abstract base class
- [ ] Step 3: Create ScoreBehavior
- [ ] Step 4: Create EffectManager singleton

### Phase 2: Unified Orb Scene
- [ ] Step 5: Create unified Orb scene and script
- [ ] Step 6: Update OrbSpawner for new system
- [ ] Step 7: Migrate existing orbs to resources

### Phase 3: Cleanup & Validation
- [ ] Step 8: Delete old orb scenes and scripts
- [ ] Step 9: Integration test - gameplay parity

### Phase 4: New Orb Behaviors
- [ ] Step 10: Create TimedModifierBehavior
- [ ] Step 11: Create MovementBehavior (Drifter)
- [ ] Step 12: Create ChainReactionBehavior (Burst)
- [ ] Step 13: Create LineClearBehavior

### Phase 5: First Orb Pack
- [ ] Step 14: Create Score Multiplier orb
- [ ] Step 15: Create Slow Fall orb
- [ ] Step 16: Create Double Value orb
- [ ] Step 17: Create Time Slow orb
- [ ] Step 18: Create Combo Starter orb
- [ ] Step 19: Create Drifter orb
- [ ] Step 20: Create Burst orb
- [ ] Step 21: Create Vertical Line orb
- [ ] Step 22: Create Horizontal Line orb

### Phase 6: Final Validation
- [ ] Step 23: Update spawn table with all orbs
- [ ] Step 24: Full test suite and manual verification

---

## Step 1: Create OrbData Resource Class

### Objective
Create the foundational `OrbData` resource class that defines all orb properties.

### Implementation Guidance
Create `scripts/data/orb_data.gd`:

```gdscript
class_name OrbData extends Resource

## Display
@export var display_name: String = "Orb"
@export var texture: Texture2D
@export var scale: Vector2 = Vector2.ONE

## Gameplay
@export var base_score: int = 1
@export var lifespan: float = 30.0
@export var rarity: Enums.OrbRarity = Enums.OrbRarity.COMMON

## Physics
@export var collision_radius: float = 32.0
@export var is_half_solid: bool = false

## Behaviors
@export var behaviors: Array[OrbBehavior] = []

## Spawn
@export var spawn_animation_duration: float = 1.5
```

### Test Requirements
Create `tests/unit/test_orb_data.gd`:
- Test default values
- Test property assignment
- Test serialization (duplicate)

### Integration
No dependencies - this is the foundation.

### Demo
Run `./devscripts/test.sh` and verify test_orb_data passes.

---

## Step 2: Create OrbBehavior Abstract Base Class

### Objective
Create the abstract base class for all orb behaviors.

### Implementation Guidance
Create `scripts/data/behaviors/orb_behavior.gd`:

```gdscript
class_name OrbBehavior extends Resource

@export var behavior_id: String = ""

func execute(_context: Dictionary) -> void:
    pass

func process(_orb: Node, _delta: float) -> void:
    pass

func on_spawn(_orb: Node, _progress: float) -> void:
    pass
```

Create the directory: `scripts/data/behaviors/`

### Test Requirements
Create `tests/unit/test_orb_behavior.gd`:
- Test that base methods can be called without error
- Test that subclass can override methods

### Integration
Depends on Step 1 (OrbData references OrbBehavior array).

### Demo
Run tests, verify base class exists and is instantiable.

---

## Step 3: Create ScoreBehavior

### Objective
Create the first concrete behavior that handles score addition.

### Implementation Guidance
Create `scripts/data/behaviors/score_behavior.gd`:

```gdscript
class_name ScoreBehavior extends OrbBehavior

@export var score_value: int = 1

func _init():
    behavior_id = "score"

func execute(context: Dictionary) -> void:
    var final_score = score_value

    # Apply score multiplier
    if EffectManager.has_effect("score_multiplier"):
        var multiplier = EffectManager.get_effect_value("score_multiplier")
        final_score = int(final_score * multiplier)

    # Apply combo
    if EffectManager.has_effect("combo_chain"):
        var combo = EffectManager.get_effect_value("combo_chain")
        final_score = int(final_score * (1.0 + combo * 0.5))

    # Apply double value (one-time)
    if EffectManager.has_effect("double_value"):
        final_score *= 2
        EffectManager.remove_effect("double_value")

    AddScoreEvent.invoke(final_score)
```

### Test Requirements
Create `tests/unit/test_score_behavior.gd`:
- Test base score calculation
- Test with score_multiplier effect
- Test with combo_chain effect
- Test with double_value effect

### Integration
Depends on EffectManager (Step 4) - but can mock for initial tests.

### Demo
Create a test scene that:
1. Creates an OrbData with ScoreBehavior
2. Simulates collection
3. Verifies AddScoreEvent fires with correct value

---

## Step 4: Create EffectManager Singleton

### Objective
Create the central effect tracking system.

### Implementation Guidance
Create `scripts/effect_manager.gd`:

```gdscript
class_name EffectManager extends Node

signal effect_applied(effect_id: String, value: Variant)
signal effect_removed(effect_id: String)
signal effects_changed()

var _active_effects: Dictionary = {}

class ActiveEffect:
    var effect_id: String
    var value: Variant
    var remaining_duration: float
    var stack_count: int = 1
    var source: Node

    func _init(id: String, val: Variant, dur: float, src: Node):
        effect_id = id
        value = val
        remaining_duration = dur
        source = src

func _ready() -> void:
    Events.add_listener(GameOverEvent, _on_game_over)

func _process(delta: float) -> void:
    var expired: Array[String] = []
    for effect_id in _active_effects.keys():
        var effect: ActiveEffect = _active_effects[effect_id]
        if effect.remaining_duration > 0:
            effect.remaining_duration -= delta
            if effect.remaining_duration <= 0:
                expired.append(effect_id)
    for effect_id in expired:
        remove_effect(effect_id)

func apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null) -> void:
    if _active_effects.has(effect_id):
        var existing: ActiveEffect = _active_effects[effect_id]
        existing.stack_count += 1
        existing.value = _calculate_stacked_value(existing, value)
        existing.remaining_duration = duration
    else:
        _active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)

    effect_applied.emit(effect_id, value)
    effects_changed.emit()
    _apply_global_effects()

func remove_effect(effect_id: String) -> void:
    if _active_effects.erase(effect_id):
        effect_removed.emit(effect_id)
        effects_changed.emit()
        _apply_global_effects()

func has_effect(effect_id: String) -> bool:
    return _active_effects.has(effect_id)

func get_effect_value(effect_id: String) -> Variant:
    if _active_effects.has(effect_id):
        return _active_effects[effect_id].value
    return null

func get_stack_count(effect_id: String) -> int:
    if _active_effects.has(effect_id):
        return _active_effects[effect_id].stack_count
    return 0

func clear_all_effects() -> void:
    _active_effects.clear()
    effects_changed.emit()
    _apply_global_effects()

func _calculate_stacked_value(existing: ActiveEffect, new_value: Variant) -> Variant:
    match existing.effect_id:
        "score_multiplier": return min(existing.value * new_value, 10.0)
        "slow_fall": return max(existing.value * new_value, 0.1)
        "time_slow": return max(existing.value * new_value, 0.25)
        "combo_chain": return existing.value + 1
        _: return new_value

func _apply_global_effects() -> void:
    if has_effect("time_slow"):
        Engine.time_scale = get_effect_value("time_slow")
    else:
        Engine.time_scale = 1.0

func _on_game_over(_event: GameOverEvent) -> void:
    clear_all_effects()
    Engine.time_scale = 1.0
```

**Register as autoload** in `project.godot`:
```
[autoload]
EffectManager="*res://scripts/effect_manager.gd"
```

### Test Requirements
Create `tests/unit/test_effect_manager.gd`:
- Test apply_effect creates effect
- Test has_effect returns correct bool
- Test get_effect_value returns correct value
- Test stacking behavior for each effect type
- Test effect expiration
- Test clear_all_effects
- Test time_slow updates Engine.time_scale

### Integration
Independent - will be used by behaviors and orb.

### Demo
Run test suite, manually verify in scene:
1. Call `EffectManager.apply_effect("score_multiplier", 2.0, 10.0)`
2. Verify `EffectManager.has_effect("score_multiplier") == true`
3. Wait 11 seconds, verify effect expired

---

## Step 5: Create Unified Orb Scene and Script

### Objective
Create the single Orb scene that replaces all existing orb types.

### Implementation Guidance
Create `scenes/orb.tscn`:
```
Orb (Node2D)
├── Sprite2D
├── Area2D
│   └── CollisionShape2D (CircleShape2D)
├── StaticBody2D (for half-solid, initially hidden)
│   └── CollisionPolygon2D
└── Timer
```

Create `scripts/orb.gd`:

```gdscript
class_name Orb extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var static_collision: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var timer: Timer = $Timer

var orb_data: OrbData
var _spawn_progress: float = 0.0
var _is_spawning: bool = true

signal collected

func setup(data: OrbData) -> void:
    orb_data = data
    _apply_data()

func _apply_data() -> void:
    if orb_data == null:
        return

    sprite.texture = orb_data.texture
    sprite.scale = orb_data.scale

    var circle = CircleShape2D.new()
    circle.radius = orb_data.collision_radius
    collision.shape = circle

    static_body.visible = orb_data.is_half_solid
    if orb_data.is_half_solid:
        # Create semi-circle collision polygon
        _create_half_solid_collision()

    timer.wait_time = orb_data.lifespan
    timer.start()

func _create_half_solid_collision() -> void:
    var points: PackedVector2Array = []
    var segments := 12
    for i in range(segments + 1):
        var angle = PI * i / segments - PI / 2
        var point = Vector2(cos(angle), sin(angle)) * orb_data.collision_radius
        points.append(point)
    points.append(Vector2(0, orb_data.collision_radius))
    static_collision.polygon = points
    static_body.add_to_group("half_solid")

func _ready() -> void:
    add_to_group("orbs")
    add_to_group("orb")

    area.body_entered.connect(_on_body_entered)
    timer.timeout.connect(_on_lifespan_timeout)
    static_body.body_entered.connect(_on_static_body_entered)

    _is_spawning = true
    sprite.modulate.a = 0.0
    collision.disabled = true

func _process(delta: float) -> void:
    if _is_spawning:
        _spawn_progress += delta / (orb_data.spawn_animation_duration if orb_data else 1.5)
        if _spawn_progress >= 1.0:
            _spawn_progress = 1.0
            _is_spawning = false
            collision.disabled = false

        sprite.modulate.a = _spawn_progress * 0.75

        for behavior in (orb_data.behaviors if orb_data else []):
            behavior.on_spawn(self, _spawn_progress)
    else:
        for behavior in (orb_data.behaviors if orb_data else []):
            behavior.process(self, delta)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("ball"):
        collect()

func _on_static_body_entered(body: Node2D) -> void:
    if body.is_in_group("ball") and body is RigidBody2D:
        body.linear_velocity = body.linear_velocity / 3.0

func collect() -> void:
    if orb_data == null:
        queue_free()
        return

    OrbCollectedEvent.invoke(orb_data)

    var context = {"orb": self, "orb_data": orb_data, "collector": _get_ball()}
    for behavior in orb_data.behaviors:
        behavior.execute(context)

    SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)

    collected.emit()
    queue_free()

func _on_lifespan_timeout() -> void:
    queue_free()

func _get_ball() -> Node:
    var balls = get_tree().get_nodes_in_group("ball")
    return balls[0] if balls.size() > 0 else null
```

### Test Requirements
Create `tests/unit/test_orb.gd`:
- Test setup() applies orb_data correctly
- Test spawn animation opacity progression
- Test collect() fires OrbCollectedEvent
- Test collect() executes behaviors
- Test lifespan timeout queues free
- Test half_solid collision reduces ball velocity

### Integration
Depends on Steps 1-4 (OrbData, OrbBehavior, ScoreBehavior, EffectManager).

### Demo
1. Create test scene with Orb
2. Create an OrbData resource with ScoreBehavior
3. Run scene, verify orb appears with fade-in
4. Simulate ball collision, verify score added

---

## Step 6: Update OrbSpawner for New System

### Objective
Update OrbSpawner to use the new unified orb system with weighted spawning.

### Implementation Guidance
Create `scripts/data/orb_spawn_entry.gd`:

```gdscript
class_name OrbSpawnEntry extends Resource

@export var orb_data: OrbData
@export var weight: int = 100
```

Update `scripts/orb_spawner.gd`:

```gdscript
class_name OrbSpawner extends Node2D

@export var orb_scene: PackedScene
@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10
@export var spawn_table: Array[OrbSpawnEntry] = []

var _timer: Timer

func _ready() -> void:
    _timer = Timer.new()
    _timer.wait_time = spawn_interval
    _timer.autostart = true
    _timer.timeout.connect(_on_timeout)
    add_child(_timer)

func _on_timeout() -> void:
    if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
        return

    var orb_data = _select_orb_data()
    if orb_data == null:
        return

    var orb = orb_scene.instantiate()
    orb.setup(orb_data)

    var pos = Vector2(
        randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
        randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
    )
    orb.global_position = pos
    add_child(orb)

func _select_orb_data() -> OrbData:
    if spawn_table.is_empty():
        return null

    var total_weight := 0
    for entry in spawn_table:
        total_weight += entry.weight

    var roll := randi() % total_weight
    var cumulative := 0

    for entry in spawn_table:
        cumulative += entry.weight
        if roll < cumulative:
            return entry.orb_data

    return spawn_table[0].orb_data
```

### Test Requirements
Create `tests/unit/test_orb_spawner.gd`:
- Test _select_orb_data with single entry
- Test _select_orb_data respects weights
- Test max_orbs limit is enforced
- Test orb spawns at position in zone

### Integration
Depends on Step 5 (Orb scene).

### Demo
1. Configure OrbSpawner with spawn_table containing test entries
2. Run scene, verify orbs spawn with correct distribution

---

## Step 7: Migrate Existing Orbs to Resources

### Objective
Create OrbData resources for Blue, Red, and Half-Solid orbs.

### Implementation Guidance
Add to `scripts/utils/enums.gd`:

```gdscript
enum OrbRarity {
    COMMON,
    UNCOMMON,
    RARE
}
```

Create resource files:

**`resources/orbs/blue_orb.tres`:**
```
[gd_resource type="OrbData" load_steps=3 format=3]

[ext_resource type="Texture2D" path="res://assets/orbs/blue_orb.png" id="1"]
[ext_resource type="ScoreBehavior" path="res://resources/behaviors/score_2.tres" id="2"]

[resource]
display_name = "Blue Orb"
texture = ExtResource("1")
scale = Vector2(1, 1)
base_score = 2
lifespan = 30.0
rarity = 0  # COMMON
collision_radius = 32.0
is_half_solid = false
behaviors = [ExtResource("2")]
spawn_animation_duration = 1.5
```

**`resources/orbs/red_orb.tres`:**
Similar, with base_score = 3

**`resources/orbs/half_solid_orb.tres`:**
With is_half_solid = true, base_score = 8, lifespan = 18.0, rarity = RARE

**Create behavior resources:**
- `resources/behaviors/score_2.tres` (ScoreBehavior with score_value=2)
- `resources/behaviors/score_3.tres` (ScoreBehavior with score_value=3)
- `resources/behaviors/score_8.tres` (ScoreBehavior with score_value=8)

### Test Requirements
- Test each resource loads correctly
- Test score values match expected (2, 3, 8)
- Test half_solid flag is set

### Integration
Depends on Steps 1-6.

### Demo
1. Configure OrbSpawner with the three existing orb types
2. Run game, verify orbs spawn and score correctly
3. Verify half-solid orb bounces ball and reduces velocity

---

## Step 8: Delete Old Orb Scenes and Scripts

### Objective
Remove deprecated orb files now that unified system works.

### Files to Delete
```
scripts/generic_orb.gd
scripts/blue_orb.gd
scripts/red_orb.gd
scripts/half_solid_orb.gd
scripts/orb_mngr.gd
scripts/utils/orb_properties.gd
scenes/generic_orb.tscn
scenes/blue_orb.tscn
scenes/red_orb.tscn
scenes/half_solid_orb.tscn
scenes/orb_mngr.tscn
```

### Test Requirements
- Run `./devscripts/test.sh` - all tests must pass
- Run smoke test - game must boot

### Demo
1. Run full game from main menu
2. Play a complete session
3. Verify no errors in console

---

## Step 9: Integration Test - Gameplay Parity

### Objective
Verify the migrated system plays identically to before.

### Implementation Guidance
Create `tests/integration/test_orb_parity.gd`:

```gdscript
extends GutTest

func test_blue_orb_scores_2():
    var score_before = ScoreManager.get_score()
    # Collect blue orb
    # Assert score increased by 2

func test_red_orb_scores_3():
    # Similar

func test_half_solid_reduces_ball_velocity():
    # Spawn ball with velocity
    # Collide with half-solid orb
    # Assert velocity reduced to 1/3

func test_orb_lifespan():
    # Spawn orb
    # Wait for lifespan
    # Assert orb freed
```

### Test Requirements
All integration tests pass.

### Demo
Play a full game session comparing to pre-migration behavior.

---

## Step 10: Create TimedModifierBehavior

### Objective
Create behavior for applying timed effects (score multiplier, slow fall, etc.).

### Implementation Guidance
Create `scripts/data/behaviors/timed_modifier_behavior.gd`:

```gdscript
class_name TimedModifierBehavior extends OrbBehavior

@export var effect_id: String = ""
@export var effect_value: float = 1.0
@export var duration: float = 45.0

func _init():
    behavior_id = "timed_modifier"

func execute(_context: Dictionary) -> void:
    if effect_id.is_empty():
        return
    EffectManager.apply_effect(effect_id, effect_value, duration)
```

### Test Requirements
Create `tests/unit/test_timed_modifier_behavior.gd`:
- Test effect is applied to EffectManager
- Test effect has correct value
- Test effect expires after duration

### Integration
Uses EffectManager from Step 4.

### Demo
1. Create orb with TimedModifierBehavior (effect_id="score_multiplier", value=2.0)
2. Collect orb
3. Verify EffectManager.has_effect("score_multiplier") == true
4. Collect another orb, verify score is doubled

---

## Step 11: Create MovementBehavior

### Objective
Create behavior for orbs that move (Drifter).

### Implementation Guidance
Create `scripts/data/behaviors/movement_behavior.gd`:

```gdscript
class_name MovementBehavior extends OrbBehavior

@export var speed: float = 50.0
@export var direction: Vector2 = Vector2.RIGHT
@export var oscillate: bool = true
@export var oscillate_distance: float = 100.0

var _start_position: Vector2
var _oscillate_direction: int = 1

func _init():
    behavior_id = "movement"

func on_spawn(orb: Node, progress: float) -> void:
    if progress >= 1.0:
        _start_position = orb.global_position

func process(orb: Node, delta: float) -> void:
    if _start_position == Vector2.ZERO:
        _start_position = orb.global_position
        return

    var movement = direction * speed * delta * _oscillate_direction
    orb.global_position += movement

    if oscillate:
        var distance_from_start = abs(orb.global_position.x - _start_position.x)
        if distance_from_start >= oscillate_distance:
            _oscillate_direction *= -1
```

### Test Requirements
Create `tests/unit/test_movement_behavior.gd`:
- Test orb moves in direction
- Test oscillation reverses at distance
- Test movement only after spawn complete

### Integration
Used by Orb's _process loop.

### Demo
1. Create orb with MovementBehavior
2. Watch orb drift left/right

---

## Step 12: Create ChainReactionBehavior

### Objective
Create behavior for burst orb that collects nearby orbs.

### Implementation Guidance
Create `scripts/data/behaviors/chain_reaction_behavior.gd`:

```gdscript
class_name ChainReactionBehavior extends OrbBehavior

@export var radius: float = 150.0

func _init():
    behavior_id = "chain_reaction"

func execute(context: Dictionary) -> void:
    var orb = context.get("orb")
    if orb == null:
        return

    var nearby_orbs = _get_orbs_in_radius(orb.global_position, radius)
    for nearby in nearby_orbs:
        if nearby != orb and nearby.has_method("collect"):
            nearby.collect()

func _get_orbs_in_radius(center: Vector2, r: float) -> Array[Node]:
    var results: Array[Node] = []
    var all_orbs = get_tree().get_nodes_in_group("orbs")

    for orb in all_orbs:
        if center.distance_to(orb.global_position) <= r:
            results.append(orb)

    return results
```

### Test Requirements
Create `tests/unit/test_chain_reaction_behavior.gd`:
- Test finds orbs within radius
- Test excludes self
- Test excludes orbs outside radius

### Integration
Uses orb group system.

### Demo
1. Spawn 5 orbs in cluster
2. Collect burst orb
3. Verify all nearby orbs collected

---

## Step 13: Create LineClearBehavior

### Objective
Create behavior for vertical/horizontal line collection.

### Implementation Guidance
Create `scripts/data/behaviors/line_clear_behavior.gd`:

```gdscript
class_name LineClearBehavior extends OrbBehavior

enum LineDirection { VERTICAL, HORIZONTAL }

@export var direction: LineDirection = LineDirection.VERTICAL
@export var tolerance: float = 20.0

func _init():
    behavior_id = "line_clear"

func execute(context: Dictionary) -> void:
    var orb = context.get("orb")
    if orb == null:
        return

    var orbs_to_collect: Array[Node] = []

    if direction == LineDirection.VERTICAL:
        orbs_to_collect = _get_orbs_in_vertical_line(orb.global_position.x)
    else:
        orbs_to_collect = _get_orbs_in_horizontal_line(orb.global_position.y)

    _spawn_line_visual_effect(orb)
    _delayed_collect(orbs_to_collect, orb)

func _get_orbs_in_vertical_line(x_pos: float) -> Array[Node]:
    var results: Array[Node] = []
    for orb in get_tree().get_nodes_in_group("orbs"):
        if abs(orb.global_position.x - x_pos) <= tolerance:
            results.append(orb)
    return results

func _get_orbs_in_horizontal_line(y_pos: float) -> Array[Node]:
    var results: Array[Node] = []
    for orb in get_tree().get_nodes_in_group("orbs"):
        if abs(orb.global_position.y - y_pos) <= tolerance:
            results.append(orb)
    return results

func _spawn_line_visual_effect(source_orb: Node) -> void:
    var line = Sprite2D.new()
    var img = Image.create(8, 2000, false, Image.FORMAT_RGBA8)
    img.fill(Color.YELLOW)
    line.texture = ImageTexture.create_from_image(img)
    line.modulate = Color(1, 1, 0, 0.5)
    line.z_index = 10
    line.global_position = source_orb.global_position

    if direction == LineDirection.HORIZONTAL:
        line.rotation = PI / 2

    get_tree().current_scene.add_child(line)

    var tween = source_orb.create_tween()
    tween.tween_property(line, "modulate:a", 0.0, 0.3)
    tween.tween_callback(line.queue_free)

func _delayed_collect(orbs: Array[Node], source_orb: Node) -> void:
    for target_orb in orbs:
        if target_orb != source_orb and target_orb.has_method("collect"):
            target_orb.collect()
```

### Test Requirements
Create `tests/unit/test_line_clear_behavior.gd`:
- Test vertical line finds orbs with same X
- Test horizontal line finds orbs with same Y
- Test tolerance is respected
- Test self is excluded

### Integration
Uses orb group system.

### Demo
1. Spawn orbs in vertical line
2. Collect vertical line orb
3. Verify all orbs in column collected
4. Repeat for horizontal

---

## Step 14: Create Score Multiplier Orb

### Objective
Create the Score Multiplier orb resource.

### Implementation Guidance
Create `resources/orbs/score_multiplier.tres`:
- display_name = "Score Multiplier"
- texture = (placeholder or distinct color)
- base_score = 3
- lifespan = 30.0
- rarity = UNCOMMON
- behaviors = [ScoreBehavior(3), TimedModifierBehavior(effect_id="score_multiplier", value=2.0, duration=45.0)]

### Test Requirements
- Test collecting orb applies score_multiplier effect
- Test collecting another orb while effect active doubles the multiplier (2x * 2x = 4x)
- Test effect expires after 45s

### Demo
1. Collect Score Multiplier orb
2. Collect Blue orb, verify score = 2 * 2 = 4
3. Collect another Score Multiplier, verify multiplier = 4x

---

## Step 16: Create Slow Fall Orb

### Objective
Create the Slow Fall orb that reduces ball fall speed.

### Implementation Guidance
Update `scripts/ball.gd` to poll EffectManager:

```gdscript
var base_fall_speed := 1500.0

func _physics_process(delta: float) -> void:
    _apply_effect_modifiers()
    clamp_max_speed()
    clamp_fall_speed()
    apply_air_friction()

func _apply_effect_modifiers() -> void:
    if EffectManager.has_effect("slow_fall"):
        var modifier = EffectManager.get_effect_value("slow_fall")
        fall_speed = base_fall_speed * modifier
    else:
        fall_speed = base_fall_speed

func load_constants():
    max_speed = Constants.ball_max_speed
    base_fall_speed = Constants.ball_fall_speed
    fall_speed = base_fall_speed
    air_friction = Constants.ball_air_friction
```

Create `resources/orbs/slow_fall.tres`:
- behaviors = [ScoreBehavior(2), TimedModifierBehavior(effect_id="slow_fall", value=0.5, duration=45.0)]

### Test Requirements
- Test ball fall_speed is modified when effect active
- Test stacking reduces fall_speed further
- Test effect clears on game over

### Demo
1. Collect Slow Fall orb
2. Observe ball falls noticeably slower
3. Collect another Slow Fall, observe even slower fall

---

## Step 17: Create Double Value Orb

### Objective
Create orb that makes next orb worth 2x.

### Implementation Guidance
Create `resources/orbs/double_value.tres`:
- behaviors = [ScoreBehavior(1), TimedModifierBehavior(effect_id="double_value", value=true, duration=-1)]

Note: duration=-1 means permanent until used (handled in ScoreBehavior).

### Test Requirements
- Test collecting orb applies double_value effect
- Test collecting another orb consumes effect and doubles score
- Test effect only applies once

### Demo
1. Collect Double Value orb (adds 1 score)
2. Collect Blue orb, verify score = 2 * 2 = 4 (not 2)
3. Collect another Blue orb, verify score = 2 (effect consumed)

---

## Step 18: Create Time Slow Orb

### Objective
Create orb that slows game time.

### Implementation Guidance
Create `resources/orbs/time_slow.tres`:
- behaviors = [ScoreBehavior(5), TimedModifierBehavior(effect_id="time_slow", value=0.5, duration=10.0)]

### Test Requirements
- Test Engine.time_scale is set to 0.5
- Test stacking further reduces time_scale (capped at 0.25)
- Test time_scale resets to 1.0 when effect expires

### Demo
1. Collect Time Slow orb
2. Observe game runs at half speed
3. Collect another, observe quarter speed

---

## Step 19: Create Combo Starter Orb

### Objective
Create orb that starts a combo chain multiplier.

### Implementation Guidance
Create `resources/orbs/combo_starter.tres`:
- behaviors = [ScoreBehavior(3), TimedModifierBehavior(effect_id="combo_chain", value=0, duration=10.0)]

The combo_chain value is the count of orbs collected during the window. ScoreBehavior adds `1.0 + combo * 0.5` multiplier.

### Test Requirements
- Test combo_chain starts at 0
- Test each orb collected increments combo
- Test score multiplier increases with combo
- Test combo expires after 10s

### Demo
1. Collect Combo Starter orb
2. Quickly collect 3 more orbs
3. Verify scores: 3, then 3*1.5=4.5, 3*2=6, 3*2.5=7.5

---

## Step 20: Create Drifter Orb

### Objective
Create orb that moves horizontally.

### Implementation Guidance
Create `resources/orbs/drifter.tres`:
- behaviors = [ScoreBehavior(2), MovementBehavior(speed=50, oscillate=true, oscillate_distance=100)]

### Test Requirements
- Test orb moves after spawn
- Test orb oscillates at boundaries

### Demo
1. Watch Drifter orb spawn
2. Observe it drifts left/right

---

## Step 21: Create Burst Orb

### Objective
Create orb that collects nearby orbs in radius.

### Implementation Guidance
Create `resources/orbs/burst.tres`:
- behaviors = [ScoreBehavior(8), ChainReactionBehavior(radius=150.0)]

### Test Requirements
- Test burst collects all orbs in radius
- Test burst does not collect orbs outside radius
- Test all collected orbs score correctly

### Demo
1. Spawn cluster of orbs
2. Collect Burst orb
3. Verify all nearby orbs collected

---

## Step 22: Create Vertical Line Orb

### Objective
Create orb that collects vertical line of orbs.

### Implementation Guidance
Create `resources/orbs/vertical_line.tres`:
- behaviors = [ScoreBehavior(5), LineClearBehavior(direction=VERTICAL, tolerance=20.0)]

### Test Requirements
- Test collects orbs with same X position
- Test tolerance is respected
- Test visual line effect appears

### Demo
1. Spawn orbs in vertical column
2. Collect Vertical Line orb
3. Verify all orbs in column collected with line flash

---

## Step 23: Create Horizontal Line Orb

### Objective
Create orb that collects horizontal line of orbs.

### Implementation Guidance
Create `resources/orbs/horizontal_line.tres`:
- behaviors = [ScoreBehavior(5), LineClearBehavior(direction=HORIZONTAL, tolerance=20.0)]

### Test Requirements
- Test collects orbs with same Y position
- Test tolerance is respected
- Test visual line effect appears

### Demo
1. Spawn orbs in horizontal row
2. Collect Horizontal Line orb
3. Verify all orbs in row collected with line flash

---

## Step 24: Update Spawn Table with All Orbs

### Objective
Configure the final spawn table with all 12 orb types.

### Implementation Guidance
Update OrbSpawner's spawn_table in the scene or create a default configuration:

| Orb | Rarity | Weight |
|-----|--------|--------|
| Blue | COMMON | 100 |
| Red | COMMON | 80 |
| Half-Solid | RARE | 20 |
| Score Multiplier | UNCOMMON | 40 |
| Slow Fall | UNCOMMON | 40 |
| Double Value | UNCOMMON | 40 |
| Time Slow | RARE | 20 |
| Combo Starter | RARE | 20 |
| Drifter | UNCOMMON | 40 |
| Burst | RARE | 20 |
| Vertical Line | RARE | 20 |
| Horizontal Line | RARE | 20 |

### Test Requirements
- Test spawn distribution matches expected ratios
- Test all orb types can spawn

### Demo
Play for several minutes, verify all orb types appear.

---

## Step 25: Final Validation

### Objective
Complete test suite and manual verification.

### Test Requirements
Run full test suite:
```bash
./devscripts/import.sh
./devscripts/smoke_test.sh
./devscripts/test.sh
```

### Manual Verification Checklist
- [ ] Game boots without errors
- [ ] All 12 orb types can spawn
- [ ] Score tracking works correctly
- [ ] Effect stacking works as designed
- [ ] Effects expire after duration
- [ ] Effects clear on game over
- [ ] Time slow affects game speed
- [ ] Slow fall affects ball physics
- [ ] Line orbs clear correctly
- [ ] Burst orb clears radius
- [ ] Drifter orb moves
- [ ] Combo chain multiplies score
- [ ] Double value works one-time
- [ ] No console errors during play

### Demo
Play a complete game session with all features working.

---

## Summary

**Total Steps:** 25
**Estimated Effort:**
- Phase 1 (Steps 1-4): Core infrastructure
- Phase 2 (Steps 5-7): Unified orb system
- Phase 3 (Steps 8-9): Migration and cleanup
- Phase 4 (Steps 10-13): New behaviors
- Phase 5 (Steps 14-23): New orb types
- Phase 6 (Steps 24-25): Final validation

**Key Milestones:**
1. After Step 4: EffectManager testable
2. After Step 9: Migration complete, gameplay parity
3. After Step 25: Full orb pack implemented
