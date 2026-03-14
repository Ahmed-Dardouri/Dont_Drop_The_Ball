extends Node
## Singleton that manages active effects with duration, stacking rules, and global state.
## Registered as autoload "EffectManager" in project.godot.

## Duration constant for permanent effects that don't expire automatically.
const DURATION_PERMANENT: float = -1.0

#region Stacking Caps

const SCORE_MULTIPLIER_CAP: float = 10.0
const SLOW_FALL_CAP: float = 0.1
const TIME_SLOW_CAP: float = 0.25

#endregion

#region Inner Classes

## Represents an active effect with tracking data.
class ActiveEffect:
	var effect_id: String
	var value: Variant
	var remaining_duration: float
	var source: Node

	func _init(p_effect_id: String, p_value: Variant, p_duration: float, p_source: Node = null):
		effect_id = p_effect_id
		value = p_value
		remaining_duration = p_duration
		source = p_source

#endregion

#region Private Variables

var _active_effects: Dictionary = {}  # effect_id -> ActiveEffect

#endregion

#region Lifecycle

func _ready() -> void:
	# Listen for game over to clear effects
	Events.add_listener(GameOverEvent, _on_game_over)


func _process(delta: float) -> void:
	# Process effect expiration
	var expired_effects: Array[String] = []

	for effect_id: String in _active_effects.keys():
		var effect: ActiveEffect = _active_effects[effect_id]
		# Skip permanent effects
		if effect.remaining_duration < 0.0:
			continue

		effect.remaining_duration -= delta
		if effect.remaining_duration <= 0.0:
			expired_effects.append(effect_id)

	# Remove expired effects
	for effect_id: String in expired_effects:
		_on_effect_expired(effect_id)

#endregion

#region Public API

## Apply an effect with stacking rules based on effect type.
func apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null) -> void:
	match effect_id:
		"score_multiplier":
			_stack_multiplicative_ceiling(effect_id, value, duration, source, SCORE_MULTIPLIER_CAP)
		"slow_fall":
			_stack_multiplicative_floor(effect_id, value, duration, source, SLOW_FALL_CAP)
		"time_slow":
			_stack_multiplicative_floor(effect_id, value, duration, source, TIME_SLOW_CAP)
			Engine.time_scale = get_effect_value("time_slow")
		"combo_chain":
			_stack_increment(effect_id, value, duration, source)
		"double_value":
			# Single instance, no stacking
			if not has_effect(effect_id):
				_active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)
		"sticky_head":
			# Single instance, refresh duration on reapply
			if has_effect(effect_id):
				_active_effects[effect_id].remaining_duration = duration
			else:
				_active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)
		"has_life":
			# Single instance, non-stackable (max 1 life)
			if not has_effect(effect_id):
				_active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)
		"spawn_speedup":
			# Single instance, refresh duration on reapply
			if has_effect(effect_id):
				_active_effects[effect_id].remaining_duration = duration
			else:
				_active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)
		_:
			# Default: replace existing effect
			_active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)


## Remove an effect by ID.
func remove_effect(effect_id: String) -> void:
	if _active_effects.has(effect_id):
		_active_effects.erase(effect_id)

		# Restore time_scale if time_slow was removed
		if effect_id == "time_slow":
			Engine.time_scale = 1.0


## Check if an effect is currently active.
func has_effect(effect_id: String) -> bool:
	return _active_effects.has(effect_id)


## Get the current value of an effect, or null if not active.
func get_effect_value(effect_id: String) -> Variant:
	if not _active_effects.has(effect_id):
		return null
	return _active_effects[effect_id].value


## Clear all active effects.
func clear_all_effects() -> void:
	_active_effects.clear()
	Engine.time_scale = 1.0

#endregion

#region Private Helpers

func _stack_multiplicative_ceiling(effect_id: String, value: Variant, duration: float, source: Node, cap: float) -> void:
	# Ceiling cap: value should not exceed cap (e.g., score_multiplier capped at 10x)
	if has_effect(effect_id):
		var current: ActiveEffect = _active_effects[effect_id]
		var new_value: float = float(current.value) * float(value)
		current.value = min(new_value, cap)
		current.remaining_duration = duration
	else:
		_active_effects[effect_id] = ActiveEffect.new(effect_id, float(value), duration, source)


func _stack_multiplicative_floor(effect_id: String, value: Variant, duration: float, source: Node, cap: float) -> void:
	# Floor cap: value should not go below cap (e.g., time_slow capped at 0.25x)
	if has_effect(effect_id):
		var current: ActiveEffect = _active_effects[effect_id]
		var new_value: float = float(current.value) * float(value)
		current.value = max(new_value, cap)
		current.remaining_duration = duration
	else:
		_active_effects[effect_id] = ActiveEffect.new(effect_id, float(value), duration, source)


func _stack_increment(effect_id: String, value: Variant, duration: float, source: Node) -> void:
	if has_effect(effect_id):
		var current: ActiveEffect = _active_effects[effect_id]
		current.value = int(current.value) + int(value)
		# Refresh duration on stack
		current.remaining_duration = duration
	else:
		_active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)


func _on_effect_expired(effect_id: String) -> void:
	_active_effects.erase(effect_id)

	# Restore time_scale if time_slow expired
	if effect_id == "time_slow":
		Engine.time_scale = 1.0

	# Notify when life effect expires
	if effect_id == "has_life":
		LifeChangedEvent.invoke(false)


func _on_game_over(_event: GameOverEvent) -> void:
	clear_all_effects()

#endregion
