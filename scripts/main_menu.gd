extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_play_botton_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.PLAY)


func _on_mode_button_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.MODE_SELECT)


func _on_settings_button_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.SETTINGS)


func _on_exit_button_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.EXIT)
