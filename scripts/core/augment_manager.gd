extends Node
## AugmentManager - Manages augments for the current run.
## Phase 2: Rarity system + phase-weighted pools.

## All 3 cards in a draft share the same rolled rarity.

#region Signals

signal augment_added(augment: Resource, stack_count: int)
signal augments_cleared

#endregion

#region Constants

## Number of augment choices to present
const CHOICE_COUNT: int = 3

## Rarity roll chances (draft-level, not per-card)
const RARITY_COMMON_CHANCE: float = 0.60
const RARITY_RARE_CHANCE: float = 0.30
const RARITY_MYTHICAL_CHANCE: float = 0.10

## Game phase thresholds (in seconds)
const PHASE_EARLY_THRESHOLD: float = 180.0   # 0-60 seconds
const PHASE_MID_THRESHOLD: float = 600.0    # 60-180 seconds
# 180+ seconds = late

#endregion

#region Private State

## All available augments (loaded from resources/augments/)
var _all_augments: Array[AugmentData] = []

## Augments organized by rarity and for quick pool access
var _augments_by_rarity: Dictionary = {}  # rarity -> Array[AugmentData]

## Active augments for current run: augment_id -> stack_count
var _active_augments: Dictionary = {}

## Cached augment data for quick lookup: augment_id -> AugmentData
var _augment_cache: Dictionary = {}

## Current game time (for phase detection)
var _game_time: float = 0.0

#endregion

#region Lifecycle

func _ready() -> void:
	_load_augments()
	Events.add_listener(AugmentChosenEvent, _on_augment_chosen)
	Events.add_listener(GameOverEvent, _on_game_over)


func _process(delta: float) -> void:
	_game_time += delta


## Load all augment definitions from resources/augments/
func _load_augments() -> void:
	_all_augments.clear()
	_augments_by_rarity.clear()
	_augment_cache.clear()

	var dir := DirAccess.open("res://resources/augments/")
	if dir == null:
		push_warning("AugmentManager: Could not open resources/augments/ directory")
		return

	var files := dir.get_files()
	print("AugmentManager: Found %d files in augments directory" % files.size())
	for file: String in files:
		if not file.ends_with(".tres"):
			continue
		var full_path := "res://resources/augments/" + file
		var augment := load(full_path) as AugmentData
		if augment == null:
			print("AugmentManager: Failed to load %s as AugmentData" % file)
			continue
		if not augment.is_valid():
			print("AugmentManager: Augment %s is not valid (id=%s name=%s icon=%s key=%s)" % [file, augment.augment_id, augment.display_name, augment.icon_key, augment.augment_key])
			continue
		_all_augments.append(augment)
		_augment_cache[augment.augment_id] = augment

		# Organize by rarity
		if not _augments_by_rarity.has(augment.rarity):
			_augments_by_rarity[augment.rarity] = []
		_augments_by_rarity[augment.rarity].append(augment)

	print("AugmentManager: Loaded %d augments, rarities: %s" % [_all_augments.size(), str(_augments_by_rarity.keys())])


## Returns the current game phase based on elapsed time
func get_current_phase() -> int:
	if _game_time < PHASE_EARLY_THRESHOLD:
		return Enums.GamePhase.EARLY
	elif _game_time < PHASE_MID_THRESHOLD:
		return Enums.GamePhase.MID
	else:
		return Enums.GamePhase.LATE


## Roll rarity for a draft (draft-level, not per-card)
## Returns COMMON, RARE, or MYTHICAL
func roll_draft_rarity() -> int:
	var roll := randf()
	if roll < RARITY_MYTHICAL_CHANCE:
		return Enums.AugmentRarity.MYTHICAL
	elif roll < RARITY_MYTHICAL_CHANCE + RARITY_RARE_CHANCE:
		return Enums.AugmentRarity.RARE
	else:
		return Enums.AugmentRarity.COMMON


## Get augments available for a specific rarity and phase
func _get_pool_for_rarity_and_phase(rarity: int, phase: int) -> Array[AugmentData]:
	var pool: Array[AugmentData] = []
	var rarity_pool: Array = _augments_by_rarity.get(rarity, [])

	for augment: AugmentData in rarity_pool:
		var weight: int = 0
		match phase:
			Enums.GamePhase.EARLY:
				weight = augment.early_weight
			Enums.GamePhase.MID:
				weight = augment.mid_weight
			Enums.GamePhase.LATE:
				weight = augment.late_weight

		if weight > 0:
			# Add to pool multiple times based on weight
			for i: int in range(weight):
				pool.append(augment)

	return pool


