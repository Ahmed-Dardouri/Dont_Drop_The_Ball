extends GutTest
## Unit tests for AugmentManager singleton

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


func test_apply_augment_stacks_when_stackable() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	var augment: Resource = choices[0]

	AugmentManager.apply_augment(augment)
	AugmentManager.apply_augment(augment)
	var stacks: int = AugmentManager.get_augment_stacks(augment.augment_id)

	assert_eq(stacks, 2, "Second application should result in 2 stacks")


func test_get_augment_stacks_returns_correct_count() -> void:
	var choices: Array = AugmentManager.get_random_choices()
	var augment: Resource = choices[0]

	AugmentManager.apply_augment(augment)
	AugmentManager.apply_augment(augment)

	var stacks: int = AugmentManager.get_augment_stacks(augment.augment_id)
	assert_eq(stacks, 2, "Should return 2 stacks")


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
	# Should not crash, just log warning
	AugmentManager.apply_augment(null)
	assert_true(true, "Should handle null gracefully")


func test_has_augment_returns_false_for_nonexistent() -> void:
	assert_false(AugmentManager.has_augment("nonexistent"), "Should return false for nonexistent augment")


func test_get_augment_stacks_returns_zero_for_nonexistent() -> void:
	var stacks: int = AugmentManager.get_augment_stacks("nonexistent")
	assert_eq(stacks, 0, "Should return 0 for nonexistent augment")
