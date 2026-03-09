extends GutTest
## Unit tests for HalfSolidOrb subclass

var _orb: HalfSolidOrb
var _def: OrbDefinition

func before_each() -> void:
	ScoreManager.reset_score()
	GameState.is_paused = false
	_def = OrbDefinition.new()
	_def.type_name = &"half_solid"
	_def.score_value = 8
	_def.lifespan_seconds = 18.0


func after_each() -> void:
	GameState.is_paused = false


#region Group tests

func test_half_solid_orb_in_group() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_true(_orb.is_in_group("half_solid"), "HalfSolidOrb should be in 'half_solid' group")


func test_half_solid_orb_in_orbs_group() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_true(_orb.is_in_group("orbs"), "HalfSolidOrb should also be in 'orbs' group")


#endregion

#region First hit tests

func test_first_hit_sets_was_hit() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	_orb._is_active = true
	add_child_autofree(_orb)
	await get_tree().process_frame

	assert_false(_orb._was_hit, "Should start not hit")

	# Simulate ball collision
	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	ball.linear_velocity = Vector2(300, 600)
	add_child_autofree(ball)
	await get_tree().process_frame

	_orb._on_body_entered(ball)

	assert_true(_orb._was_hit, "Should be hit after first collision")


func test_first_hit_bounces_ball() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	_orb._is_active = true
	add_child_autofree(_orb)
	await get_tree().process_frame

	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	ball.linear_velocity = Vector2(300, 600)
	add_child_autofree(ball)
	await get_tree().process_frame

	_orb._on_body_entered(ball)

	assert_almost_eq(ball.linear_velocity.x, 100.0, 1.0, "Ball X should be reduced to 1/3")
	assert_almost_eq(ball.linear_velocity.y, 200.0, 1.0, "Ball Y should be reduced to 1/3")


#endregion

#region Second hit tests

func test_second_hit_collects() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	_orb._is_active = true
	_orb._was_hit = true  # Already hit once
	add_child_autofree(_orb)
	await get_tree().process_frame

	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	add_child_autofree(ball)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	_orb._on_body_entered(ball)

	assert_eq(ScoreManager.get_score(), initial_score + 8, "Second hit should collect and add score")


func test_second_hit_doesnt_bounce() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	_orb._is_active = true
	_orb._was_hit = true  # Already hit once
	add_child_autofree(_orb)
	await get_tree().process_frame

	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	ball.linear_velocity = Vector2(300, 600)
	add_child_autofree(ball)
	await get_tree().process_frame

	_orb._on_body_entered(ball)

	# Ball velocity should NOT be modified on second hit
	assert_almost_eq(ball.linear_velocity.x, 300.0, 1.0, "Ball X should NOT be modified on second hit")
	assert_almost_eq(ball.linear_velocity.y, 600.0, 1.0, "Ball Y should NOT be modified on second hit")


#endregion

#region Non-ball tests

func test_non_ball_doesnt_trigger() -> void:
	_orb = HalfSolidOrb.new()
	_orb.definition = _def
	_orb._is_active = true
	add_child_autofree(_orb)
	await get_tree().process_frame

	var other := RigidBody2D.new()
	# Not in "ball" group
	other.linear_velocity = Vector2(300, 600)
	add_child_autofree(other)
	await get_tree().process_frame

	_orb._on_body_entered(other)

	assert_false(_orb._was_hit, "Non-ball should not trigger hit")
	assert_almost_eq(other.linear_velocity.x, 300.0, 1.0, "Non-ball velocity should not change")


#endregion

#region Inheritance tests

func test_inherits_score_from_definition() -> void:
	_orb = HalfSolidOrb.new()
	_def.score_value = 15
	_orb.definition = _def
	_orb._is_active = true
	_orb._was_hit = true
	add_child_autofree(_orb)
	await get_tree().process_frame

	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	add_child_autofree(ball)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	_orb._on_body_entered(ball)

	assert_eq(ScoreManager.get_score(), initial_score + 15, "Should use definition score value")


#endregion
