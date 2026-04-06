extends Node
## AugmentManager - Manages augments for the current run.
## Phase 2: Rarity system + phase-weighted pools.
## Supports UNIQUE (one per run) and REPEATABLE (stackable) augments.
## Repeatable augments use tuned progression tables for meaningful stacking.

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

## Maximum practical stack cap for repeatable augments
const MAX_STACK_CAP: int = 5

## Progression tables for repeatable augments.
## Each entry is: stack -> value applied at THAT stack level.
## Stack 1 = base. Higher stacks give increasingly better but controlled values.
## Values beyond MAX_STACK_CAP repeat the last entry.
const STACK_TABLES: Dictionary = {
	# Score family
	"pocket_change": [0, 3, 5, 7, 8, 9],
	"payroll_upgrade": [0, 5, 8, 11, 13, 14],
	"side_hustle_score": [0, 0.15, 0.25, 0.35, 0.40, 0.45],
	# Meter family
	"easy_money": [0, 0.20, 0.30, 0.40, 0.45, 0.50],
	"overcharged_meter": [0, 0.40, 0.55, 0.65, 0.70, 0.75],
	"catch_a_break": [0, 0.15, 0.25, 0.35, 0.40, 0.45],
	# Spawn family
	"orb_buffet": [0, 0.15, 0.20, 0.25, 0.28, 0.30],
	"adrenaline_drip": [0, 0.30, 0.40, 0.50, 0.55, 0.60],
	"shiny_problem": [0, 0.20, 0.30, 0.40, 0.45, 0.50],
	# Life family
	"just_one_more": [0, 1, 1, 1, 1, 1],
	"lucky_bounce": [0, 0.15, 0.20, 0.25, 0.28, 0.30],
	# Hybrid family
	"extra_hands": [0, 0.25, 0.35, 0.45, 0.50, 0.55],
	# Vortex family
	"bigger_vacuum": [0, 0.25, 0.42, 0.55, 0.63, 0.68],
	"long_lunch": [0, 0.25, 0.42, 0.55, 0.63, 0.68],
	# Line family
	"wide_sweep": [0, 0.20, 0.35, 0.50, 0.60, 0.65],
	# Burst family
	"snack_sized_boom": [0, 0.20, 0.35, 0.50, 0.60, 0.65],
}

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


## Get random augment choices for the selection UI.
## Returns CHOICE_COUNT unique augments from the correct pool.
## Excludes unique augments already chosen in this run.
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

	# Build unique augments with their weights, excluding chosen uniques
	var unique_augments: Array[AugmentData] = []
	var weights: Array[int] = []

	for try_rarity: int in rarities_to_try:
		unique_augments.clear()
		weights.clear()

		var rarity_pool: Array = _augments_by_rarity.get(try_rarity, [])
		for augment: AugmentData in rarity_pool:
			# Skip unique augments already chosen in this run
			if augment.selection_mode == Enums.AugmentSelectionMode.UNIQUE and has_augment(augment.augment_id):
				continue

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

	# Block if unique already chosen
	if augment_data.selection_mode == Enums.AugmentSelectionMode.UNIQUE and has_augment(augment_data.augment_id):
		push_warning("AugmentManager: Tried to apply unique augment '%s' that was already chosen" % augment_data.augment_id)
		return

	var current_stacks: int = _active_augments.get(augment_data.augment_id, 0)
	var new_stacks: int = current_stacks + 1
	_active_augments[augment_data.augment_id] = new_stacks

	_apply_augment_effect(augment_data, new_stacks)

	augment_added.emit(augment, new_stacks)
	AugmentAppliedEvent.invoke(augment_data)


## Get the current stack count for a repeatable augment (0 if not picked yet).
func get_augment_stacks(augment_id: String) -> int:
	return _active_augments.get(augment_id, 0)


## Get the selection label text for an augment card.
## Returns "Unique" for unique augments, "x0"/"x1"/"x2" for repeatable.
func get_selection_label(augment_data: AugmentData) -> String:
	if augment_data.selection_mode == Enums.AugmentSelectionMode.UNIQUE:
		return "Unique"
	var stacks: int = get_augment_stacks(augment_data.augment_id)
	return "x%d" % stacks


#region Stack Progression

## Look up the tuned value for a given augment table key at the given stack level.
## Returns the value from the progression table, clamped to MAX_STACK_CAP.
## For stacks beyond the table, returns the last entry (soft cap).
static func get_stack_value(table_key: String, stack: int) -> float:
	var table: Array = STACK_TABLES.get(table_key, [])
	if table.is_empty():
		return 0.0
	var idx: int = mini(stack, table.size() - 1)
	if idx < 0:
		idx = 0
	return table[idx]

#endregion

#region Effect Application

