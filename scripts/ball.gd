class_name Ball extends RigidBody2D

#region Exports

@export var max_speed: float = 900.0
@export var fall_speed: float = 900.0
@export var air_friction: int = 3
@export var game_over: bool = false

@export var rescue_duration: float = 1.5
@export var rescue_target_pos: Vector2 = Vector2(580, 200)
@export var player_target: Vector2 = Vector2(580, 601)

#endregion

#region Node References

@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

#endregion

#region State

# Slowdown
var _slowdown_multiplier: float = 1.0
var _slowdown_timer: float = 0.0
var _slowdown_active: bool = false

# Rescue state
var _is_rescuing: bool = false
var _rescue_progress: float = 0.0

# Rescue visual
var _rescue_sprite: Sprite2D = null
var _rescue_visual_texture: Texture2D = null

# Player reference for rescue
var _player: Node2D = null
var _player_collision: CollisionPolygon2D = null

#endregion


#region Lifecycle

func _ready() -> void:
	add_to_group("ball")
	load_constants()
	apply_easy_mode_settings()
	Events.add_listener(BallRescueEvent, _on_ball_rescue_event)
	Events.add_listener(OrbCollectedEvent, _on_orb_collected)


func _process(delta: float) -> void:
	# Handle rescue animation
	if _is_rescuing:
		_update_rescue(delta)

	# Handle slowdown timer
	if _slowdown_timer > 0.0:
		_slowdown_timer -= delta
		if _slowdown_timer <= 0.0:
			_end_slowdown()


func _physics_process(_delta: float) -> void:
	if _is_rescuing:
		# Disable physics during rescue
		linear_velocity = Vector2.ZERO
		return

	# No special handling needed - velocity was scaled at slowdown start
	clamp_max_speed()
	clamp_fall_speed()
	apply_air_friction()


#endregion

#region Physics Helpers

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


#endregion

#region Collision Handling

func _on_body_entered(body: Node) -> void:
	# Ignore all collisions during rescue
	if _is_rescuing:
		return

	if body.is_in_group("ground") && !game_over:
		# Check for life before game over
		if _has_life():
			_trigger_life_rescue()
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


#endregion

#region Life Management

## Check if player has a life (either temporary effect or permanent)
func _has_life() -> bool:
	if EffectManager.has_effect("has_life"):
		return true
	if Variables.permanent_lives > 0:
		return true
	return false


## Consume a life (prefers permanent lives in easy mode, then temporary effect)
func _consume_life() -> void:
	if GameRules.get_permanent_life_pickups() and Variables.permanent_lives > 0:
		Variables.permanent_lives -= 1
		LifeChangedEvent.invoke(false)
	elif EffectManager.has_effect("has_life"):
		EffectManager.remove_effect("has_life")
		LifeChangedEvent.invoke(false)


#endregion

#region Rescue Movement

## Start rescue movement to safe position with optional custom visual sprite.
## This is the generic rescue that can be reused by different systems (life orb, augment orb, etc.)
## sprite_texture: The texture to use for the rescue visual. If null, uses life orb texture.
func start_rescue_movement(sprite_texture: Texture2D = null) -> void:
	_is_rescuing = true
	_rescue_progress = 0.0
	freeze = true  # Freeze physics

	# Disable collisions during rescue
	if collision_shape != null:
		collision_shape.disabled = true

	# Find player for rescue positioning
	_find_player()

	# Freeze player during rescue
	if _player != null and _player is RigidBody2D:
		_player.freeze = true
		_player.set_process_input(false)  # Disable input during rescue

	# Disable player collision during rescue
	if _player_collision != null:
		_player_collision.disabled = true

	# Create rescue visual
	_create_rescue_visual(sprite_texture)

	# Notify systems
	BallRescueEvent.invoke(true)


## Trigger life rescue when ball hits ground with a life.
## This consumes a life and uses life orb visual.
func _trigger_life_rescue() -> void:
	# Consume the life FIRST
	_consume_life()

	# Play life rescue sound (bounce sound to indicate you didn't lose)
	SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.BALL_RESCUE)

	# Start rescue movement with life orb visual
	start_rescue_movement(_get_life_texture())


func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]
		# Get player collision for disabling during rescue
		_player_collision = _player.get_node_or_null("PolygonCollider2D")


