# Existing Orb Implementation Research

## 1. Orb-Related Files and Their Responsibilities

### Core Orb Scripts

| File | Class Name | Responsibility |
|------|------------|----------------|
| `/scripts/generic_orb.gd` | `GenericOrb` | Container/selector that holds all orb types as children; manages spawn animation and opacity transitions; selects one orb type based on `OrbProps` |
| `/scripts/blue_orb.gd` | `BlueOrb` | Basic collectible orb (score: 2, lifespan: 30s); uses Area2D for collision detection |
| `/scripts/red_orb.gd` | `RedOrb` | Basic collectible orb (score: 3, lifespan: 30s); uses Area2D for collision detection |
| `/scripts/half_solid_orb.gd` | `HalfSolidOrb` | Advanced orb with physical collision (score: 8, lifespan: 18s); has both Area2D for collection AND StaticBody2D for ball bounce interaction |

### Orb Management Scripts

| File | Class Name | Responsibility |
|------|------------|----------------|
| `/scripts/orb_spawner.gd` | N/A | Spawns `GenericOrb` instances on a timer; uses `OrbProps` array to determine which orb types to spawn |
| `/scripts/orb_mngr.gd` | N/A | Listens for `OrbCollectedEvent` and adds appropriate score based on orb type; contains `orb_spawner` as child |

### Supporting Scripts

| File | Class Name | Responsibility |
|------|------------|----------------|
| `/scripts/utils/orb_properties.gd` | `OrbProps` | Resource class holding orb type (`Enums.OrbType`); used to configure which orb type to instantiate |
| `/scripts/utils/enums.gd` | `Enums` | Contains `OrbType` enum: `RED`, `BLUE`, `HALF_SOLID` |
| `/scripts/utils/Constants.gd` | N/A | Contains orb-related constants: `orb_lifespan_blue=30`, `orb_lifespan_red=30`, `orb_lifespan_half_solid=18`, `orb_score_blue=2`, `orb_score_red=3`, `orb_score_half_solid=8` |
| `/scripts/utils/variables.gd` | N/A | Stores `current_score` updated by score_mngr |

### Event Scripts

| File | Class Name | Responsibility |
|------|------------|----------------|
| `/scripts/events/orb_collected_event.gd` | `OrbCollectedEvent` | Event fired when any orb is collected; carries `OrbProps` payload; checks `PauseEvent.state` before invoking |
| `/scripts/events/add_score_event.gd` | `AddScoreEvent` | Event fired to add score; listened to by `score_mngr` |
| `/scripts/events/sound_play_event.gd` | `SoundPlayEvent` | Event for playing sounds; used by orbs to play collection sound |
| `/scripts/events/pause_event.gd` | `PauseEvent` | Event for pause state; orbs check this before invoking collection event |

### Scene Files

| File | Purpose |
|------|---------|
| `/scenes/generic_orb.tscn` | Container scene with Timer and child_orbs node containing all three orb types |
| `/scenes/blue_orb.tscn` | BlueOrb with Sprite2D, Area2D/CollisionShape2D (CircleShape2D, radius=56), Timer |
| `/scenes/red_orb.tscn` | RedOrb with same structure as blue_orb |
| `/scenes/half_solid_orb.tscn` | HalfSolidOrb with collect_sprite, StaticBody2D/CollisionPolygon2D, Sprite2D (solid), collectArea2D/CollectCollisionPolygon2D, Timer |
| `/scenes/orb_spawner.tscn` | OrbSpawner configured with generic_orb_scene and OrbProps array |
| `/scenes/orb_mngr.tscn` | Contains orb_mngr script and orb_spawner child |

---

## 2. Spawning Flow (OrbSpawner -> GenericOrb -> Specific Orb Types)

```
OrbSpawner (timer-based)
    |
    v
create_orb_copy(props: OrbProps)
    |
    v
generic_orb_scene.instantiate()
    |
    v
GenericOrb.set_type(props)  --> Stores props in _props
    |
    v
GenericOrb._ready()
    |
    +--> update_orb() --> converge_orb(_props.Type)
    |                           |
    |                           v
    |                   Match on type:
    |                   - BLUE -> _child_orb = blue_orb
    |                   - RED -> _child_orb = red_orb
    |                   - HALF_SOLID -> _child_orb = half_solid_orb
    |                           |
    |                           v
    |                   queue_free() all OTHER child orbs
    |
    +--> init_timer() --> Starts 1.5s spawn animation timer
    |
    +--> disable_child_orb() --> opacity=0, collision=false
    |
    v
_process() runs orb_spawn_animation()
    |
    v
    On Timer timeout:
    enable_child_orb() --> opacity=1, collision=true
```

