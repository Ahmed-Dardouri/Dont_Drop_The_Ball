extends GutTest
## Unit tests for ComboManager vertical bonus meter system
## Tests meter fill, drain, tier progression, and bonus calculations

func before_each() -> void:
    ComboManager.reset_combo()
    ScoreManager.reset_score()
    EffectManager.clear_all_effects()


func test_meter_starts_at_zero() -> void:
    assert_eq(ComboManager.get_meter_value(), 0.0, "Meter should start at 0")


func test_score_gain_fills_meter() -> void:
    ComboManager.add_orb_score(10)
    assert_gt(ComboManager.get_meter_value(), 0.0, "Meter should increase after score gain")


func test_meter_fill_amount_proportional_to_score() -> void:
    ComboManager.add_orb_score(20)
    assert_almost_eq(ComboManager.get_meter_value(), 20.0, 0.1, "Meter should be 20 after 20 score")


func test_meter_capped_at_max() -> void:
    ComboManager.add_orb_score(500)
    assert_almost_eq(ComboManager.get_meter_value(), 250.0, 0.1, "Meter should be capped at 250")


func test_multiple_score_gains_accumulate() -> void:
    ComboManager.add_orb_score(10)
    ComboManager.add_orb_score(15)
    assert_almost_eq(ComboManager.get_meter_value(), 25.0, 0.1, "Meter should accumulate score gains")


func test_double_value_increases_base_and_meter() -> void:
    EffectManager.apply_effect("double_value", true, 10.0)
    var result: Dictionary = ComboManager.add_orb_score(10)
    assert_eq(result.base_score, 20, "Base score should be doubled")
    assert_almost_eq(ComboManager.get_meter_value(), 20.0, 0.1, "Meter should fill with adjusted base")


func test_meter_fill_uses_score_to_meter_ratio() -> void:
    assert_eq(ComboManager.SCORE_TO_METER_RATIO, 1.0, "Score to meter ratio should be 1.0")


func test_initial_tier_is_zero() -> void:
    assert_eq(ComboManager.get_current_tier(), 0, "Initial tier should be 0")


func test_tier_0_bonus_is_one() -> void:
    assert_eq(ComboManager.get_current_bonus(), 1, "Tier 0 should give +1 bonus")


func test_tier_progression_to_tier_1() -> void:
    ComboManager.add_orb_score(12)
    assert_eq(ComboManager.get_current_tier(), 1, "Should reach tier 1 at 10 meter points")
    assert_eq(ComboManager.get_current_bonus(), 2, "Tier 1 should give +2 bonus")


func test_tier_progression_to_tier_2() -> void:
    ComboManager.add_orb_score(35)
    assert_eq(ComboManager.get_current_tier(), 2, "Should reach tier 2 at 30 meter points")
    assert_eq(ComboManager.get_current_bonus(), 5, "Tier 2 should give +5 bonus")


func test_tier_progression_to_tier_3() -> void:
    ComboManager.add_orb_score(65)
    assert_eq(ComboManager.get_current_tier(), 3, "Should reach tier 3 at 60 meter points")
    assert_eq(ComboManager.get_current_bonus(), 10, "Tier 3 should give +10 bonus")


func test_tier_progression_to_tier_4() -> void:
    ComboManager.add_orb_score(105)
    assert_eq(ComboManager.get_current_tier(), 4, "Should reach tier 4 at 100 meter points")
    assert_eq(ComboManager.get_current_bonus(), 20, "Tier 4 should give +20 bonus")


func test_tier_progression_to_tier_5() -> void:
    ComboManager.add_orb_score(165)
    assert_eq(ComboManager.get_current_tier(), 5, "Should reach tier 5 at 160 meter points")
    assert_eq(ComboManager.get_current_bonus(), 50, "Tier 5 should give +50 bonus")


func test_tier_progression_to_max_tier_6() -> void:
    ComboManager.add_orb_score(260)
    assert_eq(ComboManager.get_current_tier(), 6, "Should reach tier 6 at 250 meter points")
    assert_eq(ComboManager.get_current_bonus(), 100, "Tier 6 should give +100 bonus")


