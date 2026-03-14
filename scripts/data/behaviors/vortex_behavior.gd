class_name VortexBehavior extends OrbBehavior
## Behavior that creates a vortex aura around the ball.
## The vortex collects orbs in an expanded range around the ball.

#region Properties

## Duration of the vortex effect in seconds
@export var vortex_duration: float = 30

## Radius of the vortex collection area
@export var vortex_radius: float = 100.0

## Scale multiplier for the vortex visual (final size)
@export var vortex_scale: float = 1.0

## Texture for the vortex visual effect
@export var vortex_texture: Texture2D

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")
	if orb == null:
		return

	_spawn_vortex(orb)


func _spawn_vortex(orb: Node) -> void:
	# Remove any existing vortex effect first
	var existing_vortexes := orb.get_tree().get_nodes_in_group("vortex_effect")
	for vortex in existing_vortexes:
		vortex.queue_free()

	var scene: PackedScene = load("res://scenes/vortex_effect.tscn")
	var vortex: VortexEffect = scene.instantiate()

	vortex.add_to_group("vortex_effect")
	vortex.setup(vortex_texture, vortex_radius, vortex_duration, vortex_scale)

	# Find the ball and add vortex to scene
	var balls := orb.get_tree().get_nodes_in_group("ball")
	if balls.size() > 0:
		var ball: Node2D = balls[0]
		vortex.global_position = ball.global_position
		orb.get_tree().current_scene.add_child(vortex)

	# Emit event for UI
	VortexChangedEvent.invoke(true)


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
