class_name ExplosionCircle extends Area2D
## Visual explosion effect that collects orbs as it expands.
## Uses area detection since orbs use Area2D for collision.

#region Configuration

## How long the explosion lasts in seconds
@export var duration: float = 0.3

#endregion

#region State

var _radius: float = 150.0
var _time_elapsed: float = 0.0
var _visual_sprite: Sprite2D = null
var _collision_shape: CollisionShape2D = null
var _orbs_collected: Array[Node] = []

#endregion


func _ready() -> void:
	# Set up collision to detect orb areas
	collision_layer = 0
	collision_mask = 2  # Detect orbs' Area2D on layer 2

	# Create collision shape (starts small, expands)
	_collision_shape = CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = 1.0
	_collision_shape.shape = circle_shape
	add_child(_collision_shape)

	# Connect area detection signal (orbs use Area2D, not physics bodies)
	area_entered.connect(_on_area_entered)

	# Set visual alpha
	if _visual_sprite != null:
		_visual_sprite.modulate.a = 0.8


func _process(delta: float) -> void:
	_time_elapsed += delta
	var progress: float = min(_time_elapsed / duration, 1.0)

	# Expand the collision radius over time
	var current_radius: float = _radius * progress
	if _collision_shape != null and _collision_shape.shape is CircleShape2D:
		(_collision_shape.shape as CircleShape2D).radius = max(current_radius, 1.0)

	# Expand visual scale
	scale = Vector2(progress, progress)

	# Fade out
	if _visual_sprite != null:
		_visual_sprite.modulate.a = 0.8 * (1.0 - progress * 0.7)

	# Remove when complete
	if _time_elapsed >= duration:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Find the orb node - it's the parent of the DataOrbArea
	var orb_node: Node = area.get_parent()
	if orb_node == null:
		return

	if orb_node.is_in_group("orbs") and not orb_node in _orbs_collected:
		_orbs_collected.append(orb_node)
		# Trigger full collection (behaviors, events, chain reactions)
		if orb_node.has_method("on_orb_collected"):
			orb_node.on_orb_collected()


## Initializes the explosion with radius and optional texture.
func setup(explosion_radius: float, texture: Texture2D = null) -> void:
	_radius = explosion_radius

	if texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = texture
		# Scale sprite to match radius
		var texture_size: float = max(texture.get_width(), texture.get_height())
		var scale_factor: float = (_radius * 2.0) / texture_size
		_visual_sprite.scale = Vector2(scale_factor, scale_factor)
		add_child(_visual_sprite)
