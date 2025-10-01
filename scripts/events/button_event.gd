class_name ButtonEvent extends Event

var _type: Enums.ButtonType

func _init(type: Enums.ButtonType) -> void:
	_type = type


static func invoke(type: Enums.ButtonType):
	Events.invoke(ButtonEvent.new(type))