### Key Observations:
- **Wasteful instantiation**: GenericOrb scene contains ALL three orb types as pre-instanced children. Two of them are always `queue_free()`'d.
- **Spawn animation**: 1.5 second fade-in animation controlled by GenericOrb's timer
- **Type selection**: Determined by `OrbProps.Type` passed from OrbSpawner

---

## 3. Scoring System Interaction

### Flow:
```
Ball enters orb's Area2D
    |
    v
[BlueOrb/RedOrb/HalfSolidOrb]._on_area_2d_body_entered(body)
    |
    v (if body.name == "ball")
orb_collected()
    |
    +--> OrbCollectedEvent.invoke(_props)
    |           |
    |           v (checks PauseEvent.state == false)
    |       Events.invoke(OrbCollectedEvent.new(props))
    |
    +--> SoundPlayEvent.invoke(SFX, ORB_COLLECTED)
    |
    +--> queue_free()
    |
    v
orb_mngr.orb_event_handler(event: OrbCollectedEvent)
    |
    v (match on event._props.Type)
    - BLUE: AddScoreEvent.invoke(Constants.orb_score_blue)    // +2
    - RED: AddScoreEvent.invoke(Constants.orb_score_red)      // +3
    - HALF_SOLID: AddScoreEvent.invoke(Constants.orb_score_half_solid)  // +8
    |
    v
score_mngr.add_score_handler(event: AddScoreEvent)
    |
    v
_score += event._score
Variables.current_score = score
```

### Score Values (from Constants.gd):
- BlueOrb: 2 points
- RedOrb: 3 points
- HalfSolidOrb: 8 points

### Key Observations:
- **Event-driven**: Scoring is completely decoupled via events
- **Type-to-score mapping**: Hardcoded in `orb_mngr.gd` match statement
- **Pause-aware**: `OrbCollectedEvent.invoke()` checks pause state before firing

---

## 4. Ball Collision Detection

### BlueOrb / RedOrb (identical):
```gdscript
# Structure: Node2D > Area2D > CollisionShape2D (CircleShape2D, radius=56)
func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```
- Pure Area2D detection
- No physical interaction with ball
- Ball passes through

### HalfSolidOrb (different):
```gdscript
# Structure:
# - collect_sprite (Sprite2D)
# - half_static (StaticBody2D) > CollisionPolygon2D  [physical collision]
# - Sprite2D (solid half visual)
# - collectArea2D > CollectCollisionPolygon2D  [collection detection]

func _on_collect_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```

### Ball's HalfSolidOrb Interaction (in `/scripts/ball.gd`):
```gdscript
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("ground") && !game_over:
        # ... game over logic
    elif body.is_in_group("half_solid"):
        linear_velocity = linear_velocity/3  # Velocity reduced to 1/3
```

### Key Observations:
- **HalfSolidOrb uses "half_solid" group** for ball physics interaction
- **Ball must be RigidBody2D** for physics to work
- **CollisionPolygon2D** provides semi-circular collision shape (matches visual half-circle)
- **Two collision areas**: StaticBody2D for bounce, Area2D for collection

---

## 5. Dependencies Between Orb Scripts and Other Systems

### Dependency Graph:

```
                    +------------------+
                    |    Constants     |
                    | (lifespan, score)|
                    +--------+---------+
                             |
        +--------------------+--------------------+
        |                    |                    |
        v                    v                    v
+---------------+    +---------------+    +---------------+
|    BlueOrb    |    |    RedOrb     |    | HalfSolidOrb  |
+-------+-------+    +-------+-------+    +-------+-------+
        |                    |                    |
        |     +--------------+--------------+     |
        |     |                              |     |
        v     v                              v     v
+----------------+                    +----------------+
|  OrbCollected  |                    | SoundPlayEvent |
|     Event      |                    |    (SFX)       |
+-------+--------+                    +----------------+
        |
        v
+---------------+
|   orb_mngr    |
| (score logic) |
+-------+-------+
        |
        v
+---------------+
| AddScoreEvent |
+-------+-------+
        |
        v
+---------------+
|  score_mngr   |
+---------------+
        |
        v
+---------------+
|   Variables   |
| current_score |
+---------------+


GenericOrb Dependencies:
+---------------+
|  GenericOrb   |
+-------+-------+
        |
        +--> BlueOrb, RedOrb, HalfSolidOrb (as child scene references)
        |
        +--> OrbProps (for type selection)
        |
        +--> Enums.OrbType


OrbSpawner Dependencies:
+---------------+
|  OrbSpawner   |
+-------+-------+
        |
        +--> PackedScene (generic_orb_scene)
        |
        +--> OrbProps[] (type configuration)
        |
        +--> "orbs" group (for max_orbs count)
```

