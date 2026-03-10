extends GutTest

## Unit tests for TimedModifierBehavior.
## Tests the effect application through EffectManager.

var _behavior: TimedModifierBehavior
var _context: Dictionary


func before_each() -> void:
	_behavior = TimedModifierBehavior.new()
	_context = {"orb": null, "orb_data": null, "collector": null}
	# Clear any existing effects before each test
	EffectManager.clear_all_effects()


func after_each() -> void:
	# Clean up effects after each test
	EffectManager.clear_all_effects()


#region Tests

func test_effect_applied() -> void:
	# Given
	_behavior.effect_id = "slow_fall"
	_behavior.value = 0.5
	_behavior.duration = 45.0

	# When
	_behavior.execute(_context)

	# Then
	assert_true(EffectManager.has_effect("slow_fall"), "Effect should be applied")


func test_empty_effect_id_skipped() -> void:
	# Given
	_behavior.effect_id = ""
	_behavior.value = 0.5
	_behavior.duration = 45.0

	# When - should not crash
	_behavior.execute(_context)

	# Then - no effect applied
	assert_false(EffectManager.has_effect("slow_fall"), "No effect should be applied for empty effect_id")


func test_value_passed_correctly() -> void:
	# Given
	_behavior.effect_id = "score_multiplier"
	_behavior.value = 2.5
	_behavior.duration = 30.0

	# When
	_behavior.execute(_context)

	# Then
	var effect_value: Variant = EffectManager.get_effect_value("score_multiplier")
	assert_not_null(effect_value, "Effect value should not be null")
	assert_eq(2.5, effect_value, "Effect value should match the passed value")


func test_default_values() -> void:
	# Given - fresh behavior with defaults
	var fresh_behavior: TimedModifierBehavior = TimedModifierBehavior.new()

	# Then
	assert_eq("", fresh_behavior.effect_id, "Default effect_id should be empty string")
	assert_eq(1.0, fresh_behavior.value, "Default value should be 1.0")
	assert_eq(10.0, fresh_behavior.duration, "Default duration should be 10.0")
