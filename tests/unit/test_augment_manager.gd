extends GutTest
## Unit tests for AugmentManager singleton with UNIQUE/REPEATABLE support.


func before_each() -> void:
	AugmentManager.clear_augments()
	AugmentManager._game_time = 0.0


func test_get_random_choices_returns_three_choices() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	assert_eq(choices.size(), 3, "Should return 3 choices")


func test_apply_augment_increases_stack() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	var augment: Resource = choices[0]
	AugmentManager.apply_augment(augment)
	var stacks: int = AugmentManager.get_augment_stacks(augment.augment_id)
	assert_eq(stacks, 1, "First application should result in 1 stack")


func test_apply_augment_tracks_active_augments() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	var augment: Resource = choices[0]
	AugmentManager.apply_augment(augment)
	assert_true(AugmentManager.has_augment(augment.augment_id), "Should have augment after application")


func test_apply_repeatable_augment_stacks() -> void:
	# Find a REPEATABLE augment to test stacking
	var repeatable: Resource = _find_repeatable_augment()
	if repeatable == null:
		push_warning("No repeatable augment found, skipping stack test")
		return

	AugmentManager.apply_augment(repeatable)
	AugmentManager.apply_augment(repeatable)
	var stacks: int = AugmentManager.get_augment_stacks(repeatable.augment_id)

	assert_eq(stacks, 2, "Repeatable augment should stack to 2 after two applications")


func test_apply_unique_augment_blocked_on_second_pick() -> void:
	var unique: Resource = _find_unique_augment()
	if unique == null:
		push_warning("No unique augment found, skipping unique block test")
		return

	AugmentManager.apply_augment(unique)
	assert_eq(AugmentManager.get_augment_stacks(unique.augment_id), 1, "First pick should work")

	AugmentManager.apply_augment(unique)
	assert_eq(AugmentManager.get_augment_stacks(unique.augment_id), 1, "Second pick of UNIQUE should be blocked")


func test_unique_augments_excluded_from_draft() -> void:
	var unique: Resource = _find_unique_augment()
	if unique == null:
		push_warning("No unique augment found, skipping draft exclusion test")
		return

	# Pick the unique augment
	AugmentManager.apply_augment(unique)

	# Draft many times - the unique augment should never appear
	for i: int in range(50):
		var choices: Array = AugmentManager.get_random_choices()
		for choice: Resource in choices:
			assert_ne(choice.augment_id, unique.augment_id, "Unique augment should not appear in draft after being chosen")


func test_repeatable_augments_remain_in_draft() -> void:
	var repeatable: Resource = _find_repeatable_augment()
	if repeatable == null:
		push_warning("No repeatable augment found, skipping draft inclusion test")
		return

	# Pick the repeatable augment
	AugmentManager.apply_augment(repeatable)

	# Draft many times - the repeatable augment CAN still appear
	var found: bool = false
	for i: int in range(100):
		var choices: Array = AugmentManager.get_random_choices()
		for choice: Resource in choices:
			if choice.augment_id == repeatable.augment_id:
				found = true
				break
		if found:
			break

	assert_true(found, "Repeatable augment should still appear in draft after being chosen")


func test_repeatable_stack_count_starts_at_zero() -> void:
	var repeatable: Resource = _find_repeatable_augment()
	if repeatable == null:
		push_warning("No repeatable augment found, skipping stack start test")
		return

	assert_eq(AugmentManager.get_augment_stacks(repeatable.augment_id), 0, "Stack count should be 0 before first pick")


func test_selection_label_unique() -> void:
	var unique: Resource = _find_unique_augment()
	if unique == null:
		push_warning("No unique augment found, skipping label test")
		return

	var label: String = AugmentManager.get_selection_label(unique)
	assert_eq(label, "Unique", "Unique augment label should be 'Unique'")


func test_selection_label_repeatable_shows_stack_count() -> void:
	var repeatable: Resource = _find_repeatable_augment()
	if repeatable == null:
		push_warning("No repeatable augment found, skipping label test")
		return

	var label_before: String = AugmentManager.get_selection_label(repeatable)
	assert_eq(label_before, "x0", "Repeatable label should show x0 before first pick")

	AugmentManager.apply_augment(repeatable)
	var label_after: String = AugmentManager.get_selection_label(repeatable)
	assert_eq(label_after, "x1", "Repeatable label should show x1 after first pick")


func test_clear_augments_removes_all_augments() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	AugmentManager.apply_augment(choices[0])
	AugmentManager.apply_augment(choices[1])

	AugmentManager.clear_augments()

	assert_eq(AugmentManager.get_active_augment_count(), 0, "Should have no active augments after clear")


