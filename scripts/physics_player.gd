extends RigidBody2D



@onready var ground_cast := $groundcast
@onready var ceiling_cast := $ceilingcast

@export var horizontal_speed_multiplier : float = 0.7
@export var jump_power : int = -600
@export var max_speed : int = 300
@export var end_jump_early_timeout : float = 300
@export var coyote_timeout : float = 150
@export var jump_buffer_timeout : float = 150
@export var grounding_force : float = 1.5
@export var fall_acceleration : float = 1800.0
@export var max_fall_speed : float = 800
@export var Jump_ended_early_gravity_modifier : float = 3.0
@export var gravity : float = 9.8
@export var acceleration : float = 10000
@export var stop_on_ceiled : bool = false


@export var header_strength: float = 10000.0     # base kick power
@export var inherit_factor: float = 0.1        # how much of player velocity is passed to the ball

const SPEED = 300.0



var _ceiled : bool = false
var _endedJumpEarly : bool = false
var _grounded : bool = false
var _leftHeld : bool = false
var _rightHeld : bool = false
var _JumpHeld : bool = false
var _JumpHeldPrev : bool = false
var _jumpToConsume : bool = false
var _bufferedJumpUsable : bool = false
var _coyoteUsable : bool = false
var _direction : float = 0
var _targetHorizontalVelocity : float = 0




var _move : Vector2 = Vector2.ZERO
var _frameVelocity : Vector2 = Vector2.ZERO
var _timeJumpWasPressed : int = 0
var _timeMoveWasPressed : int = 0
var _timeLeftGround : int = 0
var _timeJumpWasReleased : int = 0





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.add_listener(MoveEvent, handle_move_event)
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	pass # Replace with function body.




func _physics_process(delta: float) -> void:
		
	CheckGround()
	HandleGravity(delta)
	HandleJump()

	ApplyHorizontalMovement(delta)
	
	CheckCeiling()
	ApplyMovement(delta)
	ApplyVelocity()	



func HandleJump() -> void:

	if !_endedJumpEarly && !_grounded && !_JumpHeld && linear_velocity.y < 0:
		_endedJumpEarly = true
		
	if _jumpToConsume && HasBufferedJump():
		if _grounded || canCoyote():
			ExecuteJump()
			_jumpToConsume = false;

func ExecuteJump():
	_endedJumpEarly = false
	_timeJumpWasPressed = 0
	_bufferedJumpUsable = false
	_coyoteUsable = false
	_frameVelocity.y = jump_power

func HandleGravity(delta: float):
	if _grounded && _frameVelocity.y >= 0:
		_frameVelocity.y = grounding_force
	else:
		var inAirGravity = fall_acceleration
		if _endedJumpEarly && _frameVelocity.y < 0 :
			
			inAirGravity *= Jump_ended_early_gravity_modifier
		_frameVelocity.y = move_toward(_frameVelocity.y, max_fall_speed, inAirGravity * delta)
			



func CheckCeiling():
	if stop_on_ceiled:
		var prev_ceiled = _ceiled
		_ceiled = ceiling_cast.is_colliding()
		if !prev_ceiled && _ceiled:
			_frameVelocity.y = 1

func CheckGround():
	var previously_grounded = _grounded
	_grounded = ground_cast.is_colliding()
	_bufferedJumpUsable = true
	_coyoteUsable = true
	
	if !previously_grounded && _grounded:
		_coyoteUsable = true
		_endedJumpEarly = false
	elif previously_grounded && !_grounded:
		_timeLeftGround = Time.get_ticks_msec()

func ApplyVelocity():
	linear_velocity = _frameVelocity

func HasBufferedJump() -> bool:
	var buffered : bool = false
	if _bufferedJumpUsable && Time.get_ticks_msec() < _timeJumpWasPressed + jump_buffer_timeout:
		buffered = true
	else:
		_bufferedJumpUsable = false
		
	return buffered

func canCoyote() -> bool:
	var coyotable := false
	if _coyoteUsable && Time.get_ticks_msec() < _timeLeftGround + coyote_timeout: 
		coyotable = true
	return coyotable

func ApplyHorizontalMovement(delta: float):
	var prev_direction = _direction
	_direction = Input.get_axis("ui_left", "ui_right")
	
	if prev_direction == 0 and _direction != 0:
		_timeMoveWasPressed = Time.get_ticks_msec()
	
	var curr_time = Time.get_ticks_msec()
	var time_diff = curr_time - _timeMoveWasPressed
	if time_diff > 500:
		time_diff = 500
		
	if _direction:
		_targetHorizontalVelocity = SPEED + time_diff * horizontal_speed_multiplier
		
	else:
		_targetHorizontalVelocity = move_toward(linear_velocity.x, 0, SPEED)
	

func ApplyMovement(delta: float):
	if abs(_frameVelocity.x) < max_speed:
		_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * max_speed, acceleration * delta)
	else:
		_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * _targetHorizontalVelocity, acceleration * delta)

func _input(event: InputEvent) -> void:
	pass

func handle_move_event(event: MoveEvent) -> void:
	
	if event._move == PlayerMoves.JUMP:
		if event._pressed == true:
			_JumpHeld = true
		else:
			_JumpHeld = false
			_timeJumpWasReleased = Time.get_ticks_msec()
		
		
	if event._move == PlayerMoves.LEFT:
		_leftHeld == event._pressed
	
	if event._move == PlayerMoves.RIGHT:
		_rightHeld == event._pressed
		
		
	if _leftHeld:
		_move.x = -1
	elif _rightHeld:
		_move.x = 1
	else:
		_move.x = 0	
		
	if !_JumpHeldPrev && _JumpHeld:
		_jumpToConsume = true
		_timeJumpWasPressed = Time.get_ticks_msec()
	
	_JumpHeldPrev = _JumpHeld
	
