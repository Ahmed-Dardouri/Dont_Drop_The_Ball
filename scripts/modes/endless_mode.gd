class_name EndlessMode extends ModeBase
## Endless mode implementation - the default gameplay mode.
## No win condition, score-based metric, passthrough orb collection.
## Game over is handled by GameOverEvent when the ball drops.


#region Lifecycle Hooks

## No initialization needed for endless mode
func _on_start() -> void:
	pass


## No per-frame processing needed for endless mode
func _on_process(_delta: float) -> void:
	pass


## Pass through the base score unchanged
func _on_orb_collected(_orb_data: OrbData, base_score: int) -> int:
	return base_score


## Endless mode has no win condition
func _check_win() -> bool:
	return false


## Endless mode lose is handled by GameOverEvent (ball drop)
func _check_lose() -> bool:
	return false


## No cleanup needed for endless mode
func _on_end() -> void:
	pass


#endregion

#region Metric Access

## Return score as the metric
func _get_metric() -> Dictionary:
	return {"name": "score", "value": ScoreManager.get_score()}


## Final score is the current score
func _get_final_score() -> int:
	return ScoreManager.get_score()


#endregion
