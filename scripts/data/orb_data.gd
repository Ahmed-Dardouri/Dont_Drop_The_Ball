class_name OrbData extends Resource
## Data resource defining all orb properties for the data-driven orb system.
## Replaces hardcoded orb scripts with configurable resources.

#region Display Properties

## Human-readable name for the orb (shown in UI/debug)
@export var display_name: String = "Orb"

## Sprite texture for the orb
@export var texture: Texture2D

## Scale multiplier for the sprite
@export var scale: Vector2 = Vector2.ONE

#endregion

#region Gameplay Properties

## Base score awarded when orb is collected
@export var base_score: int = 1

## Time in seconds before orb despawns
@export var lifespan: float = 30.0

## Spawn weight for weighted random selection (higher = more common)
@export var spawn_weight: float = 1.0

#endregion

#region Physics Properties

## Collision detection radius
@export var collision_radius: float = 32.0

## Whether this orb acts as a half-solid platform
@export var is_half_solid: bool = false

## Alternative texture for half-solid display (bottom half)
@export var half_solid_texture: Texture2D

#endregion

#region Behaviors

## Array of behaviors to execute on collection
@export var behaviors: Array[OrbBehavior] = []

#endregion

#region Spawn Animation

## Duration of spawn fade-in animation in seconds
@export var spawn_animation_duration: float = 0.5

#endregion
