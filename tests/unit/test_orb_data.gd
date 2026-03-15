extends GutTest
## Unit tests for OrbData resource class
## Tests creation, defaults, and property assignment


#region Default Values Tests

func test_orb_data_default_display_name() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.display_name, "Orb", "Default display_name should be 'Orb'")


func test_orb_data_default_base_score() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.base_score, 1, "Default base_score should be 1")


func test_orb_data_default_lifespan() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.lifespan, 30.0, "Default lifespan should be 30.0")


func test_orb_data_default_spawn_weight() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.spawn_weight, 1.0, "Default spawn_weight should be 1.0")


func test_orb_data_default_scale() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.scale, Vector2.ONE, "Default scale should be Vector2.ONE")


func test_orb_data_default_collision_radius() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.collision_radius, 32.0, "Default collision_radius should be 32.0")


func test_orb_data_default_is_half_solid() -> void:
	var orb_data := OrbData.new()
	assert_false(orb_data.is_half_solid, "Default is_half_solid should be false")


func test_orb_data_default_behaviors() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.behaviors.size(), 0, "Default behaviors array should be empty")


func test_orb_data_default_spawn_animation_duration() -> void:
	var orb_data := OrbData.new()
	assert_eq(orb_data.spawn_animation_duration, 0.5, "Default spawn_animation_duration should be 0.5")


#endregion

#region Property Assignment Tests

func test_orb_data_set_display_name() -> void:
	var orb_data := OrbData.new()
	orb_data.display_name = "Test Orb"
	assert_eq(orb_data.display_name, "Test Orb", "display_name should be settable")


func test_orb_data_set_base_score() -> void:
	var orb_data := OrbData.new()
	orb_data.base_score = 5
	assert_eq(orb_data.base_score, 5, "base_score should be settable")


func test_orb_data_set_lifespan() -> void:
	var orb_data := OrbData.new()
	orb_data.lifespan = 45.0
	assert_eq(orb_data.lifespan, 45.0, "lifespan should be settable")


func test_orb_data_set_spawn_weight() -> void:
	var orb_data := OrbData.new()
	orb_data.spawn_weight = 5.0
	assert_eq(orb_data.spawn_weight, 5.0, "spawn_weight should be settable")


func test_orb_data_set_is_half_solid() -> void:
	var orb_data := OrbData.new()
	orb_data.is_half_solid = true
	assert_true(orb_data.is_half_solid, "is_half_solid should be settable")


#endregion

#region Resource Tests

func test_orb_data_is_resource() -> void:
	var orb_data := OrbData.new()
	assert_true(orb_data is Resource, "OrbData should extend Resource")


func test_orb_data_can_be_duplicated() -> void:
	var original := OrbData.new()
	original.display_name = "Original"
	original.base_score = 10
	original.spawn_weight = 3.0

	var copy := original.duplicate()
	assert_eq(copy.display_name, "Original", "Duplicated OrbData should have same display_name")
	assert_eq(copy.base_score, 10, "Duplicated OrbData should have same base_score")
	assert_eq(copy.spawn_weight, 3.0, "Duplicated OrbData should have same spawn_weight")


#endregion
