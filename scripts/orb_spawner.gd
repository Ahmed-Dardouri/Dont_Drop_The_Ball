extends Node2D

@export var generic_orb_scene: PackedScene

@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var orb_props: Array[OrbProps] = []   # Kept for backward compatibility
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10

@export var use_registry: bool = true  # Toggle between old and new system

var _timer: Timer


func _ready() -> void:
	# Initialize the orb registry if using new system
	if use_registry:
		OrbRegistry.initialize()

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

	var orb: Node

	if use_registry:
		orb = _spawn_from_registry()
	else:
		orb = _spawn_from_props()

	if orb == null:
		return

	# Position within zone relative to spawner position
	var pos = Vector2(
		randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
		randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
	)

	orb.global_position = pos
	add_child(orb)


func _spawn_from_registry() -> Node:
	var def := OrbRegistry.get_weighted_random()
	if def == null:
		return null

	# Create OrbProps from definition for backward compatibility with GenericOrb
	var props := OrbProps.new()
	props.Type = _type_name_to_orb_type(def.type_name)

	var orb := generic_orb_scene.instantiate()
	orb.set_type(props)
	# Store definition reference for future migration
	orb.set_meta("orb_definition", def)

	return orb


func _spawn_from_props() -> Node:
	if orb_props.is_empty():
		return null

	var props := orb_props[randi() % orb_props.size()]
	return create_orb_copy(props)


func create_orb_copy(props: OrbProps) -> Node:
	var orb_cpy = generic_orb_scene.instantiate()
	orb_cpy.set_type(props)
	return orb_cpy


## Map OrbDefinition type_name to legacy OrbType enum
func _type_name_to_orb_type(type_name: StringName) -> Enums.OrbType:
	match type_name:
		&"blue":
			return Enums.OrbType.BLUE
		&"red":
			return Enums.OrbType.RED
		&"half_solid":
			return Enums.OrbType.HALF_SOLID
		_:
			return Enums.OrbType.BLUE  # Default fallback
