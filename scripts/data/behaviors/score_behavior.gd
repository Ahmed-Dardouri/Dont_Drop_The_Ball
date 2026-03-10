class_name ScoreBehavior extends OrbBehavior
## Behavior that awards score when an orb is collected.
## Respects active score modifiers (double_value, score_multiplier).

#region Properties

## The base score awarded when this behavior executes.
@export var base_score: int = 1

#endregion

#region OrbBehavior Implementation

func execute(_context: Dictionary) -> void:
	var score: int = base_score

	# Apply double value if active (doubles the score)
	if EffectManager.has_effect("double_value"):
		score *= 2

	# Apply score multiplier if active
	var multiplier: Variant = EffectManager.get_effect_value("score_multiplier")
	if multiplier != null:
		score = int(score * float(multiplier))

	ScoreManager.add_score(score)


func process(_orb: Node, _delta: float) -> void:
	pass  # No per-frame logic needed


func on_spawn(_orb: Node, _progress: float) -> void:
	pass  # No spawn logic needed

#endregion
