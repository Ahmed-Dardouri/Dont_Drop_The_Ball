extends Node

#region game_variables
var current_score: int = 0

## Debug: set this to a non-zero value to start each run with that score (testing only)
@export var debug_start_score: int = 0

#endregion

#region permanent_lives
## Permanent lives counter for easy mode (separate from temporary "has_life" effect)
var permanent_lives: int = 0
#endregion

#region augment_modifiers
## Score modifiers
var score_per_orb_bonus: int = 0
var chain_score_bonus: int = 0
var score_multiplier_bonus: float = 0.0

## Meter modifiers
var meter_fill_multiplier: float = 0.0
var meter_drain_reduction: float = 0.0

## Burst modifiers
var burst_radius_bonus: float = 0.0

## Vortex modifiers
var vortex_radius_bonus: float = 0.0

## Line clear modifiers
var line_clear_range_bonus: float = 0.0
var line_clear_bonus_per_orb: int = 0

## Spawn modifiers
var orb_spawn_rate_bonus: float = 0.0
var life_orb_chance_bonus: float = 0.0
var special_orb_chance_bonus: float = 0.0
var special_orb_score_bonus: float = 0.0

## Collection modifiers
var collection_range_bonus: float = 0.0

## Vortex modifiers
var vortex_duration_bonus: float = 0.0

## Reset all augment modifiers (call on game over / new run)
func reset_augment_modifiers() -> void:
	score_per_orb_bonus = 0
	chain_score_bonus = 0
	score_multiplier_bonus = 0.0
	meter_fill_multiplier = 0.0
	meter_drain_reduction = 0.0
	burst_radius_bonus = 0.0
	vortex_radius_bonus = 0.0
	vortex_duration_bonus = 0.0
	line_clear_range_bonus = 0.0
	line_clear_bonus_per_orb = 0
	orb_spawn_rate_bonus = 0.0
	life_orb_chance_bonus = 0.0
	special_orb_chance_bonus = 0.0
	special_orb_score_bonus = 0.0
	collection_range_bonus = 0.0
#endregion
