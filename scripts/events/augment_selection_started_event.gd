class_name AugmentSelectionStartedEvent extends Event
## Fired when augment selection UI opens.
## Gameplay should pause when this event is received.

## The 3 augment choices presented to the player
var _choices: Array = []  # Array of AugmentData resources


func _init(choices: Array) -> void:
	_choices = choices


static func invoke(choices: Array) -> void:
	Events.invoke(AugmentSelectionStartedEvent.new(choices))
