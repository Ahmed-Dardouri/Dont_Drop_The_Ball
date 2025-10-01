class_name ButtonEvent extends Event

var _type: Enums.MainButtonType

func _init(type: Enums.MainButtonType) -> void:
	_type = type


static func invoke(type: Enums.MainButtonType):
	Events.invoke(ButtonEvent.new(type))
