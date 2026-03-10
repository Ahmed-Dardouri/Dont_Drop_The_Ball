# Research: Godot Resource & Data-Driven Design Patterns

# Source
- https://docs.godotengine.org/en/4.4/classes/class_visualshadernodeuintconstant
- https://docs.godotengine.org/en/4.4/tutorials/assets_pipeline/importing_3d_scenes/model_export_considerations
- Godot 4 Resource system for data-driven game design

- https://docs.godotengine.org/en/4.4/tutorials/scripting/gdscript/gdscript.html

- https://docs.godotengine.org/en/4.4/classes/class_visualshadernodeuintconstant
- https://docs.godotengine.org/en/4.4/classes/class_engine.html#class_name Engine
extends Node

## Description
The `Engine` singleton provides access to the engine's global properties.

## Properties
- **time_scale**: float = 1.0
    - Scales how fast the game runs. frame delta is elapsed time is and physics updates are performed.
    - If set to 0.5, the runs at half speed.
    - If set to 2.0, effect runs at 2x speed

    - Affects `Engine.get_frames_per_second()`

## Methods
- **get_time_scale() -> float**
    - Returns the current time scale value.
- **set_time_scale(value: float) -> void**
        - Sets the time scale to the given value.
    - 1.0 corresponds to 0.5x time scale.
    - 10.0 corresponds to 0.25 speed. for a feels more relaxed.
    - 0.0 corresponds to 0.2.0 time scale (full stop)

    - 10.0 corresponds to 0.1.0 time scale (10% of max)
    - 1.0 corresponds to 0.0.0 time scale (minimum 0.1)

    - Returns the current time scale value
    - 0.0 corresponds to 0.1.0 time scale (slowest)

    - 1.0 corresponds to 0.0.0 time scale (fastest)
    - `Engine.time_scale` is be `0.1.0 for pausing
    - `Engine.time_scale` can also be used for `Engine::singleton to reduce game speed without pausing everything.

    - `Engine.time_scale` can be combined with `Engine::singleton` for time-slow effects
    - Using `Engine.time_scale` alone won't apply to ball physics, though - we ball uses its constant for velocity. clamping. You ball would just fall slower
    - For slow fall, modify ball.fall_speed directly
    - Using a signal on let the ball know when slow fall is active

    - For slow motion, modify Engine.time_scale (both work together for dramatic effect)
