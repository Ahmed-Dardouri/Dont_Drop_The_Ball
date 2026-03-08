extends GutTest
## Unit tests for OrbProps resource class
## Tests creation and property access for orb properties


func test_orb_props_default_type() -> void:
	var props := OrbProps.new()
	assert_eq(props.Type, Enums.OrbType.BLUE, "Default orb type should be BLUE")


func test_orb_props_set_type() -> void:
	var props := OrbProps.new()
	props.Type = Enums.OrbType.RED
	assert_eq(props.Type, Enums.OrbType.RED, "Type should be settable to RED")


func test_orb_props_all_types() -> void:
	var types := [Enums.OrbType.BLUE, Enums.OrbType.RED, Enums.OrbType.HALF_SOLID]

	for type in types:
		var props := OrbProps.new()
		props.Type = type
		assert_eq(props.Type, type, "Type should be settable to %s" % type)


func test_orb_props_is_resource() -> void:
	var props := OrbProps.new()
	assert_true(props is Resource, "OrbProps should extend Resource")


func test_orb_props_can_be_copied() -> void:
	var original := OrbProps.new()
	original.Type = Enums.OrbType.HALF_SOLID

	# Resources can be duplicated
	var copy := original.duplicate()
	assert_eq(copy.Type, Enums.OrbType.HALF_SOLID, "Duplicated props should have same type")
