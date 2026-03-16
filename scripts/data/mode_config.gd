class_name ModeConfig extends Resource
## Configuration resource for game modes.
## Defines mode properties for editor configuration.
## Matches the existing OrbData resource pattern.

#region Identity Properties

## Unique identifier for the mode (e.g., "endless", "time_attack")
@export var mode_id: String = ""

## Human-readable name displayed in UI
@export var display_name: String = ""

## Description shown in mode selection screen
@export var description: String = ""

## Optional icon for mode selection UI
@export var icon: Texture2D

#endregion

#region Implementation Properties

## GDScript containing mode logic (extends ModeBase)
@export var implementation: GDScript

## Custom orb pool for this mode (empty = use default)
@export var orb_pool: Array[OrbData] = []

#endregion

#region Gameplay Properties

## Seconds between orb spawns (0 = use default)
@export var spawn_interval: float = 0.0

## Maximum orbs on screen (0 = use default)
@export var max_orbs: int = 0

## Metric name to display on HUD (e.g., "score", "time", "wave")
@export var hud_metric: String = "score"

## Whether this mode has a win condition
@export var has_win: bool = false

#endregion

#region Mode-Specific Tuning

## Ball physics configuration for this mode (null = use global defaults)
@export var ball_physics_config: BallPhysicsConfig

## Player physics configuration for this mode (null = use global defaults)
@export var player_physics_config: PlayerPhysicsConfig

## Progression configuration for this mode (null = use global defaults)
@export var progression_config: ProgressionConfig

## Background color for this mode (Color(0, 0, 0, 0) = use default dark)
@export var background_color: Color = Color(0, 0, 0, 0)

## Whether to show parallax background (true = show forest parallax, false = solid color only)
@export var show_parallax_background: bool = true

#endregion

#region Validation

## Returns true if required fields are populated
func is_valid() -> bool:
	return not mode_id.strip_edges().is_empty() and not display_name.strip_edges().is_empty()

#endregion
