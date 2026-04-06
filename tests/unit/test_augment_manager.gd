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
