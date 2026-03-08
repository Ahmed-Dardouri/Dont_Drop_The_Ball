extends GutTest
## Unit tests for orb scoring logic
## Tests the relationship between orb types and their score values

# Test that orb types map to correct score values based on Constants
# This tests the logic pattern used in orb_mngr.gd


func _get_orb_score(orb_type: Enums.OrbType) -> int:
	# Mirror the logic from orb_mngr.gd
	match orb_type:
		Enums.OrbType.BLUE:
			return Constants.orb_score_blue
		Enums.OrbType.RED:
			return Constants.orb_score_red
		Enums.OrbType.HALF_SOLID:
			return Constants.orb_score_half_solid
		_:
			return 0


func test_blue_orb_score() -> void:
	var score := _get_orb_score(Enums.OrbType.BLUE)
	assert_eq(score, Constants.orb_score_blue, "Blue orb should have blue score")
	assert_eq(score, 2, "Blue orb score should be 2 (from Constants)")


func test_red_orb_score() -> void:
	var score := _get_orb_score(Enums.OrbType.RED)
	assert_eq(score, Constants.orb_score_red, "Red orb should have red score")
	assert_eq(score, 3, "Red orb score should be 3 (from Constants)")


func test_half_solid_orb_score() -> void:
	var score := _get_orb_score(Enums.OrbType.HALF_SOLID)
	assert_eq(score, Constants.orb_score_half_solid, "Half-solid orb should have half-solid score")
	assert_eq(score, 8, "Half-solid orb score should be 8 (from Constants)")


func test_unknown_orb_type_returns_zero() -> void:
	# Test with a value outside the enum
	var score := _get_orb_score(-1)
	assert_eq(score, 0, "Unknown orb type should return 0 score")


func test_score_ordering() -> void:
	# Half-solid orbs are worth the most (they're rarer/harder to get)
	assert_gt(Constants.orb_score_half_solid, Constants.orb_score_red,
		"Half-solid should be worth more than red")
	assert_gt(Constants.orb_score_red, Constants.orb_score_blue,
		"Red should be worth more than blue")


func test_all_orb_scores_positive() -> void:
	assert_gt(Constants.orb_score_blue, 0, "Blue orb score should be positive")
	assert_gt(Constants.orb_score_red, 0, "Red orb score should be positive")
	assert_gt(Constants.orb_score_half_solid, 0, "Half-solid orb score should be positive")


func test_orb_lifespans_configured() -> void:
	# Verify orb lifespans are properly configured
	assert_gt(Constants.orb_lifespan_blue, 0, "Blue orb lifespan should be positive")
	assert_gt(Constants.orb_lifespan_red, 0, "Red orb lifespan should be positive")
	assert_gt(Constants.orb_lifespan_half_solid, 0, "Half-solid orb lifespan should be positive")
