class_name SoundEnableEvent extends Event

var _type: Enums.SoundType
var _command: Enums.SoundCmd

func _init(type: Enums.SoundType, command: Enums.SoundCmd) -> void:
	_command = command
	_type = type


static func invoke(type: Enums.SoundType, command: Enums.SoundCmd):
	Events.invoke(SoundEnableEvent.new(type, command))
