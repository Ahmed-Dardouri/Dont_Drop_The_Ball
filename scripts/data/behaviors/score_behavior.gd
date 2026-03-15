class_name ScoreBehavior extends OrbBehavior
## Behavior that awards score when an orb is collected.
## Uses ComboManager for combo bonuses and spawns floating score labels.
## Respects active score modifiers (double_value, score_multiplier).

#region Properties

## The base score awarded when this behavior executes.
@export var base_score: int = 1

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	# Use ComboManager to handle scoring with combo bonuses
	var result: Dictionary = ComboManager.add_orb_score(base_score)

	# Spawn floating score label at orb position
	var orb: Node = context.get("orb")
	if orb != null and orb is Node2D:
		var world_pos: Vector2 = orb.global_position
		_spawn_floating_score(orb, world_pos, result.base_score, result.combo_bonus, result.tier)


func _spawn_floating_score(orb: Node, world_pos: Vector2, base_score: int, combo_bonus: int, tier: int) -> void:
	# Find a suitable parent for the floating score (world or root)
	var parent: Node = orb.get_tree().current_scene
	if parent == null:
		return  # Skip floating score in test environments
	FloatingScore.spawn_at(parent, world_pos, base_score, combo_bonus, tier)


func process(_orb: Node, _delta: float) -> void:
	pass  # No per-frame logic needed


func on_spawn(_orb: Node, _progress: float) -> void:
	pass  # No spawn logic needed

#endregion
