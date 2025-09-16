extends RigidBody2D



@onready var ground_cast := $groundcast
@onready var ceiling_cast := $ceilingcast

@export var jump_power : int = -600
@export var initial_move_speed : int = 300
@export var coyote_timeout : float = 150
@export var jump_buffer_timeout : float = 150
@export var grounding_force : float = 1.5
@export var fall_acceleration : float = 1800.0
@export var max_fall_speed : float = 800
@export var Jump_ended_early_gravity_modifier : float = 3.0
@export var move_acceleration : float = 600
@export var initial_move_acceleration : float = 10000
@export var move_deceleration : float = 10000
@export var stop_on_ceiled : bool = false



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
var _targetHorizontalVelocity : float = 0
var _addedHorizontalVelocity : float = 0



var _move : Vector2 = Vector2.ZERO
var _frameVelocity : Vector2 = Vector2.ZERO
var _timeJumpWasPressed : int = 0
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
	# print("linear velocity : " + str(linear_velocity.x))


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
	if _move.x:
		_targetHorizontalVelocity = _addedHorizontalVelocity + initial_move_speed
	else:
		_targetHorizontalVelocity = 0
	

func ApplyMovement(delta: float):
	if _targetHorizontalVelocity != 0:
		if abs(_frameVelocity.x) < initial_move_speed:
			_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * _targetHorizontalVelocity, initial_move_acceleration * delta)
		else:
			if sign(_frameVelocity.x * _move.x) == -1:
				_frameVelocity.x = 0
			_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * _targetHorizontalVelocity, move_acceleration * delta)
	else:
		_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * 0, move_deceleration * delta)
	
	
	
func handle_move_event(event: MoveEvent) -> void:
	if event._move == PlayerMoves.JUMP:
		if event._pressed == true:
			_JumpHeld = true
		else:
			_JumpHeld = false
			_timeJumpWasReleased = Time.get_ticks_msec()
		
	if event._move == PlayerMoves.LEFT:
		_leftHeld = event._pressed
	
	if event._move == PlayerMoves.RIGHT:
		_rightHeld = event._pressed
		
	if _leftHeld:
		_move.x = -1
		_addedHorizontalVelocity = event._power
		
	elif _rightHeld:
		_move.x = 1
		_addedHorizontalVelocity = event._power
		
	else:
		_move.x = 0	
		_addedHorizontalVelocity = 0
		
	if !_JumpHeldPrev && _JumpHeld:
		_jumpToConsume = true
		_timeJumpWasPressed = Time.get_ticks_msec()
	
	
	
	_JumpHeldPrev = _JumpHeld
	
	pass
