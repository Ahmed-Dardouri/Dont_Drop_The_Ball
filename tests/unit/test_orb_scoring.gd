extends GutTest
## Unit tests for orb scoring via OrbData resources
## Tests that migrated orb resources have correct score values


func test_blue_orb_score() -> void:
	var resource: Resource = load("res://resources/orbs/blue_orb.tres")
	var blue_orb: OrbData = resource as OrbData
	assert_eq(blue_orb.base_score, 2, "Blue orb should have base_score of 2")


func test_red_orb_score() -> void:
	var resource: Resource = load("res://resources/orbs/red_orb.tres")
	var red_orb: OrbData = resource as OrbData
	assert_eq(red_orb.base_score, 3, "Red orb should have base_score of 3")


func test_half_solid_orb_score() -> void:
	var resource: Resource = load("res://resources/orbs/half_solid_orb.tres")
	var half_orb: OrbData = resource as OrbData
	assert_eq(half_orb.base_score, 8, "Half solid orb should have base_score of 8")


func test_score_ordering() -> void:
	var blue: OrbData = load("res://resources/orbs/blue_orb.tres") as OrbData
	var red: OrbData = load("res://resources/orbs/red_orb.tres") as OrbData
	var half: OrbData = load("res://resources/orbs/half_solid_orb.tres") as OrbData

	assert_gt(half.base_score, red.base_score, "Half-solid should be worth more than red")
	assert_gt(red.base_score, blue.base_score, "Red should be worth more than blue")


func test_all_orb_scores_positive() -> void:
	var orbs: Array[OrbData] = [
		load("res://resources/orbs/blue_orb.tres") as OrbData,
		load("res://resources/orbs/red_orb.tres") as OrbData,
		load("res://resources/orbs/half_solid_orb.tres") as OrbData,
	]

	for orb: OrbData in orbs:
		assert_gt(orb.base_score, 0, "%s should have positive score" % orb.display_name)


func test_all_orbs_have_score_behavior() -> void:
	var orbs: Array[OrbData] = [
		load("res://resources/orbs/blue_orb.tres") as OrbData,
		load("res://resources/orbs/red_orb.tres") as OrbData,
		load("res://resources/orbs/half_solid_orb.tres") as OrbData,
	]

	for orb: OrbData in orbs:
		var has_score_behavior := false
		for behavior: OrbBehavior in orb.behaviors:
			if behavior is ScoreBehavior:
				has_score_behavior = true
				break
		assert_true(has_score_behavior, "%s should have a ScoreBehavior" % orb.display_name)


func test_orb_lifespans() -> void:
	var blue: OrbData = load("res://resources/orbs/blue_orb.tres") as OrbData
	var red: OrbData = load("res://resources/orbs/red_orb.tres") as OrbData
	var half: OrbData = load("res://resources/orbs/half_solid_orb.tres") as OrbData

	assert_eq(blue.lifespan, 30.0, "Blue orb should have 30s lifespan")
	assert_eq(red.lifespan, 30.0, "Red orb should have 30s lifespan")
	assert_eq(half.lifespan, 18.0, "Half solid orb should have 18s lifespan")


func test_half_solid_flag() -> void:
	var half: OrbData = load("res://resources/orbs/half_solid_orb.tres") as OrbData
	assert_true(half.is_half_solid, "Half solid orb should have is_half_solid=true")

	var blue: OrbData = load("res://resources/orbs/blue_orb.tres") as OrbData
	assert_false(blue.is_half_solid, "Blue orb should have is_half_solid=false")
