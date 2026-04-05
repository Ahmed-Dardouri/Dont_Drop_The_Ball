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
## TESTING: Equal chances for all rarities
const RARITY_COMMON_CHANCE: float = 0.33
const RARITY_RARE_CHANCE: float = 0.33
const RARITY_MYTHICAL_CHANCE: float = 0.34

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

	# Build unique augments with their weights (deduplicate the weighted pool)
	var unique_augments: Array[AugmentData] = []
	var weights: Array[int] = []

	for try_rarity: int in rarities_to_try:
		unique_augments.clear()
		weights.clear()

		var rarity_pool: Array = _augments_by_rarity.get(try_rarity, [])
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
				unique_augments.append(augment)
				weights.append(weight)

		# Only use this rarity if it has enough augments for a full draft (exactly 3)
		if unique_augments.size() >= CHOICE_COUNT:
			break  # Found enough augments at this rarity level

	if unique_augments.size() < CHOICE_COUNT:
		push_warning("AugmentManager: Not enough augments available for any rarity in phase=%d (found %d, need %d)" % [phase, unique_augments.size(), CHOICE_COUNT])
		# Still return what we have, but this shouldn't happen with proper config

	# Select CHOICE_COUNT unique augments using weighted random selection
	var choices: Array[Resource] = []
	var selected_indices: Array[int] = []

	while choices.size() < CHOICE_COUNT and selected_indices.size() < unique_augments.size():
		# Build weight list excluding already selected indices
		var available_weights: Array[int] = []
		var available_indices: Array[int] = []
		for i: int in range(unique_augments.size()):
			if i not in selected_indices:
				available_weights.append(weights[i])
				available_indices.append(i)

		if available_weights.is_empty():
			break

		# Weighted random selection
		var total_weight: int = 0
		for w: int in available_weights:
			total_weight += w

		var roll := randi_range(1, total_weight)
		var cumulative: int = 0
		var selected_local_idx: int = 0

		for i: int in range(available_weights.size()):
			cumulative += available_weights[i]
			if roll <= cumulative:
				selected_local_idx = i
				break

		var actual_idx: int = available_indices[selected_local_idx]
		selected_indices.append(actual_idx)
		choices.append(unique_augments[actual_idx])

	return choices


