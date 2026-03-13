class_name BurstBehavior extends OrbBehavior
## Behavior that spawns an expanding explosion circle which collects nearby orbs.
## Creates a visual burst effect with proper orb collection.

#region Properties

## Radius in pixels for the explosion circle.
@export var radius: float = 150.0

## Bonus score per orb cleared (in addition to their own score).
@export var bonus_per_orb: int = 2

## Texture for the explosion circle visual.
@export var explosion_texture: Texture2D

## How long the explosion lasts in seconds.
@export var explosion_duration: float = 0.3

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")
	if orb == null:
		return

	var center: Vector2 = orb.global_position if orb.has_method("get") else Vector2.ZERO

	# Spawn the explosion circle
	_spawn_explosion(orb, center)


func _spawn_explosion(orb: Node, center: Vector2) -> void:
	var scene: PackedScene = load("res://scenes/explosion_circle.tscn")
	var explosion: ExplosionCircle = scene.instantiate()

	explosion.setup(radius, explosion_texture)
	explosion.duration = explosion_duration
	explosion.global_position = center

	# Add to the same parent as the orb (usually the scene tree)
	orb.get_tree().current_scene.add_child(explosion)


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
