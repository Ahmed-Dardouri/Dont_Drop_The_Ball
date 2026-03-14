class_name LifeOrbBehavior extends OrbBehavior
## Behavior that grants an extra life (saves from game over once).
## Maximum of 1 life can be held at a time.

#region OrbBehavior Implementation

func execute(_context: Dictionary) -> void:
	# Only grant life if player doesn't already have one
	if not EffectManager.has_effect("has_life"):
		EffectManager.apply_effect("has_life", true, EffectManager.DURATION_PERMANENT)
		LifeChangedEvent.invoke(true)


func process(_orb: Node, _delta: float) -> void:
	pass  # No per-frame logic needed


func on_spawn(_orb: Node, _progress: float) -> void:
	pass  # No spawn logic needed

#endregion
