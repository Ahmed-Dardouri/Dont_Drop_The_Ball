class_name BallRescueEvent extends Event
## Event fired when the ball is being rescued (moved to safety).
## Used to trigger visual effects and pause normal gameplay.

var _is_rescuing: bool


func _init(is_rescuing: bool) -> void:
	_is_rescuing = is_rescuing


## Returns whether rescue is active.
func is_rescuing() -> bool:
	return _is_rescuing


## Fires the BallRescueEvent.
static func invoke(is_rescuing: bool) -> void:
	Events.invoke(BallRescueEvent.new(is_rescuing))
