extends Node2D
## Controls mode-specific visual elements like parallax background.

@onready var forest_parallax: Node2D = $forest_parallax


func _ready() -> void:
	_update_parallax_visibility()


func _process(_delta: float) -> void:
	# Update visibility in case mode changes
	_update_parallax_visibility()


func _update_parallax_visibility() -> void:
	if forest_parallax == null:
		return

	forest_parallax.visible = GameRules.get_show_parallax_background()