## Get random augment choices for the selection UI.
## Returns CHOICE_COUNT unique augments from the correct pool.
## Falls back to lower rarities if rolled rarity has no available augments.
func get_random_choices() -> Array[Resource]:
	var rolled_rarity := roll_draft_rarity()
	var phase := get_current_phase()

	# Try rarities from rolled down to COMMON until we find augments
	var rarities_to_try := [rolled_rarity]
	if rolled_rarity == Enums.AugmentRarity.MYTHICAL:
		rarities_to_try.append(Enums.AugmentRarity.RARE)
	if rolled_rarity >= Enums.AugmentRarity.RARE:
		rarities_to_try.append(Enums.AugmentRarity.COMMON)

	var pool: Array[AugmentData] = []
	var actual_rarity := rolled_rarity

	for try_rarity: int in rarities_to_try:
		pool = _get_pool_for_rarity_and_phase(try_rarity, phase)
		if not pool.is_empty():
			actual_rarity = try_rarity
			break

	print("AugmentManager: get_random_choices - rolled=%d actual=%d phase=%d pool_size=%d" % [rolled_rarity, actual_rarity, phase, pool.size()])

	if pool.is_empty():
		push_warning("AugmentManager: No augments available for any rarity in phase=%d" % phase)
		return []

	var choices: Array[Resource] = []
	var selected_ids: Array[String] = []

	# Make a working copy of the pool to remove picked items
	var working_pool: Array[AugmentData] = []
	working_pool.append_array(pool)

	while choices.size() < CHOICE_COUNT and working_pool.size() > 0:
		var idx := randi_range(0, working_pool.size() - 1)
		var augment := working_pool[idx]
		working_pool.remove_at(idx)  # Always remove to prevent infinite loop

		if augment.augment_id not in selected_ids:
			choices.append(augment)
			selected_ids.append(augment.augment_id)

	print("AugmentManager: get_random_choices returning %d choices" % choices.size())
	return choices


## Apply an augment to the current run.
func apply_augment(augment: Resource) -> void:
	if augment == null or not augment.is_valid():
		push_warning("Attempted to apply invalid augment")
		return

	var augment_data: AugmentData = augment as AugmentData
	var current_stacks: int = _active_augments.get(augment_data.augment_id, 0)

	# For Phase 2: simple single-selection (no stacking yet)
	var new_stacks: int = current_stacks + 1
	_active_augments[augment_data.augment_id] = new_stacks

	_apply_augment_effect(augment_data)

	augment_added.emit(augment, new_stacks)
	AugmentAppliedEvent.invoke(augment_data)


## Apply the actual effect of an augment
func _apply_augment_effect(augment: AugmentData) -> void:
	# Handle specific augment keys
	match augment.augment_key:
		"score_bonus":
			ScoreManager.add_score(50)  # Fixed +50 score for prototype
		"max_life_plus_1":
			Variables.permanent_lives += 1
			LifeChangedEvent.invoke(true)
		"burst_radius_up":
			print("AugmentManager: burst_radius_up applied (placeholder)")
		"spawn_rate_up":
			print("AugmentManager: spawn_rate_up applied (placeholder)")
		"line_clear_up":
			print("AugmentManager: line_clear_up applied (placeholder)")
		"vortex_radius_up":
			print("AugmentManager: vortex_radius_up applied (placeholder)")
		"meter_fill_up":
			print("AugmentManager: meter_fill_up applied (placeholder)")
		# Add more handlers as augments are implemented
		_:
			# Placeholder: log unimplemented augment
			print("AugmentManager: Augment '%s' not yet implemented" % augment.augment_key)


## Check if an augment is active
func has_augment(augment_id: String) -> bool:
	return _active_augments.get(augment_id, 0) > 0


## Get the stack count for an augment
func get_augment_stacks(augment_id: String) -> int:
	return _active_augments.get(augment_id, 0)


## Get all active augments
func get_all_active_augments() -> Dictionary:
	return _active_augments.duplicate()


## Clear all augments (for new run)
func clear_augments() -> void:
	_active_augments.clear()
	augments_cleared.emit()


## Get total number of distinct augments active
func get_active_augment_count() -> int:
	return _active_augments.size()

#endregion

#region Event Handlers

func _on_augment_chosen(event: AugmentChosenEvent) -> void:
	if event._augment == null:
		return
	apply_augment(event._augment)


func _on_game_over(_event: GameOverEvent) -> void:
	clear_augments()
	_game_time = 0.0  # Reset game time for fresh run

#endregion
