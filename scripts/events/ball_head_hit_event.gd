class_name BallHeadHitEvent extends Event
## Event fired when the ball hits the player's head.
## Used to reset combo counters and trigger visual feedback.


## Fires the BallHeadHitEvent.
static func invoke() -> void:
	Events.invoke(BallHeadHitEvent.new())
