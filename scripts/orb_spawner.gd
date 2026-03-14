class_name OrbSpawner
extends Node2D

@export var generic_orb_scene: PackedScene

@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var orb_data_array: Array[OrbData] = []
@export var debug_force_orb_type: String = ""
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10

# Life orb settings
@export var life_orb_data: OrbData
@export var life_orb_spawn_interval: float = 60.0  # Spawn every 60 seconds

var _timer: Timer
var _life_orb_timer: Timer
var _game_time_elapsed: float = 0.0

# Spawn metrics
var _spawn_counts: Dictionary = {}  # orb_name -> count
var _total_spawns: int = 0


func _ready() -> void:
	# Set up regular orb spawn timer
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)

	# Set up life orb timer (starts after first interval, not at game start)
	if life_orb_data != null:
		_life_orb_timer = Timer.new()
		_life_orb_timer.wait_time = life_orb_spawn_interval
		_life_orb_timer.autostart = true
		_life_orb_timer.one_shot = false
		_life_orb_timer.timeout.connect(_on_life_orb_timeout)
		add_child(_life_orb_timer)

	# Initialize spawn counts
	for data: OrbData in orb_data_array:
		_spawn_counts[data.display_name] = 0
	if life_orb_data != null:
		_spawn_counts[life_orb_data.display_name] = 0


func _process(delta: float) -> void:
	_game_time_elapsed += delta


func _on_timeout() -> void:
	# Don't spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return

	var orb := _spawn_orb()
	if orb == null:
		return

	_position_orb(orb)
	add_child(orb)


func _on_life_orb_timeout() -> void:
	# Skip spawning at game start (timer fires immediately with autostart)
	if _game_time_elapsed < life_orb_spawn_interval:
		return

	if life_orb_data == null:
		return

	# Don't spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return

	var orb := OrbAdapter.create_orb_from_data(generic_orb_scene, life_orb_data)
	_record_spawn(life_orb_data.display_name)
	_position_orb(orb)
	add_child(orb)


func _position_orb(orb: Node) -> void:
	# Position within zone relative to spawner position
	var pos = Vector2(
		randf_range(spawn_zone.position.x, spawn_zone.position.x + spawn_zone.size.x),
		randf_range(spawn_zone.position.y, spawn_zone.position.y + spawn_zone.size.y)
	)
	orb.global_position = pos


func _spawn_orb() -> Node:
	if orb_data_array.is_empty():
		return null

	# Debug override: force specific orb type by name
	if not debug_force_orb_type.is_empty():
		for data: OrbData in orb_data_array:
			if data.display_name == debug_force_orb_type:
				_record_spawn(data.display_name)
				return OrbAdapter.create_orb_from_data(generic_orb_scene, data)
		return null  # Debug type not found

	# Weighted random selection
	var data := _get_weighted_random_orb()
	if data == null:
		return null

	_record_spawn(data.display_name)
	return OrbAdapter.create_orb_from_data(generic_orb_scene, data)


func _get_weighted_random_orb() -> OrbData:
	if orb_data_array.is_empty():
		return null

	# Calculate total weight
	var total_weight: float = 0.0
	for data: OrbData in orb_data_array:
		total_weight += data.spawn_weight

	if total_weight <= 0.0:
		# Fallback to uniform random if all weights are 0
		var idx := randi() % orb_data_array.size()
		return orb_data_array[idx]

	# Weighted random selection
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0

	for data: OrbData in orb_data_array:
		cumulative += data.spawn_weight
		if roll <= cumulative:
			return data

	# Fallback (shouldn't reach here)
	return orb_data_array.back()


func _record_spawn(orb_name: String) -> void:
	if not _spawn_counts.has(orb_name):
		_spawn_counts[orb_name] = 0
	_spawn_counts[orb_name] += 1
	_total_spawns += 1


## Prints spawn metrics for rarity testing and analysis.
func print_spawn_metrics() -> void:
	print("=== ORB SPAWN METRICS ===")
	print("Total orbs spawned: %d" % _total_spawns)
	print("Game time elapsed: %.1f seconds" % _game_time_elapsed)
	print("\nPer-type breakdown:")
	for orb_name: String in _spawn_counts.keys():
		var count: int = _spawn_counts[orb_name]
		var percentage: float = 0.0
		if _total_spawns > 0:
			percentage = (float(count) / float(_total_spawns)) * 100.0
		print("  %s: %d (%.1f%%)" % [orb_name, count, percentage])
	print("=========================")


## Returns the spawn count for a specific orb type.
func get_spawn_count(orb_name: String) -> int:
	if _spawn_counts.has(orb_name):
		return _spawn_counts[orb_name]
	return 0


## Returns total spawns across all orb types.
func get_total_spawns() -> int:
	return _total_spawns


## Returns a copy of the spawn counts dictionary.
func get_all_spawn_counts() -> Dictionary:
	return _spawn_counts.duplicate()
