class_name ModeBase extends RefCounted
## Abstract base class for game mode implementations.
## Provides lifecycle hooks that ModeManager calls during gameplay.
## Concrete modes (EndlessMode, TimeAttackMode, etc.) extend this class.

## The mode configuration this implementation is associated with
var config: ModeConfig


#region Lifecycle Hooks

## Called when the mode starts. Override to initialize mode state.
func _on_start() -> void:
	pass


## Called every frame during gameplay. Override for time-based logic.
## @param delta: Time elapsed since last frame in seconds
func _on_process(_delta: float) -> void:
	pass


## Called when an orb is collected. Override to modify scoring.
## @param orb_data: The collected orb's data (may be null)
## @param base_score: The base score value for this orb
## @returns: Modified score value (default: returns base_score unchanged)
func _on_orb_collected(_orb_data: OrbData, base_score: int) -> int:
	return base_score


## Check if the player has won. Override to add win conditions.
## @returns: true if win condition is met, false otherwise
func _check_win() -> bool:
	return false


## Check if the player has lost. Override to add lose conditions.
## Note: Ball drop game over is handled by GameOverEvent, not this hook.
## @returns: true if lose condition is met, false otherwise
func _check_lose() -> bool:
	return false


## Called when the mode ends. Override for cleanup.
func _on_end() -> void:
	pass


#endregion

#region Metric Access

## Get the current metric for HUD display.
## @returns: Dictionary with "name" and "value" keys
func _get_metric() -> Dictionary:
	return {"name": "score", "value": ScoreManager.get_score()}


## Get the final score when the mode ends.
## @returns: Final score value
func _get_final_score() -> int:
	return ScoreManager.get_score()


#endregion
