extends Node
## Combo Manager - Vertical bonus meter system.
## Meter fills when score is gained and drains continuously over time.
## Bonus tiers: +1, +2, +5, +10, +20, +50, +100

#region Constants - Easy to tune

## Bonus tier values (must be in ascending order)
const BONUS_TIERS: Array[int] = [1, 2, 5, 10, 20, 50, 100]

## Meter thresholds to reach each tier (0-indexed, cumulative meter points needed)
## Lower tiers are easier to reach than higher tiers
const TIER_THRESHOLDS: Array[float] = [
	0.0,    # Tier 0 (+1):  starting tier
	10.0,   # Tier 1 (+2):  10 points needed
	30.0,   # Tier 2 (+5):  30 points needed (20 more)
	60.0,   # Tier 3 (+10): 60 points needed (30 more)
	100.0,  # Tier 4 (+20): 100 points needed (40 more)
	160.0,  # Tier 5 (+50): 160 points needed (60 more)
	290.0,  # Tier 6 (+100): 250 points needed (130 more)
]

## Base drain rate (meter points per second) at each tier
## Higher tiers drain faster
const TIER_DRAIN_RATES: Array[float] = [
	0.5,    # Tier 0 (+1):  slow drain
	1.0,    # Tier 1 (+2):  slow drain
	2.0,    # Tier 2 (+5):  medium drain
	6.0,    # Tier 3 (+10): medium-fast drain
	12.0,   # Tier 4 (+20): fast drain
	25.0,   # Tier 5 (+50): faster drain
	50.0,   # Tier 6 (+100): fastest drain
]

## Colors for each tier (0-6) - single source of truth for UI elements
const TIER_COLORS: Array[Color] = [
	Color.WHITE,       # Tier 0: +1
	Color.LIGHT_BLUE,  # Tier 1: +2
	Color.CYAN,        # Tier 2: +5
	Color.LIME,        # Tier 3: +10
	Color.YELLOW,      # Tier 4: +20
	Color.ORANGE,      # Tier 5: +50
	Color(1.0, 0.4, 0.7),  # Tier 6: +100 (purple-pinkish)
]

## How much score contributes to meter fill per point of score
const SCORE_TO_METER_RATIO: float = 1

## Maximum meter value (capped at highest threshold)
const MAX_METER_VALUE: float = 300.0

#endregion

#region Private State

var _meter_value: float = 0.0
var _current_tier: int = 0

#endregion

#region Lifecycle

func _ready() -> void:
	# Connect to game over to reset meter
	Events.add_listener(GameOverEvent, _on_game_over)


func _process(delta: float) -> void:
	# Drain the meter continuously
	if _meter_value > 0.0:
		var drain_rate: float = TIER_DRAIN_RATES[_current_tier]
		_meter_value = maxf(_meter_value - drain_rate * delta, 0.0)
		_update_tier()

#endregion

#region Public API

## Called when score is gained. Fills the meter and returns bonus info.
## Returns a dictionary with base_score, combo_bonus, tier, and total.
## tier is captured BEFORE the meter fills to ensure correct color matching.
func add_orb_score(base_score: int) -> Dictionary:
	# Apply double value if active (doubles the score)
	var adjusted_base: int = base_score
	if EffectManager.has_effect("double_value"):
		adjusted_base *= 2

	# Apply score multiplier if active
	var multiplier: Variant = EffectManager.get_effect_value("score_multiplier")
	if multiplier != null:
		adjusted_base = int(adjusted_base * float(multiplier))

	# Capture tier BEFORE any changes (for correct UI color matching)
	var tier_at_collection: int = _current_tier

	# Get current bonus tier value
	var bonus: int = BONUS_TIERS[tier_at_collection]
	var total: int = adjusted_base + bonus

	# Add to score
	ScoreManager.add_score(total)

	# Fill the meter based on score gained
	_fill_meter(float(adjusted_base))

	return {"base_score": adjusted_base, "combo_bonus": bonus, "tier": tier_at_collection, "total": total}


## Gets the current meter value (0.0 to MAX_METER_VALUE)
func get_meter_value() -> float:
	return _meter_value


## Gets the current tier index (0-6)
func get_current_tier() -> int:
	return _current_tier


## Gets the current bonus value based on tier
func get_current_bonus() -> int:
	return BONUS_TIERS[_current_tier]


## Gets the threshold needed to reach a given tier
func get_threshold_for_tier(tier_index: int) -> float:
	if tier_index < 0 or tier_index >= TIER_THRESHOLDS.size():
		return MAX_METER_VALUE
	return TIER_THRESHOLDS[tier_index]


## Resets the meter to zero (for game over / new game)
func reset_combo() -> void:
	var old_tier: int = _current_tier
	_meter_value = 0.0
	_current_tier = 0

	# Fire events for UI
	MeterChangedEvent.invoke(_meter_value, _current_tier)
	if old_tier != _current_tier:
		TierChangedEvent.invoke(old_tier, _current_tier)
	ComboResetEvent.invoke()


## Gets the number of available tiers
func get_tier_count() -> int:
	return BONUS_TIERS.size()


## Gets progress toward next tier (0.0 to 1.0), or 1.0 if at max tier
func get_progress_to_next_tier() -> float:
	if _current_tier >= TIER_THRESHOLDS.size() - 1:
		return 1.0

	var current_threshold: float = TIER_THRESHOLDS[_current_tier]
	var next_threshold: float = TIER_THRESHOLDS[_current_tier + 1]
	var range_size: float = next_threshold - current_threshold

	if range_size <= 0.0:
		return 1.0

	return clampf((_meter_value - current_threshold) / range_size, 0.0, 1.0)


## Compatibility: get_combo_bonus() returns current bonus value
func get_combo_bonus() -> int:
	return get_current_bonus()


## Compatibility: get_next_combo_bonus() returns next tier bonus (or current if max)
func get_next_combo_bonus() -> int:
	if _current_tier + 1 < BONUS_TIERS.size():
		return BONUS_TIERS[_current_tier + 1]
	return BONUS_TIERS[_current_tier]

#endregion

#region Private Helpers

func _fill_meter(score_amount: float) -> void:
	var old_tier: int = _current_tier

	# Add to meter, capped at max
	_meter_value = minf(_meter_value + score_amount * SCORE_TO_METER_RATIO, MAX_METER_VALUE)

	# Update tier based on new meter value
	_update_tier()

	# Fire event for UI
	MeterChangedEvent.invoke(_meter_value, _current_tier)

	if old_tier != _current_tier:
		TierChangedEvent.invoke(old_tier, _current_tier)


func _update_tier() -> void:
	# Find the highest tier we qualify for
	var new_tier: int = 0
	for i: int in range(TIER_THRESHOLDS.size() - 1, -1, -1):
		if _meter_value >= TIER_THRESHOLDS[i]:
			new_tier = i
			break

	if new_tier != _current_tier:
		var old_tier: int = _current_tier
		_current_tier = new_tier
		TierChangedEvent.invoke(old_tier, _current_tier)
		MeterChangedEvent.invoke(_meter_value, _current_tier)


func _on_game_over(_event: GameOverEvent) -> void:
	reset_combo()

#endregion
