extends Node
## Centralized mode lifecycle management.
## Loads mode configs, orchestrates mode start/end, and manages high scores.
## Registered as autoload singleton "ModeManager" in project.godot
##
## NOTE: This is separate from GameState.current_mode which tracks game STATE
## (menu/playing/paused/game_over). ModeManager.current_mode tracks the active
## PLAY MODE configuration (endless/time_attack/orb_hunt/survival).
##
## NOTE: No class_name is used to avoid shadowing the autoload global name.

#region Signals

## Emitted when a mode starts
signal mode_started(mode_id: String)

## Emitted when a mode ends with result (win: bool, score: int, etc.)
signal mode_ended(mode_id: String, result: Dictionary)

## Emitted when the current mode's metric updates
signal metric_updated(metric_name: String, value: Variant)

#endregion

#region Properties

## Currently active mode configuration (null when no mode is active)
var current_mode: ModeConfig = null

## Currently active mode implementation instance (null when no mode is active)
var _mode_impl: ModeBase = null

## Available mode configurations loaded from resources/modes/
var _available_modes: Dictionary = {}

## High scores per mode (persisted via SavedGame)
var _high_scores: Dictionary = {}

#endregion

#region Lifecycle

func _ready() -> void:
	_load_available_modes()


## Load all mode configs from resources/modes/ directory
func _load_available_modes() -> void:
	var modes_dir := "res://resources/modes/"
	var dir := DirAccess.open(modes_dir)

	if dir == null:
		push_warning("ModeManager: Could not open modes directory: " + modes_dir)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path := modes_dir + file_name
			var config := load(full_path) as ModeConfig

			if config and config.is_valid():
				_available_modes[config.mode_id] = config
			else:
				push_warning("ModeManager: Invalid mode config: " + full_path)

		file_name = dir.get_next()

	dir.list_dir_end()


func _process(delta: float) -> void:
	if _mode_impl != null:
		_mode_impl._on_process(delta)

#endregion

#region Mode Lifecycle

## Start a mode by its ID. Returns false if mode doesn't exist.
func start_mode(mode_id: String) -> void:
	if not _available_modes.has(mode_id):
		push_warning("ModeManager: Cannot start unknown mode: " + mode_id)
		return

	current_mode = _available_modes[mode_id]
	_instantiate_mode_implementation()
	mode_started.emit(mode_id)


## End the current mode with a result dictionary.
func end_mode(result: Dictionary) -> void:
	if current_mode == null:
		push_warning("ModeManager: Cannot end mode - no mode is active")
		return

	if _mode_impl != null:
		_mode_impl._on_end()

	var ended_mode_id := current_mode.mode_id
	mode_ended.emit(ended_mode_id, result)
	current_mode = null
	_mode_impl = null


## Create an instance of the mode's implementation script
func _instantiate_mode_implementation() -> void:
	if current_mode == null:
		return

	if current_mode.implementation == null:
		push_warning("ModeManager: No implementation script for mode: " + current_mode.mode_id)
		return

	var impl_script := current_mode.implementation
	_mode_impl = impl_script.new() as ModeBase

	if _mode_impl == null:
		push_warning("ModeManager: Failed to instantiate implementation for mode: " + current_mode.mode_id)
		return

	_mode_impl.config = current_mode
	_mode_impl._on_start()


#endregion

#region Mode Config Access

## Get a mode configuration by ID. Returns null if not found.
func get_mode_config(mode_id: String) -> ModeConfig:
	if not _available_modes.has(mode_id):
		return null
	return _available_modes[mode_id]


## Get the current mode implementation instance. Returns null if no mode is active.
func get_mode_implementation() -> ModeBase:
	return _mode_impl


#endregion

#region High Score Management

## Get high score for a mode. Returns 0 if no score recorded.
func get_high_score(mode_id: String) -> int:
	if not _high_scores.has(mode_id):
		return 0
	return _high_scores[mode_id]


## Set high score for a mode.
func set_high_score(mode_id: String, score: int) -> void:
	_high_scores[mode_id] = score


#endregion

#region Metric Access

## Get the current mode's metric for HUD display.
## Returns empty dict if no mode is active.
## Returns {"name": metric_name, "value": current_value} when a mode is active.
func get_current_metric() -> Dictionary:
	if current_mode == null:
		return {}

	if _mode_impl != null:
		return _mode_impl._get_metric()

	return {
		"name": current_mode.hud_metric,
		"value": _get_metric_value()
	}


## Get the current metric value based on mode's hud_metric setting.
func _get_metric_value() -> Variant:
	if current_mode == null:
		return 0

	match current_mode.hud_metric:
		"score":
			return ScoreManager.get_score()
		_:
			return ScoreManager.get_score()

#endregion
