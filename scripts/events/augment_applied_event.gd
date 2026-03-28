class_name AugmentAppliedEvent extends Event
## Fired when an augment has been applied to the run.
## This happens after the player makes their choice.

## The augment that was applied
var _augment: Resource = null  # AugmentData

## The current stack count for this augment (1 if not stackable)
var _stack_count: int = 1


func _init(augment: Resource, stack_count: int = 1) -> void:
	_augment = augment
	_stack_count = stack_count


static func invoke(augment: Resource, stack_count: int = 1) -> void:
	Events.invoke(AugmentAppliedEvent.new(augment, stack_count))