### External System Dependencies:
| System | How Orbs Depend On It |
|--------|----------------------|
| `Events` singleton | `OrbCollectedEvent`, `AddScoreEvent`, `SoundPlayEvent` all use `Events.invoke()` |
| `Constants` singleton | Lifespan values (`orb_lifespan_*`) |
| `Enums` class | `OrbType` enum, `SoundType`, `Sounds` |
| `PauseEvent` | Checked before invoking collection event |
| `Variables` singleton | `current_score` updated indirectly via score_mngr |
| Ball's "ball" name | Collision detection uses `body.name == "ball"` |
| "half_solid" group | Ball detects HalfSolidOrb via group membership |

---

## 6. HalfSolidOrb - Special Behaviors

### Unique Characteristics:

1. **Dual Collision System**:
   - `StaticBody2D` with `CollisionPolygon2D`: Provides physical surface for ball to bounce off
   - `Area2D` with `CollectCollisionPolygon2D`: Detects when ball enters for collection

2. **Physics Material** (from scene):
   ```
   friction = 554.25
   rough = true
   absorbent = true
   ```

3. **Ball Velocity Modification**:
   - When ball collides with HalfSolidOrb's StaticBody2D, ball's velocity is divided by 3
   - Located in `/scripts/ball.gd`:
     ```gdscript
     elif body.is_in_group("half_solid"):
         linear_velocity = linear_velocity/3
     ```

4. **Visual Structure**:
   - Two sprites: `collect_sprite` (left half, collectible area) and `Sprite2D` (right half, solid visual)
   - Represents a half-circle where one side is collectible and one side is solid

5. **Shorter Lifespan**: 18 seconds (vs 30 for other orbs)

6. **Higher Score**: 8 points (vs 2-3 for other orbs)

7. **Group Membership**: Must be in "half_solid" group for ball physics detection

### Collision Polygon Shape:
```
Semi-circular polygon approximating a half-circle:
polygon = PackedVector2Array(0.015625, 0.0078125, 0.046875, -41.3594, 12.0951, -39.7556, ...)
```
The polygon creates a curved surface matching the visual half-circle appearance.

---

## 7. What Must Be Preserved During Migration

### Critical Behaviors:
1. **Spawn animation**: 1.5s fade-in with opacity transition
2. **Lifespan timeout**: Auto-cleanup via timer
3. **Collection flow**: Area2D body_entered -> orb_collected() -> events -> queue_free()
4. **Score mapping**: Type-to-score must remain consistent
5. **Sound effect**: ORB_COLLECTED sound on collection
6. **Pause check**: Events must not fire when paused

### HalfSolidOrb-Specific Must-Haves:
1. **"half_solid" group membership**: Required for ball physics
2. **StaticBody2D with CollisionPolygon2D**: Physical collision surface
3. **Velocity reduction**: Ball velocity / 3 on collision
4. **Physics material**: friction, rough, absorbent properties
5. **Dual sprite structure**: Visual representation of collectible vs solid halves

### Event Contracts:
- `OrbCollectedEvent` must carry `OrbProps` with valid `Type`
- `AddScoreEvent` must carry integer score value
- Both events check `PauseEvent.state` before invoking

### Scene References:
- `generic_orb.tscn` must contain all orb type children
- `orb_spawner.tscn` must reference `generic_orb_scene`
- Individual orb scenes must maintain their collision/sprite structure

### Constants References:
- `orb_lifespan_blue`, `orb_lifespan_red`, `orb_lifespan_half_solid`
- `orb_score_blue`, `orb_score_red`, `orb_score_half_solid`

### Interface Contracts:
- `set_type(props: OrbProps)`: Called by OrbSpawner
- `set_sprite_opacity(value: float)`: Called by GenericOrb during spawn animation
- `set_collision_enable(value: bool)`: Called by GenericOrb during spawn animation

---

## 8. Known Issues / Technical Debt

1. **Code Duplication**: ~80% identical code across BlueOrb, RedOrb, HalfSolidOrb
2. **Wasteful Scene Instantiation**: GenericOrb loads all types, deletes 2
3. **Hardcoded Ball Name**: Uses `body.name == "ball"` instead of groups
4. **Tight Coupling**: Orbs directly import Constants, Enums, multiple event classes
5. **Inconsistent Patterns**: BlueOrb/RedOrb use Area2D collision, HalfSolidOrb uses separate Area2D node

---

## 9. Extension Points for New Orb Types

To add a new orb type, the following must be modified:
1. Add new value to `Enums.OrbType`
2. Add lifespan/score constants to `Constants.gd`
3. Create new orb script (currently requires copy-paste pattern)
4. Create new orb scene with Sprite2D, Area2D, Timer
5. Add scene reference to `generic_orb.tscn` as child
6. Add case to `GenericOrb.converge_orb()`
7. Add score case to `orb_mngr.orb_event_handler()`
8. Add to `OrbProps` array in spawner configuration

This is the primary pain point the unified system should address.
