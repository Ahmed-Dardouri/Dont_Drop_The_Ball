extends Node2D
## Updates the background color based on the current game mode.

@onready var background_rect: ColorRect = $ColorRect


func _ready() -> void:
	_update_background_color()


func _process(_delta: float) -> void:
	# Update background color every frame in case mode changes
	_update_background_color()


func _update_background_color() -> void:
	if background_rect == null:
		return

	var target_color: Color = GameRules.get_background_color()
	background_rect.color = target_color
