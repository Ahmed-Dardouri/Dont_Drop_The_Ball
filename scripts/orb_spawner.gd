extends Node2D

@export var generic_orb_scene: PackedScene

@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var orb_props: Array[OrbProps] = []
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10

var _timer: Timer


func _ready() -> void:
	# Set up timer
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)


func _on_timeout() -> void:
	# Don't spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return

	var orb := _spawn_from_props()
	if orb == null:
		return

	# Position within zone relative to spawner position
	var pos = Vector2(
		randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
		randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
	)

	orb.global_position = pos
	add_child(orb)


func _spawn_from_props() -> Node:
	if orb_props.is_empty():
		return null

	var props := orb_props[randi() % orb_props.size()]
	return create_orb_copy(props)


func create_orb_copy(props: OrbProps) -> Node:
	var orb_cpy = generic_orb_scene.instantiate()
	orb_cpy.set_type(props)
	return orb_cpy
