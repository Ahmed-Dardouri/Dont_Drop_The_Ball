class_name PauseEvent extends Event

var _pause: bool = true

func _init(pause: bool) -> void:
	_pause = pause


static func invoke(_pause : bool):
	Events.invoke(PauseEvent.new(_pause))
