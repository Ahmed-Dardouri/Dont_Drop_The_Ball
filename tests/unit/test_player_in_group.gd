extends GutTest
## Unit tests for player group assignment
## Tests that physics_player is properly added to "player" group


func test_player_in_player_group() -> void:
	# Load and instance the player scene
	var player_scene = load("res://scenes/physics_player.tscn")
	var player = player_scene.instantiate()
	add_child_autofree(player)

	# Wait for _ready to be called
	await get_tree().process_frame

	# Check that player is in the "player" group
	assert_true(player.is_in_group("player"), "Player should be in 'player' group")


func test_player_group_after_ready() -> void:
	# Test using script directly
	var player_script = load("res://scripts/physics_player.gd")
	var player = RigidBody2D.new()
	player.set_script(player_script)

	add_child_autofree(player)

	# Wait for _ready to be called
	await get_tree().process_frame

	assert_true(player.is_in_group("player"), "Player should be in 'player' group after _ready")
