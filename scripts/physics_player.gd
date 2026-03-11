extends RigidBody2D



@onready var ground_cast := $groundcast
@onready var ceiling_cast := $ceilingcast

#region loaded_constants

var keyboard_move_power : int = 0
var jump_power : int = 0
var initial_move_speed : int = 0
var coyote_timeout : float = 0
var jump_buffer_timeout : float = 0
var grounding_force : float = 0
var fall_acceleration : float = 0
var max_fall_speed : float = 0
var Jump_ended_early_gravity_modifier : float = 0
var move_acceleration : float = 0
var initial_move_acceleration : float = 0
var move_deceleration : float = 0
var stop_on_ceiled : bool = false
var mass_const : float = 0
var gravity : float = 0

#endregion

#region internal_variables

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

#endregion



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("player")
	load_constants()
	apply_constants()
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

		# Apply slow_fall effect if active
		var current_max_fall = max_fall_speed
		if EffectManager.has_effect("slow_fall"):
			var slow_factor = EffectManager.get_effect_value("slow_fall")
			current_max_fall = max_fall_speed * slow_factor

		_frameVelocity.y = move_toward(_frameVelocity.y, current_max_fall, inAirGravity * delta)
			


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
	# Apply sticky_head effect if active (dampens velocity)
	if EffectManager.has_effect("sticky_head"):
		var dampen = EffectManager.get_effect_value("sticky_head")
		_frameVelocity.x *= dampen
		_frameVelocity.y *= dampen

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
			else:
				_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * _targetHorizontalVelocity, move_acceleration * delta)
	else:
		_frameVelocity.x = move_toward(_frameVelocity.x, _move.x * 0, move_deceleration * delta)
	
	
	
func handle_move_event(event: MoveEvent) -> void:
	if event._move == Enums.PlayerMoves.JUMP:
		if event._pressed == true:
			_JumpHeld = true
		else:
			_JumpHeld = false
			_timeJumpWasReleased = Time.get_ticks_msec()
		
	if event._move == Enums.PlayerMoves.LEFT:
		_leftHeld = event._pressed
		if _leftHeld:
			_addedHorizontalVelocity = event._power
			
	if event._move == Enums.PlayerMoves.RIGHT:
		_rightHeld = event._pressed
		if _rightHeld:
			_addedHorizontalVelocity = event._power

	update_move()
	
	if !_leftHeld && !_rightHeld:
		_addedHorizontalVelocity = 0
		
	if !_JumpHeldPrev && _JumpHeld:
		_jumpToConsume = true
		_timeJumpWasPressed = Time.get_ticks_msec()
	
	
	_JumpHeldPrev = _JumpHeld
	
	pass

func update_move():
	if _rightHeld:
		_move.x = 1
	elif _leftHeld:
		_move.x = -1
	else:
		_move.x = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Jump"):
		MoveEvent.invoke(Enums.PlayerMoves.JUMP, true, 0)
	if event.is_action_released("Jump"):
		MoveEvent.invoke(Enums.PlayerMoves.JUMP, false, 0) 
	if event.is_action_pressed("Left"):
		MoveEvent.invoke(Enums.PlayerMoves.LEFT, true, keyboard_move_power)
	if event.is_action_released("Left"):
		MoveEvent.invoke(Enums.PlayerMoves.LEFT, false, 0)
	if event.is_action_pressed("Right"):
		MoveEvent.invoke(Enums.PlayerMoves.RIGHT, true, keyboard_move_power)
	if event.is_action_released("Right"):
		MoveEvent.invoke(Enums.PlayerMoves.RIGHT, false, 0)

func load_constants():
	keyboard_move_power = Constants.player_keyboard_move_power
	jump_power = Constants.player_jump_power
	initial_move_speed = Constants.player_initial_move_speed
	coyote_timeout = Constants.player_coyote_timeout
	jump_buffer_timeout = Constants.player_jump_buffer_timeout
	grounding_force = Constants.player_grounding_force
	fall_acceleration = Constants.player_fall_acceleration
	max_fall_speed = Constants.player_max_fall_speed
	Jump_ended_early_gravity_modifier = Constants.player_Jump_ended_early_gravity_modifier
	move_acceleration = Constants.player_move_acceleration
	initial_move_acceleration = Constants.player_initial_move_acceleration
	move_deceleration = Constants.player_move_deceleration
	stop_on_ceiled = Constants.player_stop_on_ceiled
	mass_const = Constants.player_mass_const
	gravity = Constants.player_gravity

func apply_constants():
	mass = mass_const
	gravity_scale = gravity
