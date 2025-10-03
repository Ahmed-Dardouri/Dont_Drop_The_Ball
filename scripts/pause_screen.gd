extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_button_pressed() -> void:
	WorldButtonEvent.invoke(Enums.WorldButtonType.MAIN_MENU)

func _on_back_button_pressed() -> void:
	WorldButtonEvent.invoke(Enums.WorldButtonType.BACK)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && visible == true:
		WorldButtonEvent.invoke(Enums.WorldButtonType.BACK)
