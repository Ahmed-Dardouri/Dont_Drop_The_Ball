class_name VortexChangedEvent extends Event
## Event fired when the vortex effect state changes.

var _has_vortex: bool


func _init(has_vortex: bool) -> void:
	_has_vortex = has_vortex


## Returns whether vortex is active.
func has_vortex() -> bool:
	return _has_vortex


## Fires the VortexChangedEvent.
static func invoke(has_vortex: bool) -> void:
	Events.invoke(VortexChangedEvent.new(has_vortex))