## Helper to get IDs from augment array for deduplication
func _get_ids(augments: Array[AugmentData]) -> Array[String]:
	var ids: Array[String] = []
	for aug: AugmentData in augments:
		ids.append(aug.augment_id)
	return ids


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
	var stacks: int = get_augment_stacks(augment.augment_id)

	# Handle specific augment keys
	match augment.augment_key:
		# === COMMON SCORE AUGMENTS ===
		"pocket_change":
			# +3 score per orb per stack
			Variables.score_per_orb_bonus += 3
		"collectors_habit":
			# +2 base orb score per stack
			Variables.score_per_orb_bonus += 2
		"starter_credit":
			# One-time +100 score
			ScoreManager.add_score(100)

		# === COMMON LIFE AUGMENTS ===
		"just_one_more":
			# +1 permanent life
			Variables.permanent_lives += 1
			LifeChangedEvent.invoke(true)
		"lucky_bounce":
			# +15% life orb chance per stack
			Variables.life_orb_chance_bonus += 0.15

		# === COMMON METER AUGMENTS ===
		"easy_money":
			# +20% meter fill rate per stack
			Variables.meter_fill_multiplier += 0.2
		"catch_a_break":
			# -15% meter drain rate per stack
			Variables.meter_drain_reduction += 0.15

		# === COMMON BURST AUGMENTS ===
		"snack_sized_boom":
			# +20% burst radius per stack
			Variables.burst_radius_bonus += 0.2

		# === COMMON VORTEX AUGMENTS ===
		"bigger_vacuum":
			# +25% vortex radius per stack
			Variables.vortex_radius_bonus += 0.25

		# === COMMON LINE AUGMENTS ===
		"wide_sweep":
			# +20% line clear range per stack
			Variables.line_clear_range_bonus += 0.2

		# === COMMON SPAWN AUGMENTS ===
		"orb_buffet":
			# +15% orb spawn rate per stack
			Variables.orb_spawn_rate_bonus += 0.15
		"shiny_problem":
			# +20% special orb chance per stack
			Variables.special_orb_chance_bonus += 0.2

		# === RARE SCORE AUGMENTS ===
		"payroll_upgrade":
			# +5 score per orb (stronger than common)
			Variables.score_per_orb_bonus += 5
		"rent_was_due":
			# +4 score per orb
			Variables.score_per_orb_bonus += 4
		"chain_appetite":
			# +2 chain score bonus per stack
			Variables.chain_score_bonus += 2
		"greedy_little_hands":
			# +3 score per orb, +10% special orb bonus
			Variables.score_per_orb_bonus += 3
			Variables.special_orb_chance_bonus += 0.1

		# === RARE LIFE AUGMENTS ===
		"extra_pocket":
			# +1 life, +25% life orb chance
			Variables.permanent_lives += 1
			Variables.life_orb_chance_bonus += 0.25
			LifeChangedEvent.invoke(true)

		# === RARE METER AUGMENTS ===
		"overcharged_meter":
			# +40% meter fill rate per stack
			Variables.meter_fill_multiplier += 0.4
		"bigger_bank":
			# +30% meter fill, -20% drain
			Variables.meter_fill_multiplier += 0.3
			Variables.meter_drain_reduction += 0.2

		# === RARE BURST AUGMENTS ===
		"boom_goes_the_neighborhood":
			# +50% burst radius per stack
			Variables.burst_radius_bonus += 0.5

		# === RARE VORTEX AUGMENTS ===
		"industrial_strength":
			# +60% vortex radius per stack
			Variables.vortex_radius_bonus += 0.6

		# === RARE LINE AUGMENTS ===
		"full_screen_insurance":
			# +50% line clear range per stack
			Variables.line_clear_range_bonus += 0.5

		# === RARE SPAWN AUGMENTS ===
		"adrenaline_drip":
			# +30% orb spawn rate per stack
			Variables.orb_spawn_rate_bonus += 0.3

		# === MYTHICAL SCORE AUGMENTS ===
		"big_bank_energy":
			# +10 score per orb (massive)
			Variables.score_per_orb_bonus += 10
		"jackpot_fever":
			# +15 score per orb, +0.3 score multiplier
			Variables.score_per_orb_bonus += 15
			Variables.score_multiplier_bonus += 0.3

		# === MYTHICAL LIFE AUGMENTS ===
		"plot_armor":
			# +2 lives, +30% life orb chance
			Variables.permanent_lives += 2
			Variables.life_orb_chance_bonus += 0.3
			LifeChangedEvent.invoke(true)

		# === MYTHICAL METER AUGMENTS ===
		"infinite_snack_glitch":
			# +80% meter fill, -40% drain
			Variables.meter_fill_multiplier += 0.8
			Variables.meter_drain_reduction += 0.4

		# === MYTHICAL BURST AUGMENTS ===
		"kaboom_deluxe":
			# +100% burst radius
			Variables.burst_radius_bonus += 1.0
		"boom_tax_refund":
			# +80% burst radius, +5 chain bonus
			Variables.burst_radius_bonus += 0.8
			Variables.chain_score_bonus += 5

		# === MYTHICAL VORTEX AUGMENTS ===
		"black_hole_budget_cut":
			# +100% vortex radius
			Variables.vortex_radius_bonus += 1.0
		"vacuum_maxxed":
			# +120% vortex radius
			Variables.vortex_radius_bonus += 1.2

		# === MYTHICAL LINE AUGMENTS ===
		"line_em_up":
			# +100% line clear range
			Variables.line_clear_range_bonus += 1.0
		"laser_but_horizontal":
			# +120% line clear range
			Variables.line_clear_range_bonus += 1.2

		# === MYTHICAL SPAWN AUGMENTS ===
		"orb_storm":
			# +60% orb spawn rate
			Variables.orb_spawn_rate_bonus += 0.6
		"oops_all_orbs":
			# +50% orb spawn rate, +40% special orb chance
			Variables.orb_spawn_rate_bonus += 0.5
			Variables.special_orb_chance_bonus += 0.4

		# === LEGACY PLACEHOLDERS (for backwards compatibility) ===
		"score_bonus":
			ScoreManager.add_score(50)
		"max_life_plus_1":
			Variables.permanent_lives += 1
			LifeChangedEvent.invoke(true)
		"burst_radius_up":
			Variables.burst_radius_bonus += 0.2
		"spawn_rate_up":
			Variables.orb_spawn_rate_bonus += 0.15
		"line_clear_up":
			Variables.line_clear_range_bonus += 0.2
		"vortex_radius_up":
			Variables.vortex_radius_bonus += 0.25
		"meter_fill_up":
			Variables.meter_fill_multiplier += 0.2

		_:
			print("AugmentManager: Unknown augment key '%s'" % augment.augment_key)


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
	Variables.reset_augment_modifiers()
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
