class_name OrbAdapter
## Utility class that bridges OrbData resources to the spawn system.
## Creates configured GenericOrb instances from OrbData definitions.


## Creates a configured GenericOrb from OrbData.
## Returns null if either argument is null.
static func create_orb_from_data(generic_orb_scene: PackedScene, orb_data: OrbData) -> GenericOrb:
	# Null safety checks
	if generic_orb_scene == null or orb_data == null:
		return null

	# Instantiate the GenericOrb scene
	var orb: GenericOrb = generic_orb_scene.instantiate()

	# Configure with OrbData
	orb.set_orb_data(orb_data)

	# Add to orbs group for chain collection
	orb.add_to_group("orbs")

	return orb
