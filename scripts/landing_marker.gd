extends Node2D
## Visual indicator that shows where the ball will land.
## Only visible in modes with show_landing_marker enabled.

#region Configuration

## The ball to track (set by parent or auto-detected)
@export var ball: RigidBody2D

## Color of the landing marker
@export var marker_color: Color = Color(1, 1, 0, 0.5)

## Size of the marker
@export var marker_size: float = 30.0

## How far ahead to predict (in seconds)
@export var prediction_time: float = 2.0

## Ground Y position (auto-detected if not set)
@export var ground_y: float = 700.0

#endregion

#region Private

var _marker: Polygon2D = null
var _enabled: bool = false

#endregion


func _ready() -> void:
	# Auto-detect ball if not set
	if ball == null:
		var parent = get_parent()
		if parent is RigidBody2D and parent.is_in_group("ball"):
			ball = parent

	# Create the marker visual
	_create_marker()

	# Check if enabled for current mode
	_update_enabled()


func _process(_delta: float) -> void:
	if not _enabled or ball == null:
		visible = false
		return

	# Calculate landing position
	var landing_pos: Variant = _predict_landing()

	if landing_pos != null and landing_pos is Vector2:
		visible = true
		global_position = landing_pos
		global_rotation = 0  # Keep marker upright
	else:
		visible = false


func _create_marker() -> void:
	_marker = Polygon2D.new()

	# Create a simple circle/indicator shape
	var points: PackedVector2Array = []
	var segments: int = 16

	for i in range(segments):
		var angle: float = TAU * i / segments
		var x: float = cos(angle) * marker_size
		var y: float = sin(angle) * marker_size
		points.append(Vector2(x, y))

	_marker.polygon = points
	_marker.color = marker_color
	_marker.z_index = -10  # Behind most game elements

	add_child(_marker)
	visible = false


func _update_enabled() -> void:
	_enabled = GameRules.get_show_landing_marker()


## Predict where the ball will land using physics simulation
func _predict_landing() -> Variant:
	if ball == null:
		return null

	# Get ball's current state
	var pos: Vector2 = ball.global_position
	var vel: Vector2 = ball.linear_velocity
	var gravity_setting: Variant = ProjectSettings.get_setting("physics/2d/default_gravity")
	var gravity: float = ball.gravity_scale * float(gravity_setting)

	# If ball is moving up, wait until it starts falling
	if vel.y < 0:
		# Calculate time to reach apex
		var time_to_apex: float = -vel.y / gravity
		# Move to apex position
		pos.y += vel.y * time_to_apex + 0.5 * gravity * time_to_apex * time_to_apex
		pos.x += vel.x * time_to_apex
		vel.y = 0  # At apex, vertical velocity is 0

	# Calculate time to fall to ground
	if gravity <= 0:
		return null

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