func test_get_active_augment_count_returns_correct_number() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	AugmentManager.apply_augment(choices[0])
	AugmentManager.apply_augment(choices[1])

	var count: int = AugmentManager.get_active_augment_count()
	assert_eq(count, 2, "Should have 2 active augments")


func test_apply_invalid_augment_does_not_crash() -> void:
	AugmentManager.apply_augment(null)
	assert_true(true, "Should handle null gracefully")


func test_has_augment_returns_false_for_nonexistent() -> void:
	assert_false(AugmentManager.has_augment("nonexistent"), "Should return false for nonexistent augment")


func test_get_augment_stacks_returns_zero_for_nonexistent() -> void:
	var stacks: int = AugmentManager.get_augment_stacks("nonexistent")
	assert_eq(stacks, 0, "Should return 0 for nonexistent augment")


func test_merged_augments_not_in_pool() -> void:
	# These augment IDs were merged/removed and should not be loadable
	var merged_ids: Array[String] = [
		"collectors_habit", "safety_net", "paper_trail", "room_to_breathe",
		"soft_fuse", "sharp_line", "long_reach", "fast_lane", "top_shelf",
		"rent_was_due", "savings_account", "more_lives_more_problems",
		"life_insurance", "kaboom_deluxe", "full_screen_insurance",
		"line_em_up", "laser_but_horizontal", "black_hole_budget_cut",
		"rainmaker", "lucky_penny", "main_score_augment", "special_delivery",
		"jackpot_bonus"
	]
	for merged_id: String in merged_ids:
		assert_false(AugmentManager._augment_cache.has(merged_id), "Merged augment '%s' should not be in pool" % merged_id)


func test_draft_still_returns_three_valid_cards() -> void:
	# Ensure draft works after cleanup
	for i: int in range(10):
		AugmentManager.clear_augments()
		AugmentManager._game_time = 0.0
		var choices: Array = AugmentManager.get_random_choices()
		assert_eq(choices.size(), 3, "Draft %d should return 3 cards" % i)
		for choice: Resource in choices:
			assert_not_null(choice, "Each choice should be non-null")
			assert_true(choice.is_valid(), "Each choice should be valid")


	# --- Stack Progression Tests ---

func test_stack_value_returns_table_entry() -> void:
	# Stack 1 should return index 1 of the table
	assert_eq(AugmentManager.get_stack_value("pocket_change", 1), 3.0, "Stack 1 pocket_change = 3")
	assert_eq(AugmentManager.get_stack_value("pocket_change", 2), 5.0, "Stack 2 pocket_change = 5")
	assert_eq(AugmentManager.get_stack_value("pocket_change", 3), 7.0, "Stack 3 pocket_change = 7")


func test_stack_value_clamps_beyond_table() -> void:
	# Stack 10 should return the last entry (soft cap)
	assert_eq(AugmentManager.get_stack_value("pocket_change", 10), 9.0, "Stack 10 should clamp to last table entry 9")
	assert_eq(AugmentManager.get_stack_value("pocket_change", 100), 9.0, "Stack 100 should clamp to last table entry")


func test_stack_value_zero_for_missing_table() -> void:
	assert_eq(AugmentManager.get_stack_value("nonexistent_table", 1), 0.0, "Missing table should return 0")


func test_stack_value_stack_0_returns_0() -> void:
	assert_eq(AugmentManager.get_stack_value("pocket_change", 0), 0.0, "Stack 0 should return 0 (index 0)")


func test_score_repeatable_scales_with_stacks() -> void:
	# pocket_change is repeatable score augment
	var aug: Resource = _find_repeatable_by_key("pocket_change")
	if aug == null:
		pending("pocket_change not found in pool")
		return

	# Apply 3 stacks and check cumulative bonus increases each time
	var before_1: int = Variables.score_per_orb_bonus
	AugmentManager.apply_augment(aug)
	var after_1: int = Variables.score_per_orb_bonus
	var gain_1: int = after_1 - before_1
	assert_eq(gain_1, 3, "Stack 1 pocket_change should add 3")

	var before_2: int = Variables.score_per_orb_bonus
	AugmentManager.apply_augment(aug)
	var after_2: int = Variables.score_per_orb_bonus
	var gain_2: int = after_2 - before_2
	assert_eq(gain_2, 5, "Stack 2 pocket_change should add 5")
	assert_true(gain_2 > gain_1, "Stack 2 should be stronger than stack 1")

	var before_3: int = Variables.score_per_orb_bonus
	AugmentManager.apply_augment(aug)
	var after_3: int = Variables.score_per_orb_bonus
	var gain_3: int = after_3 - before_3
	assert_eq(gain_3, 7, "Stack 3 pocket_change should add 7")
	assert_true(gain_3 > gain_2, "Stack 3 should be stronger than stack 2")


