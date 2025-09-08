extends RigidBody2D

@onready var shape_cast: ShapeCast2D = $ShapeCast2D 

@export var skin := 0.5

@export_range(0.0, 10000.0, 10.0) var max_speed := 1500.0
@export_range(0.0, 10000.0, 10.0) var fall_speed := 1500.0
@export_range(0.0, 100, 1) var air_friction := 1

var _prev_pos := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prev_pos = global_position
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	clamp_max_speed()
	clamp_fall_speed()
	apply_air_friction()
			

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	check_CCD(state)
	# check_CCD_aux(state)

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


func check_CCD(state: PhysicsDirectBodyState2D):
	var dt := state.step
	var curr := state.transform.origin
	var vel := state.linear_velocity

	var space := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(_prev_pos, curr)
	params.exclude = [self]                 # don't hit self
	params.collision_mask = collision_mask  # respect your masks
	
	var hit := space.intersect_ray(params)
	
	if hit:
		# Place at time of impact (hit.position) with small separation along normal
		var p = hit.position - hit.normal * skin
		state.transform.origin = p

	_prev_pos = state.transform.origin
		
func check_CCD_aux(state: PhysicsDirectBodyState2D) -> void:
	var dt := state.step
	var curr := state.transform.origin

	# sweep from previous center -> current center (prev→curr)
	shape_cast.global_position = _prev_pos
	shape_cast.target_position = shape_cast.to_local(curr)
	# ensure mask matches what the ball should hit
	shape_cast.collision_mask = collision_mask
	shape_cast.exclude_parent = true
	shape_cast.force_shapecast_update()

	if shape_cast.is_colliding():
		var p := shape_cast.get_collision_point(0)
		var n := shape_cast.get_collision_normal(0)
		# place at impact with a tiny skin; the shape-cast already accounts for radius
		state.transform.origin = p - n * skin

	_prev_pos = state.transform.origin
	pass
