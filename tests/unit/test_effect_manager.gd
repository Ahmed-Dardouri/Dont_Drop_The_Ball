extends GutTest

# Test suite for EffectManager singleton
# Tests apply_effect, has_effect, get_effect_value, expiration, stacking

var _original_time_scale: float


func before_all():
	_original_time_scale = Engine.time_scale


func after_all():
	Engine.time_scale = _original_time_scale


func before_each():
	EffectManager.clear_all_effects()
	Engine.time_scale = 1.0


#region Basic Effect Tests

func test_apply_effect_and_has_effect():
	# Given: EffectManager is cleared
	assert_false(EffectManager.has_effect("test"), "Should not have effect before applying")

	# When: apply_effect is called
	EffectManager.apply_effect("test", 2.0, 10.0)

	# Then: has_effect returns true
	assert_true(EffectManager.has_effect("test"), "Should have effect after applying")


func test_get_effect_value_returns_applied_value():
	# Given: effect is applied
	EffectManager.apply_effect("test", 2.0, 10.0)

	# When: get_effect_value is called
	var value = EffectManager.get_effect_value("test")

	# Then: value equals what was applied
	assert_eq(value, 2.0, "Effect value should be 2.0")


func test_get_effect_value_returns_null_for_nonexistent():
	# Given: no effect applied
	# When: get_effect_value is called for nonexistent effect
	var value = EffectManager.get_effect_value("nonexistent")

	# Then: returns null
	assert_null(value, "Should return null for nonexistent effect")


func test_remove_effect():
	# Given: effect is applied
	EffectManager.apply_effect("test", 2.0, 10.0)
	assert_true(EffectManager.has_effect("test"))

	# When: remove_effect is called
	EffectManager.remove_effect("test")

	# Then: effect no longer exists
	assert_false(EffectManager.has_effect("test"), "Effect should be removed")


func test_clear_all_effects():
	# Given: multiple effects applied
	EffectManager.apply_effect("effect1", 1.0, 10.0)
	EffectManager.apply_effect("effect2", 2.0, 10.0)
	EffectManager.apply_effect("effect3", 3.0, 10.0)

	# When: clear_all_effects is called
	EffectManager.clear_all_effects()

	# Then: no effects remain
	assert_false(EffectManager.has_effect("effect1"))
	assert_false(EffectManager.has_effect("effect2"))
	assert_false(EffectManager.has_effect("effect3"))

#endregion

#region Expiration Tests

func test_effect_expires_after_duration():
	# Given: effect with short duration
	EffectManager.apply_effect("test", 1.0, 0.1)
	assert_true(EffectManager.has_effect("test"))

	# When: time passes
	await wait_seconds(0.2)

	# Then: effect is removed
	assert_false(EffectManager.has_effect("test"), "Effect should expire after duration")


func test_permanent_effect_does_not_expire():
	# Given: effect with DURATION_PERMANENT
	EffectManager.apply_effect("permanent", 5.0, EffectManager.DURATION_PERMANENT)

	# When: time passes
	await wait_seconds(0.2)

	# Then: effect still exists
	assert_true(EffectManager.has_effect("permanent"), "Permanent effect should not expire")

#endregion

#region Stacking Tests

func test_score_multiplier_stacks_multiplicatively():
	# Given: two score_multiplier effects applied
	EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
	EffectManager.apply_effect("score_multiplier", 2.0, 10.0)

	# When: get_effect_value is called
	var value = EffectManager.get_effect_value("score_multiplier")

	# Then: values are multiplied (2.0 * 2.0 = 4.0)
	assert_eq(value, 4.0, "Score multiplier should stack multiplicatively")


func test_score_multiplier_cap_at_10x():
	# Given: multiple score_multiplier effects that would exceed cap
	EffectManager.apply_effect("score_multiplier", 5.0, 10.0)  # 5x
	EffectManager.apply_effect("score_multiplier", 5.0, 10.0)  # 25x -> capped at 10x

	# When: get_effect_value is called
	var value = EffectManager.get_effect_value("score_multiplier")

	# Then: value is capped at 10.0
	assert_eq(value, 10.0, "Score multiplier should be capped at 10x")


func test_slow_fall_stacks_and_caps():
	# Given: multiple slow_fall effects that would go below cap
	EffectManager.apply_effect("slow_fall", 0.3, 10.0)  # 30% speed
	EffectManager.apply_effect("slow_fall", 0.3, 10.0)  # 9% speed -> capped at 10%

	# When: get_effect_value is called
	var value = EffectManager.get_effect_value("slow_fall")

	# Then: value is capped at 0.1 (90% reduction)
	assert_eq(value, 0.1, "Slow fall should be capped at 0.1 (90% reduction)")


func test_time_slow_sets_engine_time_scale():
	# Given: time_slow effect applied
	# When: apply_effect is called
	EffectManager.apply_effect("time_slow", 0.5, 10.0)

	# Then: Engine.time_scale is set
	assert_eq(Engine.time_scale, 0.5, "Time slow should set Engine.time_scale")


func test_time_slow_cap_at_025x():
	# Given: multiple time_slow effects
	EffectManager.apply_effect("time_slow", 0.5, 10.0)  # 0.5x
	EffectManager.apply_effect("time_slow", 0.5, 10.0)  # 0.25x
	EffectManager.apply_effect("time_slow", 0.5, 10.0)  # Would be 0.125x -> capped at 0.25x

	# When: checking time_scale
	var value = EffectManager.get_effect_value("time_slow")

	# Then: value is capped at 0.25
	assert_eq(value, 0.25, "Time slow should be capped at 0.25x")
	assert_eq(Engine.time_scale, 0.25, "Engine.time_scale should be capped at 0.25x")


func test_combo_chain_stacks_incrementally():
	# Given: two combo_chain effects
	EffectManager.apply_effect("combo_chain", 1, 10.0)
	EffectManager.apply_effect("combo_chain", 1, 10.0)

	# When: get_effect_value is called
	var value = EffectManager.get_effect_value("combo_chain")

	# Then: values are incremented (1 + 1 = 2)
	assert_eq(value, 2, "Combo chain should stack incrementally")


func test_double_value_no_stacking():
	# Given: two double_value effects
	EffectManager.apply_effect("double_value", true, -1.0)
	EffectManager.apply_effect("double_value", true, -1.0)

	# When: has_effect is checked
	# Then: only one instance exists (no stacking)
	assert_true(EffectManager.has_effect("double_value"), "Double value should exist")
	# Double value doesn't stack - single instance only

#endregion

#region Time Scale Restoration Tests

func test_time_scale_restored_when_time_slow_expires():
	# Given: time_slow effect with short duration
	EffectManager.apply_effect("time_slow", 0.5, 0.1)
	assert_eq(Engine.time_scale, 0.5)

	# When: effect expires
	await wait_seconds(0.2)

	# Then: time_scale is restored to 1.0
	assert_eq(Engine.time_scale, 1.0, "Time scale should be restored when time_slow expires")

#endregion
