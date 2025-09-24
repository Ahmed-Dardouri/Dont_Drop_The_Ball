class_name OrbCollectedEvent extends Event

var _type: int

func _init(type: int) -> void:
	_type = type


static func invoke_orb_event(type : int):
	Events.invoke(OrbCollectedEvent.new(type))
