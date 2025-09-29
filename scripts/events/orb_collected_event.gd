class_name OrbCollectedEvent extends Event

var _props: OrbProps

func _init(props: OrbProps) -> void:
	_props = props


static func invoke_orb_event(props : OrbProps):
	Events.invoke(OrbCollectedEvent.new(props))
