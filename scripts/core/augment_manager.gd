extends Node
## AugmentManager - Manages augments for the current run.
## Phase 1: Simple prototype with fixed augment pool.

#region Signals

signal augment_added(augment: Resource, stack_count: int)
signal augments_cleared

#endregion

#region Constants

## Number of augment choices to present (Phase 1: always 3)
const CHOICE_COUNT: int = 3

## Effect type constants (matches Enums.AugmentEffect)
const EFFECT_FLAT_SCORE_BONUS: int = 0
const EFFECT_SPAWN_RATE_MULTIPLIER: int = 1
const EFFECT_BURST_RADIUS_MULTIPLIER: int = 2
const EFFECT_LINE_CLEAR_RANGE_MULT: int = 3
const EFFECT_VORTEX_RADIUS_MULT: int = 4
const EFFECT_MAX_LIVES_BONUS: int = 5
const EFFECT_METER_FILL_MULT: int = 6
const EFFECT_BALL_SLOWDOWN_MULT: int = 7

#endregion

#region Private State

## All available prototype augments (Phase 1: fixed list)
var _prototype_augments: Array[Resource] = []

## Active augments for current run: augment_id -> stack_count
var _active_augments: Dictionary = {}

## Cached augment data for quick lookup: augment_id -> AugmentData
var _augment_cache: Dictionary = {}

#endregion

#region Lifecycle

func _ready() -> void:
	_initialize_prototype_augments()
	Events.add_listener(AugmentChosenEvent, _on_augment_chosen)
	Events.add_listener(GameOverEvent, _on_game_over)


func _initialize_prototype_augments() -> void:
	# Phase 1: Create a fixed set of prototype augments programmatically
	# For now, create simple augments as Resource instances

	var aug1 := _create_augment(
		"flat_score_100",
		"Score Bonus",
		"+100 score immediately",
		EFFECT_FLAT_SCORE_BONUS,
		100.0,
		true,
		10
	)
	_prototype_augments.append(aug1)
	_augment_cache["flat_score_100"] = aug1

	var aug2 := _create_augment(
		"spawn_rate_1.1",
		"Quick Spawns",
		"Orbs spawn 10% faster",
		EFFECT_SPAWN_RATE_MULTIPLIER,
		1.1,
		true,
		5
	)
	_prototype_augments.append(aug2)
	_augment_cache["spawn_rate_1.1"] = aug2

	var aug3 := _create_augment(
		"burst_radius_1.2",
		"Bigger Burst",
		"Burst orb radius +20%",
		EFFECT_BURST_RADIUS_MULTIPLIER,
		1.2,
		true,
		5
	)
	_prototype_augments.append(aug3)
	_augment_cache["burst_radius_1.2"] = aug3


func _create_augment(
	p_id: String,
	p_name: String,
	p_desc: String,
	p_type: int,
	p_value: float,
	p_can_stack: bool,
	p_max_stacks: int
) -> Resource:
	var augment := AugmentData.new()
	augment.augment_id = p_id
	augment.display_name = p_name
	augment.description = p_desc
	augment.effect_type = p_type
	augment.effect_value = p_value
	augment.can_stack = p_can_stack
	augment.max_stacks = p_max_stacks
	return augment


#endregion

#region Public API

## Get random augment choices for the selection UI.
## Returns CHOICE_COUNT random augments from the prototype pool.
func get_random_choices() -> Array[Resource]:
	var available: Array[Resource] = []
	available.append_array(_prototype_augments)

	var choices: Array[Resource] = []
	var indices: Array[int] = []
	for i: int in range(available.size()):
		indices.append(i)
	indices.shuffle()

	for i: int in range(mini(CHOICE_COUNT, indices.size())):
		choices.append(available[indices[i]])

	return choices


## Apply an augment to the current run.
## Returns the new stack count (1 if not stackable, or if already at max).
func apply_augment(augment: Resource) -> int:
	if augment == null or not augment.is_valid():
		push_warning("Attempted to apply invalid augment")
		return 0

	var current_stacks: int = _active_augments.get(augment.augment_id, 0)

	if not augment.can_stack and current_stacks > 0:
		# Already have this non-stackable augment
		push_warning("Attempted to stack non-stackable augment: %s" % augment.augment_id)
		return current_stacks

	if current_stacks >= augment.max_stacks:
		# Already at max stacks
		push_warning("Attempted to exceed max stacks for augment: %s" % augment.augment_id)
		return current_stacks

	# Apply the augment
	var new_stacks: int = current_stacks + 1
	_active_augments[augment.augment_id] = new_stacks

	# Apply immediate effects for FLAT_SCORE_BONUS
	if augment.effect_type == EFFECT_FLAT_SCORE_BONUS:
		ScoreManager.add_score(int(augment.effect_value))

	# Emit signal and event
	augment_added.emit(augment, new_stacks)
	AugmentAppliedEvent.invoke(augment, new_stacks)

	return new_stacks


## Get the total multiplier for a given effect type.
## For multipliers: multiply all stack values together.
## For flat bonuses: sum all stack values.
func get_effect_multiplier(effect_type: int) -> float:
	var total: float = 1.0

	for aug_id: String in _active_augments:
		var augment: Resource = _augment_cache.get(aug_id)
		if augment == null:
			continue
		if augment.effect_type != effect_type:
			continue

		var stacks: int = _active_augments[aug_id]
		match effect_type:
			EFFECT_SPAWN_RATE_MULTIPLIER, \
			EFFECT_BURST_RADIUS_MULTIPLIER, \
			EFFECT_LINE_CLEAR_RANGE_MULT, \
			EFFECT_VORTEX_RADIUS_MULT, \
			EFFECT_METER_FILL_MULT, \
			EFFECT_BALL_SLOWDOWN_MULT:
				# Multiplicative stacking
				total *= pow(augment.effect_value, stacks)
			_:
				# Additive stacking for flat bonuses
				total += augment.effect_value * stacks

	return total


## Get the total flat bonus for a given effect type.
## Returns the sum of (effect_value * stack_count) for all matching augments.
func get_effect_flat_bonus(effect_type: int) -> float:
	var total: float = 0.0

	for aug_id: String in _active_augments:
		var augment: Resource = _augment_cache.get(aug_id)
		if augment == null:
			continue
		if augment.effect_type != effect_type:
			continue

		var stacks: int = _active_augments[aug_id]
		total += augment.effect_value * stacks

	return total


## Check if an augment is active (has at least 1 stack)
func has_augment(augment_id: String) -> bool:
	return _active_augments.get(augment_id, 0) > 0


## Get the stack count for an augment
func get_augment_stacks(augment_id: String) -> int:
	return _active_augments.get(augment_id, 0)


## Get all active augments (for UI/debug)
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
	# Clear augments on game over for fresh start next run
	clear_augments()


#endregion