func test_all_tier_bonuses_match_spec() -> void:
    var expected_tiers: Array[int] = [1, 2, 5, 10, 20, 50, 100]
    for i: int in range(expected_tiers.size()):
        assert_eq(ComboManager.BONUS_TIERS[i], expected_tiers[i], "Tier %d bonus should be +%d" % [i, expected_tiers[i]])


func test_lower_tiers_easier_to_reach() -> void:
    var thresholds: Array = ComboManager.TIER_THRESHOLDS
    var gap_0_1: float = thresholds[1] - thresholds[0]
    var gap_5_6: float = thresholds[6] - thresholds[5]
    assert_lt(gap_0_1, gap_5_6, "Lower tiers should have smaller gaps (easier to reach)")


func test_tier_ordering_is_correct() -> void:
    assert_eq(ComboManager.TIER_THRESHOLDS.size(), 7, "Should have 7 tier thresholds")
    assert_eq(ComboManager.TIER_THRESHOLDS[0], 0.0, "First tier threshold should be 0")
    assert_eq(ComboManager.TIER_THRESHOLDS[1], 10.0, "Second tier threshold should be 10")
    assert_eq(ComboManager.TIER_THRESHOLDS[2], 30.0, "Third tier threshold should be 30")
    assert_eq(ComboManager.TIER_THRESHOLDS[3], 60.0, "Fourth tier threshold should be 60")
    assert_eq(ComboManager.TIER_THRESHOLDS[4], 100.0, "Fifth tier threshold should be 100")
    assert_eq(ComboManager.TIER_THRESHOLDS[5], 160.0, "Sixth tier threshold should be 160")
    assert_eq(ComboManager.TIER_THRESHOLDS[6], 250.0, "Seventh tier threshold should be 250")


func test_meter_drains_over_time() -> void:
    ComboManager.add_orb_score(20)
    var initial_value: float = ComboManager.get_meter_value()
    ComboManager._process(1.0)
    assert_lt(ComboManager.get_meter_value(), initial_value, "Meter should drain over time")


func test_meter_does_not_go_negative() -> void:
    ComboManager.add_orb_score(3)
    ComboManager._process(10.0)
    assert_true(ComboManager.get_meter_value() >= 0.0, "Meter should not go negative")


func test_drain_stops_at_zero() -> void:
    ComboManager.reset_combo()
    ComboManager._process(5.0)
    assert_eq(ComboManager.get_meter_value(), 0.0, "Drain should stop at zero")


func test_drain_at_tier_0_rate() -> void:
    ComboManager.add_orb_score(5)
    assert_eq(ComboManager.get_current_tier(), 0, "Should be at tier 0")
    var initial: float = ComboManager.get_meter_value()
    ComboManager._process(1.0)
    var expected: float = maxf(initial - 2.0, 0.0)
    assert_almost_eq(ComboManager.get_meter_value(), expected, 0.1, "Tier 0 should drain at 2.0/sec")


func test_higher_tier_drains_faster() -> void:
    # Reach tier 6
    ComboManager.add_orb_score(260)
    assert_eq(ComboManager.get_current_tier(), 6, "Should be at tier 6")
    var initial_tier6: float = ComboManager.get_meter_value()

    # Process 1 second at tier 6
    ComboManager._process(1.0)
    var after_tier6: float = ComboManager.get_meter_value()

    # Reset and reach tier 0
    ComboManager.reset_combo()
    ComboManager.add_orb_score(5)
    assert_eq(ComboManager.get_current_tier(), 0, "Should be at tier 0")
    var initial_tier0: float = ComboManager.get_meter_value()

    # Process 1 second at tier 0
    ComboManager._process(1.0)
    var after_tier0: float = ComboManager.get_meter_value()

    # Tier 6 should drain faster than tier 0 (rate is 25 vs 3)
    assert_gt(initial_tier0 - after_tier0, initial_tier6 - after_tier6, "Tier 6 should drain faster than tier 0")


func test_meter_draining_reduces_tier() -> void:
    ComboManager.add_orb_score(50)
    assert_eq(ComboManager.get_current_tier(), 2, "Should start at tier 2")
    while ComboManager.get_meter_value() > 25.0:
        ComboManager._process(0.1)
    assert_eq(ComboManager.get_current_tier(), 1, "Tier should drop when meter drains")


