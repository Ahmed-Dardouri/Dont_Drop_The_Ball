class_name SoundPlayEvent extends Event

var _type: Enums.SoundType
var _sound: Enums.Sounds

func _init(type: Enums.SoundType, sound : Enums.Sounds) -> void:
	_sound = sound
	_type = type


static func invoke(type: Enums.SoundType, sound : Enums.Sounds):
	Events.invoke(SoundPlayEvent.new(type, sound))
