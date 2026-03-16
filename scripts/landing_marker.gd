extends Node2D
## Visual indicator that shows where the ball will land.
## Only visible in modes with show_landing_marker enabled.

#region Configuration

## The ball to track (set by parent or auto-detected)
@export var ball: RigidBody2D

## Color of the landing marker
@export var marker_color: Color = Color(1, 0.8, 0.2, 0.7)

## Size of the marker
@export var marker_size: float = 25.0

## How far ahead to predict (in seconds)
@export var prediction_time: float = 3.0

## Ground Y position
@export var ground_y: float = 640.0

#endregion

#region Private

var _marker: Polygon2D = null
var _enabled: bool = false
var _ball_detected: bool = false

#endregion


func _ready() -> void:
	# Auto-detect ball if not set
	if ball == null:
		var parent = get_parent()
		if parent is RigidBody2D and parent.is_in_group("ball"):
			ball = parent
			_ball_detected = true

	# Create the marker visual
	_create_marker()


func _process(_delta: float) -> void:
	# Check if enabled for current mode (mode may start after _ready)
	_enabled = GameRules.get_show_landing_marker()

	if not _enabled or ball == null:
		visible = false
		return

	# Calculate landing position
	var landing_pos: Variant = _predict_landing()

	if landing_pos != null and landing_pos is Vector2:
		global_position = landing_pos
		global_rotation = 0  # Keep marker upright
		visible = true
		_marker.color = marker_color  # Ensure color is applied
	else:
		visible = false


func _create_marker() -> void:
	_marker = Polygon2D.new()

	# Create a ring shape (hollow circle) for better visibility
	var points: PackedVector2Array = []
	var segments: int = 24
	var inner_radius: float = marker_size * 0.6
	var outer_radius: float = marker_size

	# Create ring by drawing outer circle then inner circle reversed
	for i in range(segments):
		var angle: float = TAU * i / segments
		points.append(Vector2(cos(angle) * outer_radius, sin(angle) * outer_radius))
	for i in range(segments - 1, -1, -1):
		var angle: float = TAU * i / segments
		points.append(Vector2(cos(angle) * inner_radius, sin(angle) * inner_radius))

	_marker.polygon = points
	_marker.color = marker_color
	_marker.z_index = 100  # In front of most game elements
	_marker.z_as_relative = false

	add_child(_marker)
	visible = false


## Predict where the ball will land using physics simulation
func _predict_landing() -> Variant:
	if ball == null:
		return null

	# Get ball's current state
	var pos: Vector2 = ball.global_position
	var vel: Vector2 = ball.linear_velocity
	var gravity_setting: Variant = ProjectSettings.get_setting("physics/2d/default_gravity")
	var gravity: float = ball.gravity_scale * float(gravity_setting)

	# If gravity is 0 or very small, can't predict
	if gravity <= 0:
		return null

	# If ball is moving up, calculate time to apex and position at apex
	if vel.y < 0:
		# Calculate time to reach apex
		var time_to_apex: float = -vel.y / gravity
		# Move to apex position
		pos.y += vel.y * time_to_apex + 0.5 * gravity * time_to_apex * time_to_apex
		pos.x += vel.x * time_to_apex
		# At apex, vertical velocity is 0

	# Calculate time to fall to ground from current (or apex) position
	var distance_to_fall: float = ground_y - pos.y
	if distance_to_fall <= 0:
		return null  # Already at or below ground

	var time_to_land: float = sqrt(2 * distance_to_fall / gravity)

	# Limit prediction time
	time_to_land = min(time_to_land, prediction_time)

	# Calculate landing position
	var landing_x: float = pos.x + vel.x * time_to_land
	var landing_y: float = ground_y

	return Vector2(landing_x, landing_y)
