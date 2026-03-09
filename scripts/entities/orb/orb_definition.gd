class_name OrbDefinition extends Resource
## Resource definition for orb types.
## Enables data-driven orb configuration and easy addition of new orb types.

## Unique identifier for this orb type (used for registry lookup)
@export var type_name: StringName

## Human-readable name for UI/debugging
@export var display_name: String

## Points awarded when this orb is collected
@export var score_value: int = 1

## How long the orb exists before despawning (in seconds)
@export var lifespan_seconds: float = 30.0

## Scene to instantiate for this orb (if using custom scene)
@export var scene: PackedScene

## Sprite texture for the orb (if using default orb scene)
@export var sprite_texture: Texture2D

## Whether this orb has a physics body (like half-solid orbs)
@export var has_physics_body: bool = false

@export_category("Spawn Settings")
## Relative probability of spawning (higher = more likely)
@export var spawn_weight: float = 1.0
