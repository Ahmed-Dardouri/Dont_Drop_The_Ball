extends RigidBody2D

@export_range(0.0, 10000.0, 10.0) var max_speed := 1500.0

@export_range(0.0, 10000.0, 10.0) var fall_speed := 1500.0

@export_range(0.0, 100, 1) var air_friction := 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
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
