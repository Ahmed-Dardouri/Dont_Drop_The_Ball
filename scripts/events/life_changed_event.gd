class_name LifeChangedEvent extends Event
## Event fired when the player gains or loses a life.

var _has_life: bool


func _init(has_life: bool) -> void:
	_has_life = has_life


## Returns whether the player now has a life.
func has_life() -> bool:
	return _has_life


## Fires the LifeChangedEvent.
static func invoke(has_life: bool) -> void:
	Events.invoke(LifeChangedEvent.new(has_life))
