extends RigidBody2D

@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var max_speed := 1500.0
var fall_speed := 1500.0
var air_friction := 1
var game_over: bool = false

# Rescue state
var _is_rescuing: bool = false
var _rescue_target_pos: Vector2 = Vector2(580, 200)
var _player_target : Vector2 = Vector2(580, 601)
var _rescue_progress: float = 0.0
var _rescue_duration: float = 1.5

# Rescue visual
var _rescue_sprite: Sprite2D = null

# Player reference for rescue
var _player: Node2D = null
var _player_collision: CollisionPolygon2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ball")
	load_constants()
	Events.add_listener(BallRescueEvent, _on_ball_rescue_event)


func _process(delta: float) -> void:
	# Handle rescue animation
	if _is_rescuing:
		_update_rescue(delta)


func _physics_process(_delta: float) -> void:
	if _is_rescuing:
		# Disable physics during rescue
		linear_velocity = Vector2.ZERO
		return

	clamp_max_speed()
	clamp_fall_speed()
	apply_air_friction()


func clamp_max_speed():
	if max_speed > 0.0:
		var v := linear_velocity
		var s := v.length()
		if s > max_speed:
			linear_velocity = v * (max_speed / s)


func clamp_fall_speed():
	if fall_speed > 0.0:
		var v := linear_velocity.y

		if v > fall_speed:
			linear_velocity.y = fall_speed


func apply_air_friction():
	linear_velocity.x = linear_velocity.x * (1.0 - air_friction/1000.0)


func _on_body_entered(body: Node) -> void:
	# Ignore all collisions during rescue
	if _is_rescuing:
		return

	if body.is_in_group("ground") && !game_over:
		# Check for life before game over
		if EffectManager.has_effect("has_life"):
			_trigger_rescue()
		else:
			game_over = true
			GameOverEvent.invoke()
			PauseEvent.invoke(true)
			SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)
	elif body.is_in_group("player"):
		# Ball hit player's head - reset combo
		BallHeadHitEvent.invoke()
	elif body.is_in_group("half_solid"):
		# Gentle velocity reduction for smoother bounce feel
		linear_velocity = linear_velocity * 0.4


#region Rescue Logic

func _trigger_rescue() -> void:
	_is_rescuing = true
	_rescue_progress = 0.0
	freeze = true  # Freeze physics

	# Disable collisions during rescue
	if collision_shape != null:
		collision_shape.disabled = true

	# Consume the life
	EffectManager.remove_effect("has_life")
	LifeChangedEvent.invoke(false)

	# Find player for rescue positioning
	_find_player()

	# Freeze player during rescue
	if _player != null and _player is RigidBody2D:
		_player.freeze = true

	# Disable player collision during rescue
	if _player_collision != null:
		_player_collision.disabled = true

	# Create rescue visual
	_create_rescue_visual()

	# Notify systems
	BallRescueEvent.invoke(true)

	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.BALL_RESCUE)


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]
		# Get player collision for disabling during rescue
		_player_collision = _player.get_node_or_null("PolygonCollider2D")


func _create_rescue_visual() -> void:
	# Create sprite behind ball to indicate rescue
	_rescue_sprite = Sprite2D.new()
	_rescue_sprite.texture = _get_life_texture()
	_rescue_sprite.scale = Vector2(0.4, 0.4)  # Visible scale
	_rescue_sprite.z_index = -1
	_rescue_sprite.modulate = Color(1, 1, 1, 0.7)
	_rescue_sprite.position = Vector2(0, 0)  # Center on ball
	add_child(_rescue_sprite)


func _get_life_texture() -> Texture2D:
	# Load the life orb texture
	return load("res://resources/orbs/life_orb.tres").texture


func _update_rescue(delta: float) -> void:
	_rescue_progress += delta
	var t: float = clamp(_rescue_progress / _rescue_duration, 0.0, 1.0)

	# Ease out for smooth deceleration
	var eased_t: float = 1.0 - pow(1.0 - t, 3)

	# Move ball to target
	global_position = lerp(global_position, _rescue_target_pos, eased_t * 0.1)

	# Smoothly rotate ball back to 0
	rotation = lerp(rotation, 0.0, eased_t * 0.1)

	# Move player to neutral position (below ball)
	if _player != null:

		_player.global_position = lerp(_player.global_position, _player_target, eased_t * 0.1)

	# Update rescue visual (pulsating effect)
	if _rescue_sprite != null:
		var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 100.0)
		_rescue_sprite.modulate.a = 0.5 + 0.4 * pulse
		_rescue_sprite.scale = Vector2(0.4 + 0.1 * pulse, 0.4 + 0.1 * pulse)

	# Check if rescue complete
	if t >= 1.0 and global_position.distance_to(_rescue_target_pos) < 5.0:
		_complete_rescue()


func _complete_rescue() -> void:
	_is_rescuing = false
	freeze = false

	# Re-enable collisions
	if collision_shape != null:
		collision_shape.disabled = false

	# Unfreeze player
	if _player != null and _player is RigidBody2D:
		_player.freeze = false
		_player.linear_velocity = Vector2.ZERO

	# Re-enable player collision
	if _player_collision != null:
		_player_collision.disabled = false

	# Remove rescue visual
	if _rescue_sprite != null:
		_rescue_sprite.queue_free()
		_rescue_sprite = null

	# Reset velocity and rotation
	linear_velocity = Vector2.ZERO
	rotation = 0.0

	# Notify systems
	BallRescueEvent.invoke(false)

	# Reset combo
	ComboManager.reset_combo()


func _on_ball_rescue_event(event: BallRescueEvent) -> void:
	# Handle external rescue events if needed
	if event.is_rescuing():
		_is_rescuing = true
		freeze = true
	else:
		_is_rescuing = false
		freeze = false


## Returns whether the ball is currently in rescue mode.
func is_rescuing() -> bool:
	return _is_rescuing

#endregion


func load_constants():
	max_speed = Constants.ball_max_speed
	fall_speed = Constants.ball_fall_speed
	air_friction = Constants.ball_air_friction


func apply_constants():
	pass
