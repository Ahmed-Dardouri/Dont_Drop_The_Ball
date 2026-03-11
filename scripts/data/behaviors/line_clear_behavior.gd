class_name LineClearBehavior extends OrbBehavior
## Behavior that clears orbs in a vertical or horizontal line from the orb's position.

#region Properties

## Direction of the line clear: "vertical" or "horizontal"
@export var direction: String = "vertical"

## How far in each direction to clear (pixels from center).
@export var range_distance: float = 500.0

## Bonus score per orb cleared.
@export var bonus_per_orb: int = 3

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")
	if orb == null:
		return

	var center: Vector2 = orb.global_position if orb.has_method("get") else Vector2.ZERO

	# Find all orbs in the "orbs" group
	var all_orbs: Array[Node] = orb.get_tree().get_nodes_in_group("orbs")
	var collected_count: int = 0

	for nearby_orb: Node in all_orbs:
		if nearby_orb == orb:
			continue  # Skip self

		if not nearby_orb.is_inside_tree():
			continue

		var orb_pos: Vector2 = nearby_orb.global_position
		var should_clear: bool = false

		if direction == "vertical":
			# Check if within vertical line (same x, within y range)
			if abs(orb_pos.x - center.x) < 50.0 and abs(orb_pos.y - center.y) <= range_distance:
				should_clear = true
		elif direction == "horizontal":
			# Check if within horizontal line (same y, within x range)
			if abs(orb_pos.y - center.y) < 50.0 and abs(orb_pos.x - center.x) <= range_distance:
				should_clear = true

		if should_clear:
			ScoreManager.add_score(bonus_per_orb)
			collected_count += 1
			nearby_orb.queue_free()

	# Bonus for chain
	if collected_count > 0:
		ScoreManager.add_score(collected_count * bonus_per_orb)


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
