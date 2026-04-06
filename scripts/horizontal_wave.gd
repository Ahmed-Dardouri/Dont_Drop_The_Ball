class_name HorizontalWave extends Area2D
## Visual wave effect that expands horizontally and collects orbs it touches.

#region Configuration

## How long the wave lasts in seconds
@export var duration: float = 0.5

## How far the wave travels in each direction (total width = range * 2)
@export var wave_range: float = 300.0

## Bonus score per orb collected
@export var bonus_per_orb: int = 4

#endregion

#region State

var _time_elapsed: float = 0.0
var _visual_sprite: Sprite2D = null
var _collision_shape: CollisionShape2D = null
var _orbs_collected: Array[Node] = []
var _start_x: float = 0.0

#endregion


func _ready() -> void:
	# Set up collision to detect orb areas
	collision_layer = 0
	collision_mask = 2  # Detect orbs' Area2D on layer 2

	# Create collision shape (rectangle that expands horizontally)
	_collision_shape = CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(1.0, 64.0)  # Start thin, tall enough to hit orbs
	_collision_shape.shape = rect_shape
	add_child(_collision_shape)

	# Connect area detection signal
	area_entered.connect(_on_area_entered)

	# Record starting position
	_start_x = global_position.x


func _process(delta: float) -> void:
	_time_elapsed += delta
	var progress: float = min(_time_elapsed / duration, 1.0)

	# Ease out for smooth expansion
	var eased_progress: float = 1.0 - pow(1.0 - progress, 2)

	# Current half-width of the wave
	var current_half_width: float = wave_range * eased_progress

	# Expand collision shape horizontally
	if _collision_shape != null and _collision_shape.shape is RectangleShape2D:
		(_collision_shape.shape as RectangleShape2D).size.x = max(current_half_width * 2, 1.0)

	# Expand visual sprite horizontally
	if _visual_sprite != null:
		var texture_width: float = _visual_sprite.texture.get_width() if _visual_sprite.texture else 1.0
		var scale_x: float = (current_half_width * 2) / texture_width
		_visual_sprite.scale = Vector2(scale_x, 1.0)

	# Fade out
	if _visual_sprite != null:
		_visual_sprite.modulate.a = 1.0 - (progress * 0.8)

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
		# Add bonus score
		ScoreManager.add_score(bonus_per_orb)
		# Trigger full collection (behaviors, events, chain reactions)
		if orb_node.has_method("on_orb_collected"):
			orb_node.on_orb_collected()


## Initializes the wave with texture and parameters.
func setup(texture: Texture2D, range_dist: float = 300.0, bonus: int = 4) -> void:
	wave_range = range_dist
	bonus_per_orb = bonus

	if texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = texture
		_visual_sprite.scale = Vector2(0.01, 1.0)  # Start very thin
		add_child(_visual_sprite)
