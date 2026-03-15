class_name MeterChangedEvent extends Event
## Event fired when the bonus meter value changes.
## Passes the current meter value and tier index for UI updates.

var _meter_value: float
var _tier_index: int


func _init(meter_value: float, tier_index: int) -> void:
	_meter_value = meter_value
	_tier_index = tier_index


## Returns the current meter value (0.0 to MAX_METER_VALUE).
func get_meter_value() -> float:
	return _meter_value


## Returns the current tier index (0-6).
func get_tier_index() -> int:
	return _tier_index


## Fires the MeterChangedEvent with the given meter value and tier.
static func invoke(meter_value: float, tier_index: int) -> void:
	Events.invoke(MeterChangedEvent.new(meter_value, tier_index))
