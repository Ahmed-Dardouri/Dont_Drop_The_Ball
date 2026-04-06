class_name VortexEffect extends Area2D
## Visual vortex aura that follows the ball and collects orbs in expanded range.
## The sprite rotates independently of the ball's rotation.

#region Configuration

## How long the vortex lasts in seconds
@export var duration: float = 45.0

## Radius of the vortex collection area
@export var vortex_radius: float = 65.0

## Scale multiplier for the vortex visual (final size)
@export var vortex_scale: float = 1.0

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

	# Listen for game over to clean up
	Events.add_listener(GameOverEvent, _on_game_over)

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

	# Check for orbs that spawned inside the vortex (area_entered doesn't fire for those)
	_check_existing_orbs()

	# Check if effect expired
	if _time_elapsed >= duration:
		_cleanup()


func _on_area_entered(area: Area2D) -> void:
	# Skip collection if ball is in rescue mode
	if _ball != null and _ball.has_method("is_rescuing") and _ball.is_rescuing():
		return

	# Find the orb node - it's the parent of the DataOrbArea
	var orb_node: Node = area.get_parent()
	if orb_node == null:
		return

	if orb_node.is_in_group("orbs") and not orb_node in _orbs_collected:
		_orbs_collected.append(orb_node)
		# Trigger full collection
		if orb_node.has_method("on_orb_collected"):
			orb_node.on_orb_collected()


func _on_game_over(_event: GameOverEvent) -> void:
	_cleanup()


func _find_ball() -> void:
	var balls := get_tree().get_nodes_in_group("ball")
	if balls.size() > 0:
		_ball = balls[0]


## Check if an orb is within the vortex collection range using distance.
## Works regardless of physics server state (unlike overlaps_area).
func _is_within_range(orb: Node2D) -> bool:
	if orb == null or not is_instance_valid(orb):
		return false
	var distance: float = global_position.distance_to(orb.global_position)
	return distance <= vortex_radius


## Check for orbs already inside the vortex area when created
func _check_existing_orbs() -> void:
	var orbs := get_tree().get_nodes_in_group("orbs")
	for orb: Node in orbs:
		if orb in _orbs_collected:
			continue
		if not orb.has_method("on_orb_collected"):
			continue
		# Use distance check instead of overlaps_area() because
		# overlaps_area() fails when orb's area is not monitorable (during spawn animation)
		if _is_within_range(orb):
			_orbs_collected.append(orb)
			orb.on_orb_collected()


func _cleanup() -> void:
	# Notify UI that vortex is gone
	VortexChangedEvent.invoke(false)
	queue_free()


## Initializes the vortex with texture and parameters.
func setup(texture: Texture2D, radius: float = 65.0, effect_duration: float = 45.0, scale_mult: float = 1.0) -> void:
	vortex_radius = radius
	duration = effect_duration
	vortex_scale = scale_mult

	# Update collision shape
	if _collision_shape != null and _collision_shape.shape is CircleShape2D:
		(_collision_shape.shape as CircleShape2D).radius = vortex_radius

	if texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = texture
		# Scale sprite to match radius, then apply vortex_scale multiplier
		var texture_size: float = max(texture.get_width(), texture.get_height())
		var scale_factor: float = (vortex_radius * 2.0) / texture_size * vortex_scale
		_visual_sprite.scale = Vector2(scale_factor, scale_factor)
		_visual_sprite.z_index = -1
		_visual_sprite.modulate = Color(1, 1, 1, 0.6)
		add_child(_visual_sprite)
