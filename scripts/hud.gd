extends CanvasLayer

@onready var check_button: CheckButton = $CheckButton
@onready var button_controls: Control = $button_controls
@onready var joystick_controls: Control = $joystick_controls

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_button.button_pressed = PlayerVariables.use_joystick
	#if PlayerVariables.use_joystick :
	#	joystick_controls.visible = true
	#else:
	#	button_controls.visible = true
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_button_toggled(toggled_on: bool) -> void:
	PlayerVariables.use_joystick = check_button.button_pressed
	pass # Replace with function body.