## Apply the actual effect of an augment, dispatched by category helpers.
## stack: the NEW stack count after this application (1 for first pick).
func _apply_augment_effect(augment: AugmentData, stack: int) -> void:
	match augment.augment_key:
		# Score
		"pocket_change", "collectors_habit", "starter_credit", "main_score_augment", "lucky_penny", "side_hustle", "payroll_upgrade", "rent_was_due", "top_shelf", "rich_get_richer", "big_bank_energy", "jackpot_fever", "golden_ticket", "special_delivery", "jackpot_bonus", "chain_appetite", "greedy_little_hands":
			_apply_score_effect(augment.augment_key, stack)
		# Life
		"just_one_more", "safety_net", "lucky_bounce", "extra_pocket", "more_lives_more_problems", "plot_armor", "second_wallet", "life_insurance":
			_apply_life_effect(augment.augment_key, stack)
		# Meter
		"easy_money", "paper_trail", "catch_a_break", "room_to_breathe", "overcharged_meter", "bigger_bank", "savings_account", "steady_pressure", "infinite_snack_glitch", "over_the_limit":
			_apply_meter_effect(augment.augment_key, stack)
		# Burst
		"snack_sized_boom", "soft_fuse", "boom_goes_the_neighborhood", "aftershock", "kaboom_deluxe", "boom_tax_refund":
			_apply_burst_effect(augment.augment_key, stack)
		# Vortex
		"bigger_vacuum", "long_lunch", "long_reach", "industrial_strength", "black_hole_budget_cut", "vacuum_maxxed":
			_apply_vortex_effect(augment.augment_key, stack)
		# Line
		"wide_sweep", "sharp_line", "full_screen_insurance", "sweep_account", "line_em_up", "laser_but_horizontal", "laser_show":
			_apply_line_effect(augment.augment_key, stack)
		# Spawn
		"orb_buffet", "shiny_problem", "adrenaline_drip", "fast_lane", "more_where_that_came_from", "orb_storm", "oops_all_orbs", "rainmaker", "lucky_universe":
			_apply_spawn_effect(augment.augment_key, stack)
		# Multi-category
		"king_sized", "extra_hands":
			_apply_hybrid_effect(augment.augment_key, stack)
		# Legacy
		"score_bonus", "max_life_plus_1", "burst_radius_up", "spawn_rate_up", "line_clear_up", "vortex_radius_up", "meter_fill_up":
			_apply_legacy_effect(augment.augment_key)
		_:
			print("AugmentManager: Unknown augment key '%s'" % augment.augment_key)


func _apply_score_effect(key: String, stack: int) -> void:
	match key:
		"pocket_change":
			Variables.score_per_orb_bonus += int(get_stack_value("pocket_change", stack))
		"collectors_habit":
			Variables.score_per_orb_bonus += 2
		"starter_credit":
			ScoreManager.add_score(100)
		"main_score_augment":
			ScoreManager.add_score(100)
		"lucky_penny":
			ScoreManager.add_score(75)
		"side_hustle":
			Variables.special_orb_score_bonus += get_stack_value("side_hustle_score", stack)
		"payroll_upgrade":
			Variables.score_per_orb_bonus += int(get_stack_value("payroll_upgrade", stack))
		"rent_was_due":
			Variables.score_per_orb_bonus += 4
		"top_shelf":
			Variables.score_per_orb_bonus += 4
		"rich_get_richer":
			Variables.chain_score_bonus += 3
			Variables.score_multiplier_bonus += 0.1
		"big_bank_energy":
			Variables.score_per_orb_bonus += 10
		"jackpot_fever":
			Variables.score_per_orb_bonus += 15
			Variables.score_multiplier_bonus += 0.3
		"golden_ticket":
			ScoreManager.add_score(500)
		"special_delivery":
			Variables.special_orb_score_bonus += 0.3
		"jackpot_bonus":
			ScoreManager.add_score(300)
			Variables.score_multiplier_bonus += 0.15
		"chain_appetite":
			Variables.chain_score_bonus += 2
		"greedy_little_hands":
			Variables.score_per_orb_bonus += 3
			Variables.special_orb_chance_bonus += 0.1
			Variables.special_orb_score_bonus += 0.1


func _apply_life_effect(key: String, stack: int) -> void:
	match key:
		"just_one_more":
			# Always +1 life per stack, but capped at MAX_STACK_CAP stacks total
			if stack <= MAX_STACK_CAP:
				Variables.permanent_lives += 1
				LifeChangedEvent.invoke(true)
		"safety_net":
			Variables.permanent_lives += 1
			LifeChangedEvent.invoke(true)
		"lucky_bounce":
			Variables.life_orb_chance_bonus += get_stack_value("lucky_bounce", stack)
		"extra_pocket":
			Variables.permanent_lives += 1
			Variables.life_orb_chance_bonus += 0.25
			LifeChangedEvent.invoke(true)
		"more_lives_more_problems":
			Variables.permanent_lives += 1
			Variables.life_orb_chance_bonus += 0.1
			LifeChangedEvent.invoke(true)
		"plot_armor":
			Variables.permanent_lives += 2 
			Variables.life_orb_chance_bonus += 0.3
			LifeChangedEvent.invoke(true)
		"second_wallet":
			Variables.permanent_lives += 2
			Variables.score_per_orb_bonus += 5
			LifeChangedEvent.invoke(true)
		"life_insurance":
			Variables.life_orb_chance_bonus += 0.4


