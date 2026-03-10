extends GutTest

# Test suite for ScoreBehavior
# Tests base score, double_value effect, score_multiplier effect, and combined multipliers

var _behavior: ScoreBehavior


func before_each() -> void:
	_behavior = ScoreBehavior.new()
	EffectManager.clear_all_effects()
	ScoreManager.reset_score()


#region Base Score Tests

func test_base_score_awarded() -> void:
	# Given: ScoreBehavior with base_score=5
	_behavior.base_score = 5
	var context: Dictionary = {"orb": null, "orb_data": null, "collector": null}

	# When: execute() is called
	_behavior.execute(context)

	# Then: ScoreManager.add_score(5) was called
	assert_eq(ScoreManager.get_score(), 5, "Base score should be awarded")


func test_default_base_score_is_one() -> void:
	# Given: Fresh ScoreBehavior
	var fresh_behavior: ScoreBehavior = ScoreBehavior.new()

	# Then: default base_score is 1
	assert_eq(fresh_behavior.base_score, 1, "Default base_score should be 1")


#endregion

#region Double Value Tests

func test_double_value_applied() -> void:
	# Given: double_value effect is active and base_score=3
	EffectManager.apply_effect("double_value", true, -1.0)
	_behavior.base_score = 3
	var context: Dictionary = {"orb": null, "orb_data": null, "collector": null}

	# When: execute() is called
	_behavior.execute(context)

	# Then: score is doubled to 6
	assert_eq(ScoreManager.get_score(), 6, "Score should be doubled when double_value is active")


#endregion

#region Score Multiplier Tests

func test_score_multiplier_applied() -> void:
	# Given: score_multiplier=2x effect is active and base_score=5
	EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
	_behavior.base_score = 5
	var context: Dictionary = {"orb": null, "orb_data": null, "collector": null}

	# When: execute() is called
	_behavior.execute(context)

	# Then: score is 10
	assert_eq(ScoreManager.get_score(), 10, "Score should be multiplied by score_multiplier")


#endregion

#region Combined Multiplier Tests

func test_combined_multipliers() -> void:
	# Given: both double_value and score_multiplier=2x are active
	EffectManager.apply_effect("double_value", true, -1.0)
	EffectManager.apply_effect("score_multiplier", 2.0, 10.0)
	_behavior.base_score = 5
	var context: Dictionary = {"orb": null, "orb_data": null, "collector": null}

	# When: execute() is called
	_behavior.execute(context)

	# Then: score is base * 2 * 2 = 20
	assert_eq(ScoreManager.get_score(), 20, "Score should be doubled then multiplied")


func test_no_effects_base_score_only() -> void:
	# Given: no effects active and base_score=7
	_behavior.base_score = 7
	var context: Dictionary = {"orb": null, "orb_data": null, "collector": null}

	# When: execute() is called
	_behavior.execute(context)

	# Then: score is just base_score
	assert_eq(ScoreManager.get_score(), 7, "Score should be base_score when no effects active")


#endregion
