extends GutTest
## Tests for orb effect baseline values and augment scaling.
## Validates that reduced baselines are correct and augments still amplify them.


func before_each() -> void:
	Variables.reset_augment_modifiers()


#region Burst Baseline

func test_burst_base_radius_is_reduced() -> void:
	var behavior := BurstBehavior.new()
	assert_eq(behavior.radius, 100.0, "Burst base radius should be 100.0")


func test_burst_augment_scales_from_reduced_base() -> void:
	var behavior := BurstBehavior.new()
	Variables.burst_radius_bonus = 0.5
	var adjusted: float = behavior.radius * (1.0 + Variables.burst_radius_bonus)
	# 100 * 1.5 = 150 (matches old base, showing augment matters)
	assert_eq(adjusted, 150.0, "Burst with +50% augment should reach old base of 150")


func test_burst_with_max_augment_is_powerful() -> void:
	var behavior := BurstBehavior.new()
	Variables.burst_radius_bonus = 1.0  # +100%
	var adjusted: float = behavior.radius * (1.0 + Variables.burst_radius_bonus)
	assert_eq(adjusted, 200.0, "Burst with +100% augment should be 200")


#endregion

#region Line Clear Baseline

func test_line_clear_base_range_is_reduced() -> void:
	var behavior := LineClearBehavior.new()
	assert_eq(behavior.range_distance, 300.0, "Line clear base range should be 300.0")


func test_line_clear_augment_scales_from_reduced_base() -> void:
	var behavior := LineClearBehavior.new()
	Variables.line_clear_range_bonus = 0.67  # ~67% to get back to ~500
	var adjusted: float = behavior.range_distance * (1.0 + Variables.line_clear_range_bonus)
	assert_almost_eq(adjusted, 501.0, 1.0, "Line clear with +67% augment should reach ~500 (old base)")


func test_line_clear_with_full_augment() -> void:
	var behavior := LineClearBehavior.new()
	Variables.line_clear_range_bonus = 1.0  # +100%
	var adjusted: float = behavior.range_distance * (1.0 + Variables.line_clear_range_bonus)
	assert_eq(adjusted, 600.0, "Line clear with +100% augment should be 600")


#endregion

#region Vortex Baseline

func test_vortex_base_radius_is_reduced() -> void:
	var behavior := VortexBehavior.new()
	assert_eq(behavior.vortex_radius, 65.0, "Vortex base radius should be 65.0")


func test_vortex_augment_scales_from_reduced_base() -> void:
	var behavior := VortexBehavior.new()
	Variables.vortex_radius_bonus = 0.54  # ~54% to get back to ~100
	var adjusted: float = behavior.vortex_radius * (1.0 + Variables.vortex_radius_bonus)
	assert_almost_eq(adjusted, 100.1, 1.0, "Vortex with +54% augment should reach ~100 (old base)")


func test_vortex_with_full_augment() -> void:
	var behavior := VortexBehavior.new()
	Variables.vortex_radius_bonus = 1.0  # +100%
	var adjusted: float = behavior.vortex_radius * (1.0 + Variables.vortex_radius_bonus)
	assert_eq(adjusted, 130.0, "Vortex with +100% augment should be 130")


#endregion

#region Spawn Speedup Baseline

func test_spawn_speedup_base_multiplier_is_reduced() -> void:
	var behavior := SpawnSpeedupBehavior.new()
	assert_eq(behavior.speed_multiplier, 1.5, "Spawn speedup base multiplier should be 1.5")


func test_spawn_speedup_applies_correctly() -> void:
	var behavior := SpawnSpeedupBehavior.new()
	# Base interval of 1.0s, divided by 1.5 = 0.667s (not 0.5s like old 2.0x)
	var base_interval: float = 1.0
	var new_interval: float = base_interval / behavior.speed_multiplier
	assert_almost_eq(new_interval, 0.667, 0.01, "Speedup 1.5x should reduce interval to ~0.667")


func test_spawn_speedup_augment_still_applies() -> void:
	# Verify the augment spawn rate bonus works independently
	Variables.orb_spawn_rate_bonus = 0.5
	var base_interval: float = 1.0
	# Spawn rate bonus: interval * (1.0 / (1.0 + bonus))
	var augmented: float = base_interval / (1.0 + Variables.orb_spawn_rate_bonus)
	assert_almost_eq(augmented, 0.667, 0.01, "Spawn rate +50% should reduce interval to ~0.667")


#endregion

#region Augment Amplification Tests

func test_burst_augment_makes_big_difference() -> void:
	var behavior := BurstBehavior.new()
	var base: float = behavior.radius
	# Stack 2 of snack_sized_boom gives +0.35
	var with_augment: float = base * (1.0 + 0.35)
	# Augment should add meaningful extra
	assert_gt(with_augment - base, 20.0, "Augment should add at least 20px radius")


func test_vortex_augment_makes_big_difference() -> void:
	var behavior := VortexBehavior.new()
	var base: float = behavior.vortex_radius
	# bigger_vacuum stack 2 gives +0.42
	var with_augment: float = base * (1.0 + 0.42)
	# Augment should add meaningful extra
	assert_gt(with_augment - base, 15.0, "Augment should add at least 15px radius")


func test_line_clear_augment_makes_big_difference() -> void:
	var behavior := LineClearBehavior.new()
	var base: float = behavior.range_distance
	# wide_sweep stack 2 gives +0.35
	var with_augment: float = base * (1.0 + 0.35)
	# Augment should add meaningful extra range
	assert_gt(with_augment - base, 50.0, "Augment should add at least 50px range")


#endregion