func test_burst_repeatable_scales_with_stacks() -> void:
	var aug: Resource = _find_repeatable_by_key("snack_sized_boom")
	if aug == null:
		pending("snack_sized_boom not found in pool")
		return

	var before_1: float = Variables.burst_radius_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.burst_radius_bonus - before_1
	assert_true(gain_1 > 0.0, "Stack 1 should add burst radius")

	var before_2: float = Variables.burst_radius_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.burst_radius_bonus - before_2
	assert_true(gain_2 > gain_1, "Stack 2 burst should be stronger than stack 1")

	var before_3: float = Variables.burst_radius_bonus
	AugmentManager.apply_augment(aug)
	var gain_3: float = Variables.burst_radius_bonus - before_3
	assert_true(gain_3 > gain_2, "Stack 3 burst should be stronger than stack 2")


func test_vortex_radius_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("bigger_vacuum")
	if aug == null:
		pending("bigger_vacuum not found in pool")
		return

	var before_1: float = Variables.vortex_radius_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.vortex_radius_bonus - before_1

	var before_2: float = Variables.vortex_radius_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.vortex_radius_bonus - before_2

	assert_true(gain_2 > gain_1, "Stack 2 vortex should be stronger than stack 1")
	# Check diminishing returns: gain_3 - gain_2 < gain_2 - gain_1
	var before_3: float = Variables.vortex_radius_bonus
	AugmentManager.apply_augment(aug)
	var gain_3: float = Variables.vortex_radius_bonus - before_3
	assert_true(gain_3 > gain_2, "Stack 3 vortex should still be stronger")
	assert_true(gain_3 - gain_2 < gain_2 - gain_1, "Diminishing returns: growth from 2->3 should be smaller than 1->2")


func test_vortex_duration_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("long_lunch")
	if aug == null:
		pending("long_lunch not found in pool")
		return

	var before_1: float = Variables.vortex_duration_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.vortex_duration_bonus - before_1

	var before_2: float = Variables.vortex_duration_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.vortex_duration_bonus - before_2

	assert_true(gain_2 > gain_1, "Stack 2 vortex duration should be stronger")
	assert_true(gain_1 > 0.0, "Stack 1 should add positive duration")


func test_line_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("wide_sweep")
	if aug == null:
		pending("wide_sweep not found in pool")
		return

	var before_1: float = Variables.line_clear_range_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.line_clear_range_bonus - before_1

	var before_2: float = Variables.line_clear_range_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.line_clear_range_bonus - before_2

	assert_true(gain_2 > gain_1, "Stack 2 line should be stronger than stack 1")


func test_spawn_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("orb_buffet")
	if aug == null:
		pending("orb_buffet not found in pool")
		return

	var before_1: float = Variables.orb_spawn_rate_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.orb_spawn_rate_bonus - before_1

	var before_2: float = Variables.orb_spawn_rate_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.orb_spawn_rate_bonus - before_2

	assert_true(gain_2 > gain_1, "Stack 2 spawn should be stronger than stack 1")
	# Spawn should scale carefully (not too fast)
	assert_true(gain_2 < gain_1 * 2.0, "Spawn scaling should be controlled (not double)")


func test_life_repeatable_scales_conservatively() -> void:
	# just_one_more always gives +1 life, but caps at MAX_STACK_CAP
	var aug: Resource = _find_repeatable_by_key("just_one_more")
	if aug == null:
		pending("just_one_more not found in pool")
		return

	var lives_before: int = Variables.permanent_lives
	AugmentManager.apply_augment(aug)
	assert_eq(Variables.permanent_lives, lives_before + 1, "Stack 1 should add 1 life")

	AugmentManager.apply_augment(aug)
	assert_eq(Variables.permanent_lives, lives_before + 2, "Stack 2 should add 1 more life")


func test_life_repeatable_caps_at_max_stack() -> void:
	var aug: Resource = _find_repeatable_by_key("just_one_more")
	if aug == null:
		pending("just_one_more not found in pool")
		return

	# Apply MAX_STACK_CAP + 2 times to test cap
	var lives_start: int = Variables.permanent_lives
	for i: int in range(AugmentManager.MAX_STACK_CAP + 2):
		AugmentManager.apply_augment(aug)

	# Should have gained exactly MAX_STACK_CAP lives (extra stacks beyond cap give no more lives)
	var lives_gained: int = Variables.permanent_lives - lives_start
	assert_eq(lives_gained, AugmentManager.MAX_STACK_CAP, "just_one_more should cap at MAX_STACK_CAP lives")


