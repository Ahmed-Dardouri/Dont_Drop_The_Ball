class_name SoundEnableEvent extends Event

var _type: Enums.SoundType
var _enable: bool

func _init(type: Enums.SoundType, enable : bool) -> void:
	_enable = enable
	_type = type


static func invoke(type: Enums.SoundType, enable : bool):
	Events.invoke(SoundEnableEvent.new(type, enable))
