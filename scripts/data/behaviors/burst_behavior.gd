class_name BurstBehavior extends OrbBehavior
## Behavior that clears nearby orbs within a radius and awards score for each.
## Creates an explosive chain collection effect.

#region Properties

## Radius in pixels to search for nearby orbs.
@export var radius: float = 150.0

## Bonus score per orb cleared (in addition to their own score).
@export var bonus_per_orb: int = 2

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")
	if orb == null:
		return

	var center: Vector2 = orb.global_position if orb.has_method("get") else Vector2.ZERO

	# Find all orbs in the "orbs" group within radius
	var all_orbs: Array[Node] = orb.get_tree().get_nodes_in_group("orbs")
	var collected_count: int = 0

	for nearby_orb: Node in all_orbs:
		if nearby_orb == orb:
			continue  # Skip self

		if not nearby_orb.is_inside_tree():
			continue

		var distance: float = center.distance_to(nearby_orb.global_position)
		if distance <= radius:
			# Award bonus score for this orb
			ScoreManager.add_score(bonus_per_orb)
			collected_count += 1
			# Queue free the nearby orb
			nearby_orb.queue_free()

	# Bonus for chain reaction
	if collected_count > 0:
		ScoreManager.add_score(collected_count * bonus_per_orb)


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
