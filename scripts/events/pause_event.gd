class_name PauseEvent extends Event

## Backward-compatible state property that delegates to GameState.
## Setting this updates GameState.is_paused.
## Getting this returns GameState.is_paused.
static var state: bool:
	get: return GameState.is_paused
	set(value): GameState.is_paused = value

var _pause: bool = true

func _init(pause: bool) -> void:
	_pause = pause


## Invoke a pause event. Updates GameState and fires the event on the bus.
static func invoke(pause: bool) -> void:
	GameState.is_paused = pause
	Events.invoke(PauseEvent.new(pause))
