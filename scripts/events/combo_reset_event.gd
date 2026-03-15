class_name ComboResetEvent extends Event
## Event fired when the combo meter resets to zero.
## Typically fires on game over or when explicitly resetting.


## Fires the ComboResetEvent.
static func invoke() -> void:
	Events.invoke(ComboResetEvent.new())
