class_name OrbSpawner
extends Node2D

@export var generic_orb_scene: PackedScene

@export var spawn_zone: Rect2 = Rect2(Vector2(-200, -200), Vector2(400, 400))
@export var orb_data_array: Array[OrbData] = []
@export var debug_force_orb_type: String = ""
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10

# Progression settings
@export var progression_config: ProgressionConfig

# Life orb settings
@export var life_orb_data: OrbData
@export var life_orb_first_spawn_delay: float = 30.0  # First spawn after 30 seconds
@export var life_orb_spawn_interval: float = 90.0  # Spawn every 90 seconds after first

# Augment orb settings
@export var augment_orb_data: OrbData
@export var augment_orb_first_spawn_delay: float = 60.0  # First spawn after 60 seconds
@export var augment_orb_spawn_interval: float = 60.0  # Spawn every 60 seconds after first

var _timer: Timer
var _game_time_elapsed: float = 0.0
var _life_orb_next_spawn_time: float = 0.0
var _augment_orb_next_spawn_time: float = 0.0
var _debug_print_timer: float = 0.0

# Spawn metrics
var _spawn_counts: Dictionary = {}  # orb_name -> count
var _total_spawns: int = 0


func _ready() -> void:
	# Set up regular orb spawn timer
	_timer = Timer.new()
	_timer.wait_time = _get_current_spawn_interval()
	_timer.autostart = true
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)

	# Initialize spawn counts
	for data: OrbData in orb_data_array:
		_spawn_counts[data.display_name] = 0
	if life_orb_data != null:
		_spawn_counts[life_orb_data.display_name] = 0
		# First life orb spawns after first_spawn_delay seconds
		_life_orb_next_spawn_time = life_orb_first_spawn_delay
	if augment_orb_data != null:
		_spawn_counts[augment_orb_data.display_name] = 0
		# First augment orb spawns after first_spawn_delay seconds
		_augment_orb_next_spawn_time = augment_orb_first_spawn_delay


func _process(delta: float) -> void:
	_game_time_elapsed += delta

	# Debug: Print spawn rate every second
	_debug_print_timer += delta
	if _debug_print_timer >= 1.0:
		_debug_print_timer = 0.0
		var current_interval: float = _get_current_spawn_interval()
		var score: int = ScoreManager.get_score()
		var available_count: int = _get_available_orbs().size()
		print("[Progression] Score: %d | Spawn Interval: %.2fs | Available Orbs: %d" % [score, current_interval, available_count])

	# Update spawn timer based on speedup effect and progression
	_update_spawn_timer()

	# Check if it's time to spawn a life orb
	if life_orb_data != null and _game_time_elapsed >= _life_orb_next_spawn_time:
		_try_spawn_life_orb()
		# Use += to maintain fixed intervals (60, 120, 180...) not relative to current time
		_life_orb_next_spawn_time += life_orb_spawn_interval

	# Check if it's time to spawn an augment orb
	if augment_orb_data != null and _game_time_elapsed >= _augment_orb_next_spawn_time:
		_try_spawn_augment_orb()
		_augment_orb_next_spawn_time += augment_orb_spawn_interval


func _get_current_spawn_interval() -> float:
	var current_interval: float = spawn_interval

	# Try mode-specific progression config first, then fallback to local config
	var mode_progression: ProgressionConfig = GameRules.get_progression_config()
	var active_progression: ProgressionConfig = mode_progression if mode_progression != null else progression_config

	# Apply progression-based spawn rate if config exists
	if active_progression != null:
		var score: int = ScoreManager.get_score()
		current_interval = active_progression.get_spawn_interval_for_score(score)

	# Apply spawn speedup effect (multiplicative)
	if EffectManager.has_effect("spawn_speedup"):
		var multiplier: Variant = EffectManager.get_effect_value("spawn_speedup")
		if multiplier != null and multiplier > 0:
			current_interval = current_interval / float(multiplier)

	return current_interval


func _update_spawn_timer() -> void:
	var current_interval: float = _get_current_spawn_interval()

	# Update timer if interval changed
	if _timer != null and abs(_timer.wait_time - current_interval) > 0.001:
		_timer.wait_time = current_interval


func _try_spawn_life_orb() -> void:
	if life_orb_data == null:
		return

	# Don't spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return

	var orb := OrbAdapter.create_orb_from_data(generic_orb_scene, life_orb_data)
	_record_spawn(life_orb_data.display_name)
	_position_orb(orb)
	add_child(orb)


func _try_spawn_augment_orb() -> void:
	if augment_orb_data == null:
		return

	# Don't spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return

	var orb := OrbAdapter.create_orb_from_data(generic_orb_scene, augment_orb_data)
	_record_spawn(augment_orb_data.display_name)
	_position_orb(orb)
	add_child(orb)
	print("[AugmentOrb] Spawned at time %.1f" % _game_time_elapsed)


func _on_timeout() -> void:
	# Don't spawn if max_orbs reached
	if max_orbs > 0 and get_tree().get_nodes_in_group("orbs").size() >= max_orbs:
		return

	var orb := _spawn_orb()
	if orb == null:
		return

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
	# Get available orbs filtered by progression
	var available_orbs: Array[OrbData] = _get_available_orbs()

	if available_orbs.is_empty():
		return null

	# Calculate total weight
	var total_weight: float = 0.0
	for data: OrbData in available_orbs:
		total_weight += data.spawn_weight

	if total_weight <= 0.0:
		# Fallback to uniform random if all weights are 0
		var idx := randi() % available_orbs.size()
		return available_orbs[idx]

	# Weighted random selection
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0

	for data: OrbData in available_orbs:
		cumulative += data.spawn_weight
		if roll <= cumulative:
			return data

	# Fallback (shouldn't reach here)
	return available_orbs.back()


func _get_available_orbs() -> Array[OrbData]:
	# Try mode-specific progression config first, then fallback to local config
	var mode_progression: ProgressionConfig = GameRules.get_progression_config()
	var active_progression: ProgressionConfig = mode_progression if mode_progression != null else progression_config

	# If no progression config, all orbs are available
	if active_progression == null:
		return orb_data_array

	var current_score: int = ScoreManager.get_score()
	var available: Array[OrbData] = []

	for data: OrbData in orb_data_array:
		if active_progression.is_orb_available(data.display_name, current_score):
			available.append(data)

	return available


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
	print("Next life orb spawn: %.1f seconds" % _life_orb_next_spawn_time)
	print("Next augment orb spawn: %.1f seconds" % _augment_orb_next_spawn_time)
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


## Returns the current list of available orbs based on score progression.
## Useful for testing and debugging.
func get_available_orb_names() -> Array[String]:
	var result: Array[String] = []
	for data: OrbData in _get_available_orbs():
		result.append(data.display_name)
	return result