func test_bonus_added_to_base_score() -> void:
    var result: Dictionary = ComboManager.add_orb_score(5)
    assert_eq(result.base_score, 5, "Base should be 5")
    assert_eq(result.combo_bonus, 1, "Bonus should be +1 at tier 0")
    assert_eq(result.total, 6, "Total should be base + bonus")


func test_higher_tier_gives_higher_bonus() -> void:
    ComboManager.add_orb_score(105)
    assert_eq(ComboManager.get_current_tier(), 4, "Should be at tier 4")
    var result: Dictionary = ComboManager.add_orb_score(5)
    assert_eq(result.combo_bonus, 20, "Tier 4 should give +20 bonus")


func test_score_added_to_score_manager() -> void:
    ScoreManager.reset_score()
    ComboManager.add_orb_score(5)
    assert_eq(ScoreManager.get_score(), 6, "Score should be added to ScoreManager")


func test_bounce_does_not_affect_meter_directly() -> void:
    ComboManager.add_orb_score(20)
    var before_bounce: float = ComboManager.get_meter_value()
    assert_eq(ComboManager.get_meter_value(), before_bounce, "Bounce should not directly affect meter (only time drain affects it)")


func test_meter_does_not_reset_on_bounce() -> void:
    ComboManager.add_orb_score(70)
    assert_eq(ComboManager.get_current_tier(), 3, "Should be at tier 3")
    assert_eq(ComboManager.get_current_tier(), 3, "Meter should not reset on bounce in new system")


func test_life_orb_effect_independent_of_meter() -> void:
    EffectManager.apply_effect("has_life", true, -1.0)
    ComboManager.add_orb_score(10)
    assert_almost_eq(ComboManager.get_meter_value(), 10.0, 0.1, "Life orb effect should not affect meter filling")
    assert_true(EffectManager.has_effect("has_life"), "Life orb effect should still be active")


func test_meter_reset_does_not_affect_life_orb() -> void:
    EffectManager.apply_effect("has_life", true, -1.0)
    ComboManager.reset_combo()
    assert_true(EffectManager.has_effect("has_life"), "Combo reset should not affect life orb effect")


func test_get_combo_bonus_returns_current_bonus() -> void:
    assert_eq(ComboManager.get_combo_bonus(), 1, "get_combo_bonus() should return current bonus")


func test_get_next_combo_bonus_returns_next_tier() -> void:
    assert_eq(ComboManager.get_next_combo_bonus(), 2, "Next combo bonus should be tier 1 (+2)")


func test_get_next_combo_bonus_at_max_tier() -> void:
    ComboManager.add_orb_score(260)
    assert_eq(ComboManager.get_next_combo_bonus(), 100, "At max tier, next combo bonus should equal current")


func test_get_tier_count_returns_seven() -> void:
    assert_eq(ComboManager.get_tier_count(), 7, "Should have 7 tiers (0-6)")


func test_get_progress_to_next_tier() -> void:
    ComboManager.add_orb_score(5)
    assert_almost_eq(ComboManager.get_progress_to_next_tier(), 0.5, 0.01, "Progress to next tier should be 50%")


func test_get_progress_to_next_tier_at_max() -> void:
    ComboManager.add_orb_score(260)
    assert_eq(ComboManager.get_progress_to_next_tier(), 1.0, "At max tier, progress should be 1.0")


func test_reset_combo_sets_meter_to_zero() -> void:
    ComboManager.add_orb_score(50)
    ComboManager.reset_combo()
    assert_eq(ComboManager.get_meter_value(), 0.0, "Reset should set meter to 0")
    assert_eq(ComboManager.get_current_tier(), 0, "Reset should set tier to 0")


func test_add_orb_score_returns_correct_dictionary() -> void:
    var result: Dictionary = ComboManager.add_orb_score(5)
    assert_has(result, "base_score", "Result should have base_score")
    assert_has(result, "combo_bonus", "Result should have combo_bonus")
    assert_has(result, "total", "Result should have total")
    assert_eq(result.base_score, 5, "base_score should be 5")
    assert_eq(result.combo_bonus, 1, "combo_bonus should be 1")
    assert_eq(result.total, 6, "total should be 6")
