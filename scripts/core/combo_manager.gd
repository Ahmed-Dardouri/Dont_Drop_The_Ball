extends Node
## Combo Manager - Tracks combo state for orb collection between ball-player hits.
## Combo bonus grows exponentially: 1, 2, 4, 8, 16... capped at 256.
## Resets when the ball hits the player's head.

## Maximum combo bonus (cap for exponential growth)
const MAX_COMBO_BONUS: int = 256

## Emitted when combo resets (ball hit player)
signal combo_reset

## Emitted when combo bonus changes (orb collected)
signal combo_bonus_changed(base_score: int, combo_bonus: int, total: int)

## Current combo bonus (exponential: starts at 1, doubles each orb, capped at 256)
var _current_combo_bonus: int = 1


func _ready() -> void:
	Events.add_listener(BallHeadHitEvent, _on_ball_head_hit)


## Called when ball hits player's head - resets combo.
func _on_ball_head_hit(_event: BallHeadHitEvent) -> void:
	reset_combo()


## Resets the combo bonus to 1.
func reset_combo() -> void:
	_current_combo_bonus = 1
	combo_reset.emit()


## Called when an orb is collected - adds combo bonus to score.
## Returns a dictionary with base_score, combo_bonus, and total.
func add_orb_score(base_score: int) -> Dictionary:
	# Apply double value if active (doubles the score)
	var adjusted_base: int = base_score
	if EffectManager.has_effect("double_value"):
		adjusted_base *= 2

	# Apply score multiplier if active
	var multiplier: Variant = EffectManager.get_effect_value("score_multiplier")
	if multiplier != null:
		adjusted_base = int(adjusted_base * float(multiplier))

	# Combo bonus is independent of base score (exponential: 1, 2, 4, 8...)
	var combo_bonus: int = _current_combo_bonus
	var total: int = adjusted_base + combo_bonus

	# Add to score
	ScoreManager.add_score(total)

	# Emit signal for UI
	combo_bonus_changed.emit(adjusted_base, combo_bonus, total)

	# Double combo bonus for next orb (exponential growth, capped at MAX_COMBO_BONUS)
	_current_combo_bonus = mini(_current_combo_bonus * 2, MAX_COMBO_BONUS)

	return {"base_score": adjusted_base, "combo_bonus": combo_bonus, "total": total}


## Gets the current combo bonus multiplier.
func get_combo_bonus() -> int:
	return _current_combo_bonus


## Gets the next combo bonus multiplier (preview, capped).
func get_next_combo_bonus() -> int:
	return mini(_current_combo_bonus * 2, MAX_COMBO_BONUS)