func test_meter_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("easy_money")
	if aug == null:
		pending("easy_money not found in pool")
		return

	var before_1: float = Variables.meter_fill_multiplier
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.meter_fill_multiplier - before_1

	var before_2: float = Variables.meter_fill_multiplier
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.meter_fill_multiplier - before_2

	assert_true(gain_2 > gain_1, "Stack 2 meter should be stronger than stack 1")
	# Meter should scale carefully
	assert_true(gain_2 < gain_1 * 2.0, "Meter scaling should be controlled")


func test_meter_drain_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("catch_a_break")
	if aug == null:
		pending("catch_a_break not found in pool")
		return

	var before_1: float = Variables.meter_drain_reduction
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.meter_drain_reduction - before_1

	var before_2: float = Variables.meter_drain_reduction
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.meter_drain_reduction - before_2

	assert_true(gain_2 > gain_1, "Stack 2 drain reduction should be stronger")
	assert_true(gain_2 < gain_1 * 2.0, "Drain scaling should be controlled")


func test_hybrid_repeatable_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("extra_hands")
	if aug == null:
		pending("extra_hands not found in pool")
		return

	var before_1: float = Variables.collection_range_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: float = Variables.collection_range_bonus - before_1

	var before_2: float = Variables.collection_range_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: float = Variables.collection_range_bonus - before_2

	assert_true(gain_2 > gain_1, "Stack 2 collection range should be stronger")


func test_score_repeatable_payroll_upgrade_scales() -> void:
	var aug: Resource = _find_repeatable_by_key("payroll_upgrade")
	if aug == null:
		pending("payroll_upgrade not found in pool")
		return

	var before_1: int = Variables.score_per_orb_bonus
	AugmentManager.apply_augment(aug)
	var gain_1: int = Variables.score_per_orb_bonus - before_1
	assert_eq(gain_1, 5, "Stack 1 payroll_upgrade = 5")

	var before_2: int = Variables.score_per_orb_bonus
	AugmentManager.apply_augment(aug)
	var gain_2: int = Variables.score_per_orb_bonus - before_2
	assert_eq(gain_2, 8, "Stack 2 payroll_upgrade = 8")

	var before_3: int = Variables.score_per_orb_bonus
	AugmentManager.apply_augment(aug)
	var gain_3: int = Variables.score_per_orb_bonus - before_3
	assert_eq(gain_3, 11, "Stack 3 payroll_upgrade = 11")


func test_scaling_is_bounded_beyond_cap() -> void:
	# Apply pocket_change many times; growth should plateau
	var aug: Resource = _find_repeatable_by_key("pocket_change")
	if aug == null:
		pending("pocket_change not found in pool")
		return

	var prev_gain: float = INF
	for i: int in range(10):
		var before: int = Variables.score_per_orb_bonus
		AugmentManager.apply_augment(aug)
		var gain: float = Variables.score_per_orb_bonus - before
		if i >= 5:
			# Beyond the table, all gains should be the same (last entry)
			assert_eq(gain, prev_gain, "Gains beyond cap should be constant (soft cap)")
		prev_gain = gain


func test_unique_augment_ignores_stack_parameter() -> void:
	# Unique augments should still work normally despite the new stack param
	var unique: Resource = _find_unique_augment()
	if unique == null:
		pending("No unique augment found")
		return

	AugmentManager.apply_augment(unique)
	assert_eq(AugmentManager.get_augment_stacks(unique.augment_id), 1, "Unique should have 1 stack")

	# Second application should be blocked
	AugmentManager.apply_augment(unique)
	assert_eq(AugmentManager.get_augment_stacks(unique.augment_id), 1, "Unique second pick blocked")


	# --- Helpers ---

func _find_repeatable_augment() -> Resource:
	for augment: AugmentData in AugmentManager._all_augments:
		if augment.selection_mode == Enums.AugmentSelectionMode.REPEATABLE:
			return augment
	return null


func _find_unique_augment() -> Resource:
	for augment: AugmentData in AugmentManager._all_augments:
		if augment.selection_mode == Enums.AugmentSelectionMode.UNIQUE:
			return augment
	return null


func _find_repeatable_by_key(key: String) -> Resource:
	for augment: AugmentData in AugmentManager._all_augments:
		if augment.selection_mode == Enums.AugmentSelectionMode.REPEATABLE and augment.augment_key == key:
			return augment
	return null
