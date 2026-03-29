class_name TestAugmentRarity extends GutTest
	## Test augment rarity system

	var rarity: Aug.roll_draft_rarity()

	func test_roll_draft_rarity_returns_common() -> void:
		rarity = AugmentManager.roll_draft_rarity()
		assert_eq(rarity, Enums.AugmentRarity.COMMON, "Should return COMMON")


	func test_roll_draft_rarity_distribution() -> void:
		# Roll many times to check distribution
		var common_count := 0
		var rare_count := 0
		var mythical_count := 0
		for i: int in range(100):
		 rarity = AugmentManager.roll_draft_rarity()
            match rarity:
                Enums.AugmentRarity.COMMON:
                    common_count += 1
                Enums.AugmentRarity.RARE:
                    rare_count += 1
                Enums.AugmentRarity.MYTHICAL:
                    mythical_count += 1

		 # Check approximate distribution (60/30/10)
        assert_true(common_count > 50, "Common should be ~60%")
        assert_true(rare_count > 20, "Rare should be ~30%")
        assert_true(mythical_count < 15, "Mythical should be ~10%")


	func test_get_current_phase() -> void:
       	# Test early phase
        AugmentManager._game_time = 0.0
        assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.EARLY, "Should be early phase at 0.0")

        # Test mid phase
        AugmentManager._game_time = 60.0
        assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.MID, "Should be mid phase at 60.0")

        # Test late phase
        AugmentManager._game_time = 200.0
        assert_eq(AugmentManager.get_current_phase(), Enums.GamePhase.LATE, "Should be late phase at 200.0")


	func test_pool_for_rarity_and_phase() -> void:
        var pool := AugmentManager._get_pool_for_rarity_and_phase(Enums.AugmentRarity.COMMON, Enums.GamePhase.EARLY)
        assert_not_null(pool, "Pool should not be null")

        # Check that all augments in pool have valid weights
        for aug in pool:
            assert_true(aug.early_weight > 0, "All augments in early pool should have early_weight > 0")


    func test_draft_returns_three_unique_cards() -> void:
        var choices := AugmentManager.get_random_choices()
        assert_eq(choices.size(), 3, "Should return exactly 3 cards")

        # Check all cards are unique
        var ids: Array[String] = []
        for choice in choices:
            var aug_data: AugmentData = choice as AugmentData
            assert_false(aug_data.augment_id in ids, "All cards should have unique IDs")
            ids.append(aug_data.augment_id)

        # Check all cards have same rarity
        var rarity := choices[0].rarity
        for choice in choices:
            var aug_data: AugmentData = choice as AugmentData
            assert_eq(aug_data.rarity, rarity, "All cards should have same rarity")


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


    func test_phase_weights_exclude_from_pool() -> void:
        # Create augment with zero early weight
        var augment := AugmentData.new()
        augment.augment_id = "no_early"
        augment.display_name = "No Early"
        augment.description = "Should not appear early"
        augment.icon_key = "score"
        augment.augment_key = "test"
        augment.early_weight = 0
        augment.mid_weight = 10
        augment.late_weight = 10

        # Test that it doesn't appear in early pool
        var early_pool := AugmentManager._get_pool_for_rarity_and_phase(Enums.AugmentRarity.COMMON, Enums.GamePhase.EARLY)
        for aug in early_pool:
            assert_not_equals(aug.augment_id, "no_early", "Augment with early_weight=0 should not be early pool")


    func test_icon_key_determines_icon_color() -> void:
        var ui := augment_choice_ui.new()
        var score_color := ui._get_icon_key_color("score")
        var burst_color := ui._get_icon_key_color("burst")
        var life_color := ui._get_icon_key_color("life")

        # Check that different icon keys give different colors
        assert_not_equals(score_color, burst_color, "Different icon keys should give different colors")
        assert_not_equals(score_color, life_color, "Different icon keys should give different colors")
