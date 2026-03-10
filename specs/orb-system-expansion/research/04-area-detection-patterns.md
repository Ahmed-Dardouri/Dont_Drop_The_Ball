# Research: Area Detection Patterns

## Burst Orb (Radius Detection)

### Method 1: PhysicsDirectSpaceState2D (Recommended)

Most efficient for one-time queries without adding nodes:

```gdscript
func get_orbs_in_radius(center: Vector2, radius: float) -> Array[Node]:
    var space_state = get_world_2d().direct_space_state
    var circle_shape = CircleShape2D.new()
    circle_shape.radius = radius

    var query = PhysicsShapeQueryParameters2D.new()
    query.transform = Transform2D(0, center)
    query.shape_rid = circle_shape.get_rid()
    query.collision_mask = 0b10000  # Orbs layer
    query.exclude = [self]  # Don't include self

    var results = space_state.intersect_shape(query, 1024)
    var orbs: Array[Node] = []

    for result in results:
        if result.collider and result.collider.is_in_group("orbs"):
            orbs.append(result.collider)

    return orbs
```

### Method 2: Area2D with Monitoring

Add a temporary Area2D, but requires more setup:

```gdscript
func get_orbs_in_radius_via_area(center: Vector2, radius: float) -> Array[Node]:
    var area = Area2D.new()
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = radius
    collision.shape = circle
    area.add_child(collision)
    area.global_position = center
    area.collision_layer = 0
    area.collision_mask = 0b10000  # Orbs layer
    get_tree().current_scene.add_child(area)

    # Force physics update
    await get_tree().physics_frame

    var orbs = area.get_overlapping_bodies()
    area.queue_free()
    return orbs
```

**Recommendation:** Use PhysicsDirectSpaceState2D for burst orb (no scene modification needed).

## Line Orbs (Vertical/Horizontal)

### Approach: Iterate orbs in group

Simple and reliable for small orb counts:

```gdscript
func get_orbs_in_vertical_line(x_pos: float, tolerance: float = 20.0) -> Array[Node]:
    var orbs: Array[Node] = []
    var all_orbs = get_tree().get_nodes_in_group("orbs")

    for orb in all_orbs:
        if abs(orb.global_position.x - x_pos) <= tolerance:
            orbs.append(orb)

    return orbs

func get_orbs_in_horizontal_line(y_pos: float, tolerance: float = 20.0) -> Array[Node]:
    var orbs: Array[Node] = []
    var all_orbs = get_tree().get_nodes_in_group("orbs")

    for orb in all_orbs:
        if abs(orb.global_position.y - y_pos) <= tolerance:
            orbs.append(orb)

    return orbs
```

### Visual Line Effect

Simple mono-color sprite that flashes:

```gdscript
# In the behavior or orb script
func spawn_line_effect(is_vertical: bool, position: float, length: float) -> void:
    var line_sprite = Sprite2D.new()
    var line_texture = _create_line_texture(is_vertical, length)

    line_sprite.texture = line_texture
    line_sprite.modulate = Color(1, 1, 0, 0.7)  # Yellow, semi-transparent
    line_sprite.z_index = 10  # Above orbs

    if is_vertical:
        line_sprite.global_position = Vector2(position, get_viewport_rect().size.y / 2)
        line_sprite.scale = Vector2(1, get_viewport_rect().size.y / length)
    else:
        line_sprite.global_position = Vector2(get_viewport_rect().size.x / 2, position)
        line_sprite.scale = Vector2(get_viewport_rect().size.x / length, 1)

    get_tree().current_scene.add_child(line_sprite)

    # Flash and fade
    var tween = create_tween()
    tween.tween_property(line_sprite, "modulate:a", 0.0, 0.5)
    tween.tween_callback(line_sprite.queue_free)
```

### Creating Simple Line Texture

```gdscript
func _create_line_texture(is_vertical: bool, length: float) -> ImageTexture:
    var width = 8 if is_vertical else int(length)
    var height = int(length) if is_vertical else 8

    var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
    image.fill(Color.WHITE)

    var texture = ImageTexture.create_from_image(image)
    return texture
```

## Chain Reaction Implementation

```gdscript
class_name BurstBehavior extends OrbBehavior

@export var radius: float = 150.0

func execute(orb: Node, _context: Dictionary) -> void:
    # First, score this orb normally
    var score_behavior = orb.orb_data.get_behavior("score")
    if score_behavior:
        score_behavior.execute(orb, {})

    # Then find and collect nearby orbs
    var nearby_orbs = _get_orbs_in_radius(orb.global_position, radius)

    for nearby_orb in nearby_orbs:
        if nearby_orb != orb and nearby_orb.has_method("collect"):
            nearby_orb.collect()  # Trigger collection without another collision

    # Visual effect
    _spawn_burst_effect(orb.global_position, radius)
```

## Performance Considerations

1. **Orb Count** - With max_orbs=10, iteration is trivial
2. **Physics Queries** - DirectSpaceState2D is efficient for radius checks
3. **Frame Delay** - Avoid awaiting for line detection (instant is fine)
4. **Cleanup** - Always queue_free visual effects

## Collision Layers

Recommend setting up a dedicated collision layer for orbs:

```gdscript
# In project settings or code:
const ORB_LAYER = 5  # Layer 5 (bit 16, value 32)

# Or configure in Project Settings > 2D Physics:
# Layer 5: "orbs"
```

Then in orb setup:
```gdscript
func setup_collision():
    collision_layer = ORB_LAYER
    collision_mask = 0  # Orbs don't need to detect collisions
```
