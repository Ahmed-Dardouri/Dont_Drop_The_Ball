class_name LineClearBehavior extends OrbBehavior
## Behavior that creates a horizontal wave expanding from the orb's position.
## The wave collects any orb it touches as it expands.

#region Properties

## Direction of the wave: "horizontal" (vertical removed for now)
@export var direction: String = "horizontal"

## How far the wave travels in each direction (pixels from center).
@export var range_distance: float = 500.0

## Bonus score per orb collected by the wave.
@export var bonus_per_orb: int = 4

## Texture for the wave visual effect.
@export var wave_texture: Texture2D

## How long the wave lasts in seconds.
@export var wave_duration: float = 0.5

#endregion

#region OrbBehavior Implementation

func execute(context: Dictionary) -> void:
	var orb: Node = context.get("orb")
	if orb == null:
		return

	if direction == "horizontal":
		_spawn_horizontal_wave(orb)


func _spawn_horizontal_wave(orb: Node) -> void:
	var center: Vector2 = orb.global_position if orb.has_method("get") else Vector2.ZERO

	var scene: PackedScene = load("res://scenes/horizontal_wave.tscn")
	var wave: HorizontalWave = scene.instantiate()

	wave.setup(wave_texture, range_distance, bonus_per_orb)
	wave.duration = wave_duration
	wave.global_position = center

	# Add to the scene tree
	orb.get_tree().current_scene.add_child(wave)


func process(_orb: Node, _delta: float) -> void:
	pass


func on_spawn(_orb: Node, _progress: float) -> void:
	pass

#endregion