func _apply_meter_effect(key: String, stack: int) -> void:
	match key:
		"easy_money":
			Variables.meter_fill_multiplier += get_stack_value("easy_money", stack)
		"paper_trail":
			Variables.meter_fill_multiplier += 0.15
		"catch_a_break":
			Variables.meter_drain_reduction += get_stack_value("catch_a_break", stack)
		"room_to_breathe":
			Variables.meter_drain_reduction += 0.1
		"overcharged_meter":
			Variables.meter_fill_multiplier += get_stack_value("overcharged_meter", stack)
		"bigger_bank":
			Variables.meter_fill_multiplier += 0.3
			Variables.meter_drain_reduction += 0.2
		"savings_account":
			Variables.meter_fill_multiplier += 0.25
		"steady_pressure":
			Variables.meter_fill_multiplier += 0.15
			Variables.meter_drain_reduction += 0.1
		"infinite_snack_glitch":
			Variables.meter_fill_multiplier += 0.8
			Variables.meter_drain_reduction += 0.4
		"over_the_limit":
			Variables.meter_fill_multiplier += 0.5
			Variables.meter_drain_reduction += 0.3


func _apply_burst_effect(key: String, stack: int) -> void:
	match key:
		"snack_sized_boom":
			Variables.burst_radius_bonus += get_stack_value("snack_sized_boom", stack)
		"soft_fuse":
			Variables.burst_radius_bonus += 0.15
		"boom_goes_the_neighborhood":
			Variables.burst_radius_bonus += 0.5
		"aftershock":
			Variables.burst_radius_bonus += 0.35
			Variables.chain_score_bonus += 2
		"kaboom_deluxe":
			Variables.burst_radius_bonus += 1.0
		"boom_tax_refund":
			Variables.burst_radius_bonus += 0.8
			Variables.chain_score_bonus += 5


func _apply_vortex_effect(key: String, stack: int) -> void:
	match key:
		"bigger_vacuum":
			Variables.vortex_radius_bonus += get_stack_value("bigger_vacuum", stack)
		"long_lunch":
			Variables.vortex_duration_bonus += get_stack_value("long_lunch", stack)
		"long_reach":
			Variables.vortex_radius_bonus += 0.4
		"industrial_strength":
			Variables.vortex_radius_bonus += 0.6
		"black_hole_budget_cut":
			Variables.vortex_radius_bonus += 1.0
		"vacuum_maxxed":
			Variables.vortex_radius_bonus += 1.2


func _apply_line_effect(key: String, stack: int) -> void:
	match key:
		"wide_sweep":
			Variables.line_clear_range_bonus += get_stack_value("wide_sweep", stack)
		"sharp_line":
			Variables.line_clear_range_bonus += 0.15
		"full_screen_insurance":
			Variables.line_clear_range_bonus += 0.5
		"sweep_account":
			Variables.line_clear_range_bonus += 0.35
			Variables.line_clear_bonus_per_orb += 1
		"line_em_up":
			Variables.line_clear_range_bonus += 1.0
		"laser_but_horizontal":
			Variables.line_clear_range_bonus += 1.2
		"laser_show":
			Variables.line_clear_range_bonus += 0.8
			Variables.line_clear_bonus_per_orb += 3


func _apply_spawn_effect(key: String, stack: int) -> void:
	match key:
		"orb_buffet":
			Variables.orb_spawn_rate_bonus += get_stack_value("orb_buffet", stack)
		"shiny_problem":
			Variables.special_orb_chance_bonus += get_stack_value("shiny_problem", stack)
		"adrenaline_drip":
			Variables.orb_spawn_rate_bonus += get_stack_value("adrenaline_drip", stack)
		"fast_lane":
			Variables.orb_spawn_rate_bonus += 0.2
		"more_where_that_came_from":
			Variables.special_orb_chance_bonus += 0.15
		"orb_storm":
			Variables.orb_spawn_rate_bonus += 0.6
		"oops_all_orbs":
			Variables.orb_spawn_rate_bonus += 0.5
			Variables.special_orb_chance_bonus += 0.4
		"rainmaker":
			Variables.orb_spawn_rate_bonus += 0.45
		"lucky_universe":
			Variables.life_orb_chance_bonus += 0.25
			Variables.special_orb_chance_bonus += 0.25


func _apply_hybrid_effect(key: String, stack: int) -> void:
	match key:
		"king_sized":
			Variables.burst_radius_bonus += 0.3
			Variables.line_clear_range_bonus += 0.3
			Variables.vortex_radius_bonus += 0.3
		"extra_hands":
			Variables.collection_range_bonus += get_stack_value("extra_hands", stack)


func _apply_legacy_effect(key: String) -> void:
	match key:
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

#endregion


#region Query

## Check if an augment is active
func has_augment(augment_id: String) -> bool:
	return _active_augments.get(augment_id, 0) > 0


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
