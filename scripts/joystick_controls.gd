extends Control

@onready var joystick: Node2D = $Joystick

@onready var jump_touch_button: TouchScreenButton = $jump_touch_button


var _left : bool = false
var _right : bool = false

var _prev_left : bool = false
var _prev_right : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(GameOverEvent, hide_controls)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_joystick()
	pass


	
func hide_controls(game_over_event: GameOverEvent):
	visible = false


func _on_jump_touch_button_pressed() -> void:
	invoke_move(PlayerMoves.JUMP, true)


func _on_jump_touch_button_released() -> void:
	invoke_move(PlayerMoves.JUMP, false)



func _on_joystick_touch_button_pressed() -> void:
	joystick.visible = true
	var pos = get_viewport().get_mouse_position()
	joystick.position = pos
	joystick.pressing = true


func _on_joystick_touch_button_released() -> void:
	joystick.visible = false
	joystick.pressing = false


func check_joystick():
	if joystick.visible == true:
		
		var posVectorX = joystick.posVector.x
		
		if posVectorX < -1 * (joystick.deadzone/ joystick.maxLength):
			_left = true
		else:
			_left = false
		
		if posVectorX > joystick.deadzone/ joystick.maxLength:
			_right = true
		else:
			_right = false
		
		if _left && !_prev_left:
			invoke_move(PlayerMoves.LEFT, true)

		if _right && !_prev_right:
			invoke_move(PlayerMoves.RIGHT, true)
		
		if !_left && _prev_left:
			invoke_move(PlayerMoves.LEFT, false)
			
		if !_right && _prev_right:
			invoke_move(PlayerMoves.RIGHT, false)
			
	else:
		if _left:
			invoke_move(PlayerMoves.LEFT, false)
		
		if _right:
			invoke_move(PlayerMoves.RIGHT, false)
			
		_left = false
		_right = false
			
	_prev_left = _left
	_prev_right = _right
	
	
	
func invoke_move(move : int, value: bool):
	Events.invoke(MoveEvent.new(move, value))
