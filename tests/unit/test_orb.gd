extends GutTest
## Unit tests for unified Orb class

var _orb: Orb
var _def: OrbDefinition

func before_each() -> void:
	ScoreManager.reset_score()
	GameState.is_paused = false
	_def = OrbDefinition.new()
	_def.type_name = &"test"
	_def.score_value = 10
	_def.lifespan_seconds = 30.0


func after_each() -> void:
	GameState.is_paused = false


#region Definition tests

func test_orb_requires_definition() -> void:
	_orb = Orb.new()
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_true(_orb.is_inside_tree(), "Orb should handle missing definition")


func test_orb_with_definition() -> void:
	_orb = Orb.new()
	_orb.definition = _def
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_true(_orb.is_inside_tree(), "Orb should initialize with definition")


#endregion

#region Spawn Animation tests

func test_spawn_animation_starts_transparent() -> void:
	_orb = Orb.new()
	_orb.definition = _def
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_almost_eq(_orb.modulate.a, 0.0, 0.1, "Orb should start transparent")


func test_spawn_animation_not_active_initially() -> void:
	_orb = Orb.new()
	_orb.definition = _def
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_false(_orb._is_active, "Orb should not be active during spawn")


#endregion

#region Collection tests

func test_collect_adds_score() -> void:
	_orb = Orb.new()
	_orb.definition = _def
	_orb._is_active = true  # Bypass spawn animation
	add_child_autofree(_orb)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	_orb.collect()
	assert_eq(ScoreManager.get_score(), initial_score + 10, "Collect should add score")


func test_collect_blocked_when_paused() -> void:
	GameState.is_paused = true

	_orb = Orb.new()
	_orb.definition = _def
	_orb._is_active = true
	add_child_autofree(_orb)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	_orb.collect()
	assert_eq(ScoreManager.get_score(), initial_score, "Paused orb should not collect")


func test_collect_blocked_during_spawn() -> void:
	_orb = Orb.new()
	_orb.definition = _def
	_orb._is_active = false  # In spawn animation
	add_child_autofree(_orb)
	await get_tree().process_frame

	var initial_score := ScoreManager.get_score()
	_orb.collect()
	assert_eq(ScoreManager.get_score(), initial_score, "Orb in spawn should not collect")


func test_collect_emits_signal() -> void:
	_orb = Orb.new()
	_orb.definition = _def

	add_child_autofree(_orb)
	await get_tree().process_frame

	# Set active after in tree
	_orb._is_active = true

	watch_signals(_orb)
	_orb.collect()
	assert_signal_emitted(_orb, "collected", "Collect should emit collected signal")


#endregion

#region Group tests

func test_orb_in_orbs_group() -> void:
	_orb = Orb.new()
	_orb.definition = _def
	add_child_autofree(_orb)
	await get_tree().process_frame
	assert_true(_orb.is_in_group("orbs"), "Orb should be in 'orbs' group")


#endregion
