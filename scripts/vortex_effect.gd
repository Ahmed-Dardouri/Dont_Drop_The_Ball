class_name VortexEffect extends Area2D
## Visual vortex aura that follows the ball and collects orbs in expanded range.
## The sprite rotates independently of the ball's rotation.

#region Configuration

## How long the vortex lasts in seconds
@export var duration: float = 45.0

## Radius of the vortex collection area
@export var vortex_radius: float = 150.0

## Rotation speed of the visual sprite (radians per second)
@export var rotation_speed: float = 2.0

#endregion

#region State

var _time_elapsed: float = 0.0
var _visual_sprite: Sprite2D = null
var _collision_shape: CollisionShape2D = null
var _orbs_collected: Array[Node] = []
var _ball: Node2D = null

#endregion


func _ready() -> void:
	# Set up collision to detect orb areas
	collision_layer = 0
	collision_mask = 2  # Detect orbs' Area2D on layer 2

	# Create collision shape
	_collision_shape = CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = vortex_radius
	_collision_shape.shape = circle_shape
	add_child(_collision_shape)

	# Connect area detection signal
	area_entered.connect(_on_area_entered)

	# Find the ball to follow
	_find_ball()


func _process(delta: float) -> void:
	_time_elapsed += delta

	# Follow the ball
	if _ball != null and is_instance_valid(_ball):
		global_position = _ball.global_position

	# Rotate visual sprite independently
	if _visual_sprite != null:
		_visual_sprite.rotation += rotation_speed * delta

	# Check if effect expired
	if _time_elapsed >= duration:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Find the orb node - it's the parent of the DataOrbArea
	var orb_node: Node = area.get_parent()
	if orb_node == null:
		return

	if orb_node.is_in_group("orbs") and not orb_node in _orbs_collected:
		_orbs_collected.append(orb_node)
		# Trigger full collection
		if orb_node.has_method("on_orb_collected"):
			orb_node.on_orb_collected()


func _find_ball() -> void:
	var balls := get_tree().get_nodes_in_group("ball")
	if balls.size() > 0:
		_ball = balls[0]


## Initializes the vortex with texture and parameters.
func setup(texture: Texture2D, radius: float = 150.0, effect_duration: float = 45.0) -> void:
	vortex_radius = radius
	duration = effect_duration

	# Update collision shape
	if _collision_shape != null and _collision_shape.shape is CircleShape2D:
		(_collision_shape.shape as CircleShape2D).radius = vortex_radius

	if texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = texture
		# Scale sprite to match radius
		var texture_size: float = max(texture.get_width(), texture.get_height())
		var scale_factor: float = (vortex_radius * 2.0) / texture_size
		_visual_sprite.scale = Vector2(scale_factor, scale_factor)
		_visual_sprite.z_index = -1
		_visual_sprite.modulate = Color(1, 1, 1, 0.6)
		add_child(_visual_sprite)
