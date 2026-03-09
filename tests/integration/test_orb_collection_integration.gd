extends GutTest
## Integration tests for the complete orb collection flow.
## Verifies that Orb, ScoreManager, GameState, and ball group detection work together.

func before_all() -> void:
	OrbRegistry.initialize()


func before_each() -> void:
	ScoreManager.reset_score()
	GameState.is_paused = false
	GameState.current_mode = Enums.GameMode.PLAYING
	OrbRegistry.reset()
	OrbRegistry.initialize()


func after_each() -> void:
	GameState.is_paused = false
	GameState.current_mode = Enums.GameMode.MENU


#region Orb Collection Flow

func test_orb_collects_and_adds_score() -> void:
	var def := OrbRegistry.get_definition(&"blue")
	assert_ne(def, null, "Blue orb definition should exist")

	var orb := Orb.new()
	orb.definition = def
	orb._is_active = true  # Bypass spawn animation
	add_child_autofree(orb)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb.collect()
	await get_tree().process_frame

	assert_eq(ScoreManager.get_score(), initial_score + def.score_value, "Score should increase by orb value")


func test_paused_orb_not_collected() -> void:
	GameState.is_paused = true

	var def := OrbRegistry.get_definition(&"blue")
	var orb := Orb.new()
	orb.definition = def
	orb._is_active = true
	add_child_autofree(orb)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb.collect()

	assert_eq(ScoreManager.get_score(), initial_score, "Score should not change when paused")


func test_orb_not_collected_during_spawn() -> void:
	var def := OrbRegistry.get_definition(&"red")
	var orb := Orb.new()
	orb.definition = def
	orb._is_active = false  # In spawn animation
	add_child_autofree(orb)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb.collect()

	assert_eq(ScoreManager.get_score(), initial_score, "Score should not change during spawn animation")


#endregion

#region Ball Group Detection

func test_ball_group_detected() -> void:
	var def := OrbRegistry.get_definition(&"blue")
	var orb := Orb.new()
	orb.definition = def
	orb._is_active = true
	add_child_autofree(orb)
	await get_tree().process_frame

	# Simulate ball collision
	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	add_child_autofree(ball)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb._on_body_entered(ball)
	await get_tree().process_frame

	assert_eq(ScoreManager.get_score(), initial_score + def.score_value, "Ball collision should trigger collection")


func test_non_ball_group_ignored() -> void:
	var def := OrbRegistry.get_definition(&"blue")
	var orb := Orb.new()
	orb.definition = def
	orb._is_active = true
	add_child_autofree(orb)
	await get_tree().process_frame

	# Simulate non-ball collision
	var other := RigidBody2D.new()
	# Not in "ball" group
	add_child_autofree(other)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb._on_body_entered(other)
	await get_tree().process_frame

	assert_eq(ScoreManager.get_score(), initial_score, "Non-ball collision should not trigger collection")


#endregion

#region HalfSolidOrb Integration

func test_half_solid_first_hit_bounces() -> void:
	var def := OrbRegistry.get_definition(&"half_solid")
	var orb := HalfSolidOrb.new()
	orb.definition = def
	orb._is_active = true
	add_child_autofree(orb)
	await get_tree().process_frame

	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	ball.linear_velocity = Vector2(300, 600)
	add_child_autofree(ball)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb._on_body_entered(ball)

	assert_eq(ScoreManager.get_score(), initial_score, "First hit should not add score")
	assert_almost_eq(ball.linear_velocity.x, 100.0, 1.0, "Ball should bounce (velocity/3)")


func test_half_solid_second_hit_collects() -> void:
	var def := OrbRegistry.get_definition(&"half_solid")
	var orb := HalfSolidOrb.new()
	orb.definition = def
	orb._is_active = true
	orb._was_hit = true  # Already hit once
	add_child_autofree(orb)
	await get_tree().process_frame

	var ball := RigidBody2D.new()
	ball.add_to_group("ball")
	add_child_autofree(ball)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	orb._on_body_entered(ball)
	await get_tree().process_frame

	assert_eq(ScoreManager.get_score(), initial_score + def.score_value, "Second hit should add score")


#endregion

#region Score Manager Integration

func test_score_accumulates_with_multiple_orbs() -> void:
	var blue_def := OrbRegistry.get_definition(&"blue")
	var red_def := OrbRegistry.get_definition(&"red")

	# Collect blue orb
	var orb1 := Orb.new()
	orb1.definition = blue_def
	orb1._is_active = true
	add_child_autofree(orb1)
	await get_tree().process_frame
	orb1.collect()
	await get_tree().process_frame

	# Collect red orb
	var orb2 := Orb.new()
	orb2.definition = red_def
	orb2._is_active = true
	add_child_autofree(orb2)
	await get_tree().process_frame
	orb2.collect()
	await get_tree().process_frame

	var expected := blue_def.score_value + red_def.score_value
	assert_eq(ScoreManager.get_score(), expected, "Score should accumulate across orbs")


func test_high_score_updates() -> void:
	ScoreManager.set_high_score(0)

	var def := OrbRegistry.get_definition(&"half_solid")
	var orb := Orb.new()
	orb.definition = def
	orb._is_active = true
	add_child_autofree(orb)
	await get_tree().process_frame
	orb.collect()
	await get_tree().process_frame

	assert_eq(ScoreManager.get_high_score(), def.score_value, "High score should update when beaten")


#endregion
