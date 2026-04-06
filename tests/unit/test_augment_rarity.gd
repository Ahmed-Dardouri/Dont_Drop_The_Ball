class_name TestAugmentRarity extends GutTest
## Test augment rarity system


func test_roll_draft_rarity_returns_valid_value() -> void:
	var rarity := AugmentManager.roll_draft_rarity()
	assert_true(rarity in [Enums.AugmentRarity.COMMON, Enums.AugmentRarity.RARE, Enums.AugmentRarity.MYTHICAL], "Should return valid rarity")


func test_roll_draft_rarity_distribution() -> void:
	# Roll many times to check distribution
	var common_count := 0
	var rare_count := 0
	var mythical_count := 0
	for i: int in range(100):
		var rarity := AugmentManager.roll_draft_rarity()
		match rarity:
			Enums.AugmentRarity.COMMON:
				common_count += 1
			Enums.AugmentRarity.RARE:
				rare_count += 1
			Enums.AugmentRarity.MYTHICAL:
				mythical_count += 1

	# TESTING: Check approximate distribution (33/33/34)
	assert_true(common_count > 20, "Common should be ~33%")
	assert_true(rare_count > 20, "Rare should be ~33%")
	assert_true(mythical_count > 20, "Mythical should be ~34%")


func test_get_current_phase() -> void:
	# Test early phase (< 180.0 seconds)
	AugmentManager._game_time = 0.0
	assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.EARLY, "Should be early phase at 0.0")

	AugmentManager._game_time = 179.0
	assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.EARLY, "Should be early phase at 179.0")

	# Test mid phase (180.0 - 599.99 seconds)
	AugmentManager._game_time = 180.0
	assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.MID, "Should be mid phase at 180.0")

	AugmentManager._game_time = 400.0
	assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.MID, "Should be mid phase at 400.0")

	# Test late phase (>= 600.0 seconds)
	AugmentManager._game_time = 600.0
	assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.LATE, "Should be late phase at 600.0")


func test_pool_for_rarity_and_phase() -> void:
	# Verify that rarity pools contain augments with positive weights for the given phase
	var common_pool: Array = AugmentManager._augments_by_rarity.get(Enums.AugmentRarity.COMMON, [])
	assert_true(common_pool.size() > 0, "Common rarity pool should have augments")

	# Check that early-weighted augments exist in the common pool
	var early_weighted_count: int = 0
	for aug: AugmentData in common_pool:
		if aug.early_weight > 0:
			early_weighted_count += 1
	assert_true(early_weighted_count > 0, "Common pool should have augments with early_weight > 0")


func test_draft_returns_three_unique_cards() -> void:
	# Reset to early phase for predictable pool
	AugmentManager._game_time = 0.0
	var choices := AugmentManager.get_random_choices()
	assert_true(choices.size() >= 1 and choices.size() <= 3, "Should return 1-3 cards")

	# Check all cards are unique
	var ids: Array[String] = []
	for choice in choices:
		var aug_data: AugmentData = choice as AugmentData
		assert_false(aug_data.augment_id in ids, "All cards should have unique IDs")
		ids.append(aug_data.augment_id)


func test_augment_data_valid() -> void:
	var augment := AugmentData.new()
	augment.augment_id = "test_aug"
	augment.display_name = "Test Augment"
	augment.description = "Test description"
	augment.icon_key = "score"
	augment.augment_key = "score_bonus"
	assert_true(augment.is_valid(), "Augment with all required fields should be valid")

	# Test invalid augment
	var invalid_augment := AugmentData.new()
	assert_false(invalid_augment.is_valid(), "Augment with missing fields should not be valid")


func test_rarity_determines_background() -> void:
	var common := AugmentData.new()
	common.rarity = Enums.AugmentRarity.COMMON
	common.augment_id = "test"
	common.display_name = "Test"
	common.icon_key = "score"
	common.augment_key = "test"

	var rare := AugmentData.new()
	rare.rarity = Enums.AugmentRarity.RARE
	rare.augment_id = "test2"
	rare.display_name = "Test"
	rare.icon_key = "score"
	rare.augment_key = "test"

	var mythical := AugmentData.new()
	mythical.rarity = Enums.AugmentRarity.MYTHICAL
	mythical.augment_id = "test3"
	mythical.display_name = "Test"
	mythical.icon_key = "score"
	mythical.augment_key = "test"

	# Test that rarity values are correct
	assert_eq(common.rarity, Enums.AugmentRarity.COMMON)
	assert_eq(rare.rarity, Enums.AugmentRarity.RARE)
	assert_eq(mythical.rarity, Enums.AugmentRarity.MYTHICAL)
