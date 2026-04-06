extends Control
## Mode selection menu - allows player to choose between game modes.

## Currently selected mode ID (default to beginner for easier experience)
var selected_mode_id: int = Enums.PlayMode.BEGINNER

@onready var endless_button: Button = $PanelContainer/VBoxContainer/endless_button
@onready var beginner_button: Button = $PanelContainer/VBoxContainer/beginner_button
@onready var back_button: Button = $PanelContainer/VBoxContainer/back_button

## Guard against re-entrant calls when setting button_pressed triggers pressed signal
var _updating_selection: bool = false


func _ready() -> void:
	_update_button_selection()


func _update_button_selection() -> void:
	_updating_selection = true
	if endless_button != null:
		endless_button.button_pressed = (selected_mode_id == Enums.PlayMode.ENDLESS)
	if beginner_button != null:
		beginner_button.button_pressed = (selected_mode_id == Enums.PlayMode.BEGINNER)
	_updating_selection = false


func _on_endless_button_pressed() -> void:
	if _updating_selection:
		return
	selected_mode_id = Enums.PlayMode.ENDLESS
	_update_button_selection()


func _on_beginner_button_pressed() -> void:
	if _updating_selection:
		return
	selected_mode_id = Enums.PlayMode.BEGINNER
	_update_button_selection()


func _on_back_button_pressed() -> void:
	ButtonEvent.invoke(Enums.MainButtonType.BACK)


## Get the currently selected mode ID.
func get_selected_mode() -> int:
	return selected_mode_id
