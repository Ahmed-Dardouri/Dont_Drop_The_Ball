extends GutTest
## Unit tests for OrbDefinition resource class


#region Default Values tests

func test_default_score_value() -> void:
	var def := OrbDefinition.new()
	assert_eq(def.score_value, 1, "Default score_value should be 1")


func test_default_lifespan() -> void:
	var def := OrbDefinition.new()
	assert_almost_eq(def.lifespan_seconds, 30.0, 0.1, "Default lifespan should be 30 seconds")


func test_default_spawn_weight() -> void:
	var def := OrbDefinition.new()
	assert_almost_eq(def.spawn_weight, 1.0, 0.1, "Default spawn_weight should be 1.0")


func test_default_has_physics_body() -> void:
	var def := OrbDefinition.new()
	assert_false(def.has_physics_body, "Default has_physics_body should be false")


func test_default_type_name() -> void:
	var def := OrbDefinition.new()
	# StringName default is empty
	assert_eq(def.type_name, &"", "Default type_name should be empty StringName")


func test_default_display_name() -> void:
	var def := OrbDefinition.new()
	assert_eq(def.display_name, "", "Default display_name should be empty string")


#endregion

#region Custom Values tests

func test_custom_type_name() -> void:
	var def := OrbDefinition.new()
	def.type_name = &"blue"
	assert_eq(def.type_name, &"blue", "Should accept custom type_name")


func test_custom_display_name() -> void:
	var def := OrbDefinition.new()
	def.display_name = "Blue Orb"
	assert_eq(def.display_name, "Blue Orb", "Should accept custom display_name")


func test_custom_score_value() -> void:
	var def := OrbDefinition.new()
	def.score_value = 10
	assert_eq(def.score_value, 10, "Should accept custom score_value")


func test_custom_lifespan() -> void:
	var def := OrbDefinition.new()
	def.lifespan_seconds = 15.0
	assert_almost_eq(def.lifespan_seconds, 15.0, 0.1, "Should accept custom lifespan")


func test_custom_spawn_weight() -> void:
	var def := OrbDefinition.new()
	def.spawn_weight = 0.5
	assert_almost_eq(def.spawn_weight, 0.5, 0.1, "Should accept custom spawn_weight")


func test_custom_has_physics_body() -> void:
	var def := OrbDefinition.new()
	def.has_physics_body = true
	assert_true(def.has_physics_body, "Should accept custom has_physics_body")


#endregion

#region StringName Type tests

func test_type_name_is_stringname() -> void:
	var def := OrbDefinition.new()
	def.type_name = &"test"
	assert_eq(typeof(def.type_name), TYPE_STRING_NAME, "type_name should be StringName type")


func test_type_name_from_string() -> void:
	var def := OrbDefinition.new()
	def.type_name = StringName("from_string")
	assert_eq(def.type_name, &"from_string", "Should accept StringName from string")


#endregion
