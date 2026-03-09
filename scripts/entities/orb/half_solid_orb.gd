class_name HalfSolidOrb extends Orb
## Half-solid orb that bounces the ball on first hit, collects on second.

## Tracks whether the ball has hit this orb once
var _was_hit: bool = false


func _ready() -> void:
	super._ready()
	add_to_group("half_solid")


## Handle collision with ball: bounce on first hit, collect on second.
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("ball"):
		return

	if not _was_hit:
		_was_hit = true
		_on_ball_collision(body)
	else:
		collect()


## Apply bounce effect to the ball (reduce velocity to 1/3).
func _on_ball_collision(ball: Node2D) -> void:
	if "linear_velocity" in ball:
		ball.linear_velocity /= 3
