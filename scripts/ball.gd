extends RigidBody2D

@onready var shape_cast: ShapeCast2D = $ShapeCast2D 


var max_speed := 1500.0
var fall_speed := 1500.0
var air_friction := 1
var game_over : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_constants()
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



func _on_body_entered(body: Node) -> void:
	if body.name == "ground_static" && !game_over:
		game_over = true
		GameOverEvent.invoke()
		SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)


func load_constants():
	max_speed = Constants.ball_max_speed
	fall_speed = Constants.ball_fall_speed
	air_friction = Constants.ball_air_friction
	
func apply_constants():
	pass
