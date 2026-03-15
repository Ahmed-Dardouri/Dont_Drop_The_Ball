class_name TierChangedEvent extends Event
## Event fired when the bonus tier changes.
## Passes the old and new tier indices for UI feedback and sound effects.

var _old_tier: int
var _new_tier: int


func _init(old_tier: int, new_tier: int) -> void:
	_old_tier = old_tier
	_new_tier = new_tier


## Returns the previous tier index.
func get_old_tier() -> int:
	return _old_tier


## Returns the new current tier index.
func get_new_tier() -> int:
	return _new_tier


## Returns true if the tier increased (level up).
func is_tier_up() -> bool:
	return _new_tier > _old_tier


## Returns true if the tier decreased (drain).
func is_tier_down() -> bool:
	return _new_tier < _old_tier


## Fires the TierChangedEvent with the given old and new tiers.
static func invoke(old_tier: int, new_tier: int) -> void:
	Events.invoke(TierChangedEvent.new(old_tier, new_tier))
