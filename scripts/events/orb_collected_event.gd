class_name OrbCollectedEvent extends Event
## Event fired when an orb is collected.
## Passes OrbData so listeners can access orb properties.

var _orb_data: OrbData

func _init(orb_data: OrbData) -> void:
	_orb_data = orb_data


## Returns the OrbData for the collected orb.
func get_orb_data() -> OrbData:
	return _orb_data


## Fires the OrbCollectedEvent with the given OrbData.
static func invoke(orb_data: OrbData) -> void:
	if PauseEvent.state == false:
		Events.invoke(OrbCollectedEvent.new(orb_data))