func _create_rescue_visual(sprite_texture: Texture2D) -> void:
	# Use provided texture or or fallback to life orb texture
	var texture_to_use: Texture2D = sprite_texture if sprite_texture != null else _get_life_texture()

	# Create sprite behind ball to indicate rescue
	_rescue_sprite = Sprite2D.new()
	_rescue_sprite.texture = texture_to_use
	_rescue_sprite.scale = Vector2(0.4, 0.4)
	_rescue_sprite.modulate.a = 0.7
	_rescue_sprite.z_index = -1  # Behind ball
	_rescue_sprite.position = rescue_target_pos
	add_child(_rescue_sprite)

	# Store for reference
	_rescue_visual_texture = texture_to_use


func _get_life_texture() -> Texture2D:
	# Load the life orb texture
	return load("res://resources/orbs/life_orb.tres").texture


func _update_rescue(delta: float) -> void:
	_rescue_progress += delta
	var t: float = clamp(_rescue_progress / rescue_duration, 0.0, 1.0)

	# Ease out for smooth deceleration
	var eased_t: float = 1.0 - pow(1.0 - t, 3)

	# Move ball to target
	global_position = lerp(global_position, rescue_target_pos, eased_t * 0.1)

	# Smoothly rotate ball back to 0
	rotation = lerp(rotation, 0.0, eased_t * 0.1)

	# Move player to neutral position (below ball)
	if _player != null:
		_player.global_position = lerp(_player.global_position, player_target, eased_t * 0.1)

	# Update rescue visual (pulsating effect)
	if _rescue_sprite != null:
		var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 100.0)
		_rescue_sprite.modulate.a = 0.5 + 0.4 * pulse
		_rescue_sprite.scale = Vector2(0.4 + 0.1 * pulse, 0.4 + 0.1 * pulse)

	# Check if rescue complete
	if _rescue_progress >= rescue_duration:
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
		_player.set_process_input(true)  # Re-enable input after rescue
		# Reset player movement state
		if _player.has_method("reset_movement_state"):
			_player.reset_movement_state()

	# Re-enable player collision
	if _player_collision != null:
		_player_collision.disabled = false

	# Remove rescue visual
	if _rescue_sprite != null:
		_rescue_sprite.queue_free()
		_rescue_sprite = null

	# Reset velocity
	linear_velocity = Vector2.ZERO
	rotation = 0.0

	# Notify systems
	BallRescueEvent.invoke(false)


#endregion

#region Slowdown

## Start ball slowdown effect (used by easy mode assist)
func start_slowdown(duration: float, multiplier: float = 1.0) -> void:
	if multiplier <= 0.0 or multiplier == 1.0:
		return

	_slowdown_active = true
	_slowdown_multiplier = multiplier
	_slowdown_timer = duration

	# Scale current velocity
	linear_velocity *= multiplier


## End ball slowdown effect
func _end_slowdown() -> void:
	if not _slowdown_active:
		return

	_slowdown_active = false
	_slowdown_multiplier = 1.0
	_slowdown_timer = 0.0

	# Restore normal velocity
	linear_velocity /= _slowdown_multiplier


#endregion

#region Event Handlers

func _on_ball_rescue_event(event: BallRescueEvent) -> void:
	# Handle external rescue events if needed
	_is_rescuing = event.is_rescuing()
	freeze = event.is_rescuing()
	collision_shape.disabled = event.is_rescuing()


func _on_orb_collected(_event: OrbCollectedEvent) -> void:
	# Apply ball slowdown if active
	var slowdown_strength := GameRules.get_ball_slowdown_on_orb()
	if slowdown_strength > 0.0 and GameRules.get_ball_slowdown_duration() > 0.0:
		start_slowdown(GameRules.get_ball_slowdown_duration(), slowdown_strength)


#endregion

#region Helpers

func load_constants() -> void:
	max_speed = GameRules.get_ball_max_speed()
	fall_speed = GameRules.get_ball_fall_speed()
	air_friction = GameRules.get_ball_air_friction()


func apply_easy_mode_settings() -> void:
	# Apply ball gravity scale from mode config
	if GameRules.get_ball_gravity_scale() > 0.0:
		gravity_scale = GameRules.get_ball_gravity_scale()

	# Apply ball scale from mode config
	if GameRules.get_ball_scale() > 0.0:
		scale = Vector2(GameRules.get_ball_scale(), GameRules.get_ball_scale())


## Returns whether the ball is currently in rescue mode.
func is_rescuing() -> bool:
	return _is_rescuing


#endregion
