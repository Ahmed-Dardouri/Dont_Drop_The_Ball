class_name LifeOrbBehavior extends OrbBehavior
## Behavior that grants an extra life (saves from game over once).
## Maximum of 1 life can be held at a time.
## Life effect lasts 60 seconds or until consumed by dropping the ball.

#region Properties

## Duration of the life effect in seconds
const LIFE_DURATION: float = 60.0

## Texture for the collection visual effect
@export var effect_texture: Texture2D

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")

	# Spawn visual effect
	if orb != null and effect_texture != null:
		_spawn_effect(orb)

	# Only grant life if player doesn't already have one
	if not EffectManager.has_effect("has_life"):
		EffectManager.apply_effect("has_life", true, LIFE_DURATION)
		LifeChangedEvent.invoke(true)


func _spawn_effect(orb: Node) -> void:
	var center: Vector2 = orb.global_position if orb.has_method("get") else Vector2.ZERO

	var scene: PackedScene = load("res://scenes/life_orb_effect.tscn")
	var effect: LifeOrbEffect = scene.instantiate()

	effect.setup(effect_texture)
	effect.global_position = center

	# Add to the scene tree
	orb.get_tree().current_scene.add_child(effect)


func process(_orb: Node, _delta: float) -> void:
	pass  # No per-frame logic needed


func on_spawn(_orb: Node, _progress: float) -> void:
	pass  # No spawn logic needed

#endregion
