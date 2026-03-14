class_name SpawnSpeedupBehavior extends OrbBehavior
## Behavior that doubles the orb spawn rate for a duration.
## Uses EffectManager to track the speedup state.

#region Properties

## Duration of the spawn speedup effect in seconds
@export var speedup_duration: float = 30.0

## Speed multiplier (2.0 = double speed, halved interval)
@export var speed_multiplier: float = 2.0

#endregion

#region OrbBehavior Implementation

func execute(_context: Dictionary) -> void:
	# Apply the spawn speedup effect
	EffectManager.apply_effect("spawn_speedup", speed_multiplier, speedup_duration)


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
