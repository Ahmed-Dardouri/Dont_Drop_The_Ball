class_name PauseEvent extends Event

static var state = false

var _pause: bool = true

func _init(pause: bool) -> void:
	_pause = pause


static func invoke(pause : bool):
	state = pause
	Events.invoke(PauseEvent.new(pause))
