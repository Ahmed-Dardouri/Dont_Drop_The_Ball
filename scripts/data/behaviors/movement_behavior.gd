class_name MovementBehavior extends OrbBehavior
## Behavior that applies movement patterns to an orb during its lifetime.

#region Properties

## Type of movement: "drift", "bounce", "sine"
@export var movement_type: String = "sine"

## Speed of movement.
@export var speed: float = 100.0

## Amplitude for oscillating movement (pixels).
@export var amplitude: float = 50.0

## Frequency for oscillating movement.
@export var frequency: float = 2.0

#endregion

#region Private Variables

var _time_elapsed: float = 0.0
var _initial_position: Vector2 = Vector2.ZERO
var _initialized: bool = false

#endregion

#region OrbBehavior Implementation

func process(orb: Node, delta: float) -> void:
	if not _initialized:
		_initial_position = orb.global_position if orb.has_method("get") else Vector2.ZERO
		_initialized = true

	_time_elapsed += delta

	match movement_type:
		"sine":
			# Horizontal sine wave oscillation
			var offset: float = sin(_time_elapsed * frequency) * amplitude
			orb.global_position.x = _initial_position.x + offset
		"drift":
			# Constant horizontal drift
			orb.global_position.x += speed * delta
		"bounce":
			# Bouncing motion
			var offset: float = abs(sin(_time_elapsed * frequency)) * amplitude
			orb.global_position.y = _initial_position.y - offset


func execute(_context: Dictionary) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
