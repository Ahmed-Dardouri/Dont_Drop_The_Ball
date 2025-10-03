class_name WorldButtonEvent extends Event

var _type: Enums.WorldButtonType

func _init(type: Enums.WorldButtonType) -> void:
	_type = type


static func invoke(type: Enums.WorldButtonType):
	Events.invoke(WorldButtonEvent.new(type))
