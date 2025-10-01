class_name VolumeSetEvent extends Event

var _type: Enums.SoundType
var _volume: float

func _init(type: Enums.SoundType, volume : float) -> void:
	_volume = volume
	_type = type


static func invoke(type: Enums.SoundType, volume : float):
	Events.invoke(VolumeSetEvent.new(type, volume))
