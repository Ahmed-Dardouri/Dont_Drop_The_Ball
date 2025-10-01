extends Control

@onready var joystick: Node2D = $Joystick

@onready var jump_touch_button: TouchScreenButton = $jump_touch_button

@export var move_power_multiplier : int = 600

var _left : bool = false
var _right : bool = false

var _prev_left : bool = false
var _prev_right : bool = false

var _reversed: bool = false
var _prev_posVectorX = 0

var _prev_diff :float = 0

var diff_sum : float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(GameOverEvent, hide_controls)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	get_joystick_action()
	check_move_reversal()
	pass


	
func hide_controls(game_over_event: GameOverEvent):
	visible = false


func _on_jump_touch_button_pressed() -> void:
	MoveEvent.invoke(Enums.PlayerMoves.JUMP, true, 0)


func _on_jump_touch_button_released() -> void:
	MoveEvent.invoke(Enums.PlayerMoves.JUMP, false, 0)



func _on_joystick_touch_button_pressed() -> void:
	joystick.visible = true
	var pos = get_viewport().get_mouse_position()
	joystick.position = pos
	joystick.pressing = true


func _on_joystick_touch_button_released() -> void:
	joystick.visible = false
	joystick.pressing = false


func get_joystick_action():
	if joystick.visible == true:
		
		var posVectorX = joystick.posVector.x
		
		var move_power = abs(posVectorX * move_power_multiplier)

		if posVectorX < -1 * (joystick.deadzone/ joystick.maxLength):
			_left = true
		else:
			_left = false
		
		if posVectorX > joystick.deadzone/ joystick.maxLength:
			_right = true
		else:
			_right = false
		
		
		if _left:
			MoveEvent.invoke(Enums.PlayerMoves.LEFT, true, move_power)

		if _right:
			MoveEvent.invoke(Enums.PlayerMoves.RIGHT, true, move_power)
			
		if !_left && _prev_left:
			MoveEvent.invoke(Enums.PlayerMoves.LEFT, false, 0)
			
		if !_right && _prev_right:
			MoveEvent.invoke(Enums.PlayerMoves.RIGHT, false, 0)
			
	else:
		if _left:
			MoveEvent.invoke(Enums.PlayerMoves.LEFT, false, 0)
		
		if _right:
			MoveEvent.invoke(Enums.PlayerMoves.RIGHT, false, 0)
			
		_left = false
		_right = false
			
	_prev_left = _left
	_prev_right = _right
	
	
func check_move_reversal():
	var posVectorX = joystick.posVector.x
	var diff = posVectorX - _prev_posVectorX
	
	
	if (diff != 0) && (sign(diff * _prev_diff) != -1):
		diff_sum += diff
	else:
		diff_sum = diff
		
	if _left && diff_sum > 0.1:
		_reversed = true
	elif _right && diff_sum < -0.1:
		_reversed = true
	else:
		_reversed = false
		
	_prev_posVectorX = posVectorX
	
	if _reversed:
		var pos = get_viewport().get_mouse_position()
		joystick.position = pos

		_prev_posVectorX = 0
	
