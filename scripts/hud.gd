extends CanvasLayer

@onready var check_button: CheckButton = $CheckButton
@onready var button_controls: Control = $button_controls
@onready var joystick_controls: Control = $joystick_controls

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_button.button_pressed = Constants.use_joystick


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_button_toggled(toggled_on: bool) -> void:
	Constants.use_joystick = check_button.button_pressed
	pass # Replace with function body.
