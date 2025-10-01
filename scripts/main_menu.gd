extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_play_botton_pressed() -> void:
	ButtonEvent.invoke(Enums.ButtonType.PLAY)


func _on_settings_button_pressed() -> void:
	ButtonEvent.invoke(Enums.ButtonType.SETTINGS)


func _on_exit_button_pressed() -> void:
	ButtonEvent.invoke(Enums.ButtonType.EXIT)


func _on_tutorial_button_pressed() -> void:
	ButtonEvent.invoke(Enums.ButtonType.TUTORIAL)
