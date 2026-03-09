class_name OrbRegistry
## Static registry for orb type definitions.
## Provides centralized registration, lookup, and weighted random selection.

static var _definitions: Dictionary = {}
static var _initialized: bool = false


## Clear all definitions and reset initialization state.
static func reset() -> void:
	_definitions.clear()
	_initialized = false


## Initialize with default orb definitions.
## Safe to call multiple times - only initializes once.
static func initialize() -> void:
	if _initialized:
		return
	_register_defaults()
	_initialized = true


## Register the default orb types (blue, red, half_solid).
static func _register_defaults() -> void:
	var blue := OrbDefinition.new()
	blue.type_name = &"blue"
	blue.display_name = "Blue Orb"
	blue.score_value = 2
	blue.lifespan_seconds = 30.0
	blue.spawn_weight = 1.0
	blue.has_physics_body = false
	register(blue)

	var red := OrbDefinition.new()
	red.type_name = &"red"
	red.display_name = "Red Orb"
	red.score_value = 3
	red.lifespan_seconds = 30.0
	red.spawn_weight = 1.0
	red.has_physics_body = false
	register(red)

	var half := OrbDefinition.new()
	half.type_name = &"half_solid"
	half.display_name = "Half Solid Orb"
	half.score_value = 8
	half.lifespan_seconds = 18.0
	half.spawn_weight = 0.5
	half.has_physics_body = true
	register(half)


## Register an orb definition.
## Logs error if definition is null or has no type_name.
static func register(def: OrbDefinition) -> void:
	if def == null or def.type_name == null or def.type_name == &"":
		push_error("OrbRegistry: Cannot register null or typeless definition")
		return
	_definitions[def.type_name] = def


## Get a definition by type name.
## Returns null and logs warning if type is not found.
static func get_definition(type_name: StringName) -> OrbDefinition:
	if not _definitions.has(type_name):
		push_warning("OrbRegistry: Unknown orb type: " + str(type_name))
		return null
	return _definitions[type_name]


## Get all registered definitions.
static func get_all_definitions() -> Array:
	return _definitions.values()


## Get a random definition weighted by spawn_weight.
## Auto-initializes if registry is empty.
static func get_weighted_random() -> OrbDefinition:
	if _definitions.is_empty():
		initialize()

	if _definitions.is_empty():
		return null

	var total_weight := 0.0
	for def in _definitions.values():
		total_weight += def.spawn_weight

	if total_weight <= 0.0:
		return _definitions.values()[0] if _definitions.size() > 0 else null

	var roll := randf() * total_weight
	var accumulated := 0.0

	for def in _definitions.values():
		accumulated += def.spawn_weight
		if roll <= accumulated:
			return def

	return _definitions.values()[0] if _definitions.size() > 0 else null
