extends GutTest
## Unit tests for ground group assignment
## Tests that ground_static is properly added to "ground" group


func test_ground_adds_static_to_group() -> void:
	# Load and instance the ground scene
	var ground_scene = load("res://scenes/ground.tscn")
	var ground = ground_scene.instantiate()
	add_child_autofree(ground)

	# Wait for _ready to be called
	await get_tree().process_frame

	# Check that ground_static is in the "ground" group
	var ground_static = ground.get_node_or_null("ground_static")
	assert_not_null(ground_static, "ground_static should exist")
	assert_true(ground_static.is_in_group("ground"), "ground_static should be in 'ground' group")


func test_ground_group_exists_after_ready() -> void:
	var ground_script = load("res://scripts/ground.gd")
	var ground = Node2D.new()
	ground.set_script(ground_script)

	# Create a mock ground_static child
	var ground_static = StaticBody2D.new()
	ground_static.name = "ground_static"
	ground.add_child(ground_static)

	add_child_autofree(ground)

	# Wait for _ready to be called
	await get_tree().process_frame

	assert_true(ground_static.is_in_group("ground"), "ground_static should be in 'ground' group after _ready")
