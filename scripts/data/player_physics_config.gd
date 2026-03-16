class_name PlayerPhysicsConfig extends Resource
## Configuration resource for player physics parameters.
## Enables editor-editable configs and data-driven physics tuning.

## Power applied when using keyboard movement (0 = use global default)
@export var keyboard_move_power: int = 0

## Jump power (negative = upward). Higher absolute value = higher jump.
@export var jump_power: int = -700

## Initial horizontal move speed
@export var move_speed: int = 120

## Normal horizontal acceleration
@export var acceleration: float = 1500.0

## Initial acceleration (faster start)
@export var initial_acceleration: float = 2000.0

## Deceleration when stopping
@export var deceleration: float = 10000.0

## Coyote time window in milliseconds
@export var coyote_timeout: float = 150.0

## Jump buffer window in milliseconds
@export var jump_buffer_timeout: float = 150.0

## Gravity acceleration when falling
@export var fall_acceleration: float = 1800.0

## Maximum fall speed
@export var max_fall_speed: float = 800.0

## Force keeping player grounded
@export var grounding_force: float = 1.5

## Gravity multiplier when jump released early
@export var early_jump_gravity_modifier: float = 3.0
