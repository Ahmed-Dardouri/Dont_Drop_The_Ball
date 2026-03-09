class_name PlayerPhysicsConfig extends Resource
## Configuration resource for player physics parameters.
## Enables editor-editable configs and data-driven physics tuning.

@export var jump_power: int = -700
@export var move_speed: int = 120
@export var acceleration: float = 1500.0
@export var initial_acceleration: float = 2000.0
@export var deceleration: float = 10000.0
@export var coyote_timeout: float = 150.0
@export var jump_buffer_timeout: float = 150.0
@export var fall_acceleration: float = 1800.0
@export var max_fall_speed: float = 800.0
@export var grounding_force: float = 1.5
@export var early_jump_gravity_modifier: float = 3.0
