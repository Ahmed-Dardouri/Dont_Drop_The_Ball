class_name TimedModifierBehavior extends OrbBehavior
## Behavior that applies timed effects through the EffectManager.
## Supports configurable effect ID, value, and and duration.

#region Properties

## The effect to apply. Empty string means no effect will be applied.
@export var effect_id: String = ""

## The value passed to the effect.
@export var value: float = 1.0

## Duration of the effect in seconds. Use -1 for permanent effects.
@export var duration: float = 10.0

#endregion

#region OrbBehavior Implementation

func execute(_context: Dictionary) -> void:
	if effect_id.is_empty():
		return

	EffectManager.apply_effect(effect_id, value, duration, _context.get("orb"))


#endregion
