class_name AugmentChosenEvent extends Event
## Fired when the player selects an augment from the choice UI.

## The augment that was chosen
var _augment: Resource = null  # AugmentData


func _init(augment: Resource) -> void:
	_augment = augment


static func invoke(augment: Resource) -> void:
	Events.invoke(AugmentChosenEvent.new(augment))
