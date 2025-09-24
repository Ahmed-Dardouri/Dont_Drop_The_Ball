extends Node2D

@export var generic_orb_scene: PackedScene

@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var orb_props: Array[OrbProps] = []   # drag your orb scenes here
@export var spawn_interval: float = 2.0           # seconds between spawns
@export var max_orbs: int = 10                    # limit active orbs (0 = unlimited)

var _timer: Timer

func _ready() -> void:
	# Set up timer
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
	
	

func _on_timeout() -> void:
	# Don’t spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return
	

	if orb_props.is_empty():
		return
	
	# Pick random orb scene
	var props:= orb_props[randi() % orb_props.size()]
	

	# Position within zone relative to spawner position
	var pos = Vector2(
		randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
		randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
	)
	var orb = create_orb_copy(props)
	orb.global_position = pos
	add_child(orb) 


func create_orb_copy(props: OrbProps) -> Node:
	
	var orb_cpy = generic_orb_scene.instantiate()
	print(orb_cpy)
	orb_cpy.set_type(props)
	return orb_cpy
