extends Control
## Mode selection menu - allows player to choose between game modes.

## Currently selected mode ID
var selected_mode_id: String = "endless"

@onready var endless_button: Button = $PanelContainer/VBoxContainer/endless_button
@onready var beginner_button: Button = $PanelContainer/VBoxContainer/beginner_button
@onready var back_button: Button = $PanelContainer/VBoxContainer/back_button


func _ready() -> void:
	_update_button_selection()


func _update_button_selection() -> void:
	# Update button appearance based on selection
	if endless_button != null:
		endless_button.button_pressed = (selected_mode_id == "endless")
	if beginner_button != null:
		beginner_button.button_pressed = (selected_mode_id == "beginner")


func _on_endless_button_pressed() -> void:
	selected_mode_id = "endless"
	_update_button_selection()


func _on_beginner_button_pressed() -> void:
	selected_mode_id = "beginner"
	_update_button_selection()


func _on_back_button_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.BACK)


## Get the currently selected mode ID.
func get_selected_mode() -> String:
	return selected_mode_id
