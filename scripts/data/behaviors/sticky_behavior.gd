class_name StickyBehavior extends OrbBehavior
## Behavior that dampens ball velocity on collision temporarily.
## Applies a "sticky head" effect that reduces bounce velocity.

#region Properties

## Velocity dampening factor (0.5 = 50% reduction).
@export var dampen_factor: float = 0.5

## Duration of the sticky effect in seconds.
@export var duration: float = 3.0

#endregion

#region OrbBehavior Implementation

func execute(_context: Dictionary) -> void:
	# Apply sticky effect through EffectManager
	EffectManager.apply_effect("sticky_head", dampen_factor, duration, _context.get("orb"))


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
