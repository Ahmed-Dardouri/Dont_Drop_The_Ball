class_name LifeOrbEffect extends Node2D
## Purely visual effect that expands and fades when life orb is collected.

#region Configuration

## How long the effect lasts in seconds
@export var duration: float = 1

## Final scale multiplier
@export var max_scale: float = 2.0
@export var min_scale: float = 0.2
#endregion

#region State

var _time_elapsed: float = 0.0
var _visual_sprite: Sprite2D = null

#endregion


func _ready() -> void:
	if _visual_sprite != null:
		_visual_sprite.modulate.a = 1.0


func _process(delta: float) -> void:
	_time_elapsed += delta
	var progress: float = min(_time_elapsed / duration, 1.0)

	# Ease out for smooth expansion
	var eased_progress: float = 1.0 - pow(1.0 - progress, 2)

	# Expand scale
	scale = Vector2.ONE * (min_scale + (max_scale - min_scale) * eased_progress)

	# Fade out
	if _visual_sprite != null:
		_visual_sprite.modulate.a = 1.0 - progress

	# Remove when complete
	if _time_elapsed >= duration:
		queue_free()


## Initializes the effect with a texture.
func setup(texture: Texture2D) -> void:
	if texture != null:
		_visual_sprite = Sprite2D.new()
		_visual_sprite.texture = texture
		_visual_sprite.scale = Vector2.ONE
		add_child(_visual_sprite)
