class_name ProgressionConfig extends Resource
## Configuration for score-based orb unlock progression and spawn rate scaling.
## Defines when orb types become available and how spawn rate increases.

#region Orb Unlock Thresholds
## Score threshold at which each orb type becomes available.
## Format: { "orb_display_name": score_threshold }
## Orbs not in this dictionary are always available (score threshold 0).
@export var orb_unlock_thresholds: Dictionary = {
	"Blue Orb": 0,
	"Burst Orb": 20,
	"Vortex Orb": 100,
	"Horizontal Wave Orb": 500,
	"Spawn Speedup Orb": 1500,
}
#endregion

#region Spawn Rate Progression
## Base spawn interval in seconds (at score 0).
@export var base_spawn_interval: float = 2.5

## Minimum spawn interval (fastest possible spawning).
@export var min_spawn_interval: float = 0.6

## Score at which minimum spawn interval is reached.
@export var max_progression_score: float = 3000.0

## Exponent for spawn rate curve (1.0 = linear, higher = faster initial decrease).
@export var progression_exponent: float = 0.7
#endregion


#region Public API
## Returns true if the orb with the given display name is available at the current score.
func is_orb_available(orb_display_name: String, current_score: int) -> bool:
	var threshold: Variant = orb_unlock_thresholds.get(orb_display_name, 0)
	return current_score >= int(threshold)


## Returns the spawn interval for the given score.
## Uses an exponential decay curve for smooth progression.
func get_spawn_interval_for_score(current_score: int) -> float:
	if max_progression_score <= 0.0:
		return base_spawn_interval

	# Normalize score to 0-1 range
	var normalized: float = clampf(float(current_score) / max_progression_score, 0.0, 1.0)

	# Apply exponent for curve shape
	var progress: float = pow(normalized, progression_exponent)

	# Interpolate between base and min interval
	return lerpf(base_spawn_interval, min_spawn_interval, progress)


## Returns all orb display names that are available at the given score.
func get_available_orbs(current_score: int) -> Array[String]:
	var result: Array[String] = []
	for orb_name: String in orb_unlock_thresholds.keys():
		if is_orb_available(orb_name, current_score):
			result.append(orb_name)
	return result


## Returns the score threshold for a specific orb type.
## Returns 0 if the orb is not in the thresholds dictionary.
func get_threshold_for_orb(orb_display_name: String) -> int:
	var threshold: Variant = orb_unlock_thresholds.get(orb_display_name, 0)
	return int(threshold)
#endregion
