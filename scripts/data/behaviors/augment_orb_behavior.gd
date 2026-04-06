class_name AugmentOrbBehavior extends OrbBehavior
## Behavior that triggers augment selection when collected.
## Pauses gameplay, shows 3 augment choices, applies selection, then resumes.

#region Properties

## Texture for the collection visual effect (optional)
@export var effect_texture: Texture2D = null

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")

	# Spawn visual effect
	if orb != null and effect_texture != null:
		_spawn_effect(orb)

	# Get 3 random augment choices
	var choices: Array = AugmentManager.get_random_choices()

	# Trigger augment selection - this will pause the game
	AugmentSelectionStartedEvent.invoke(choices)


func _spawn_effect(orb: Node) -> void:
	var center: Vector2 = orb.global_position if orb.has_method("get") else Vector2.ZERO

	const LIFE_ORB_EFFECT_SCENE: PackedScene = preload("res://scenes/life_orb_effect.tscn")

	var scene: PackedScene = LIFE_ORB_EFFECT_SCENE
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
