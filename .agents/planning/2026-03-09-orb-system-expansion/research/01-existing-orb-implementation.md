# Research: Existing Orb Implementation

## Overview

The current orb system consists of 4 scenes and 5 scripts with significant code duplication.

## File Structure

```
scenes/
├── generic_orb.tscn      # Wrapper scene with all orb types as children
├── blue_orb.tscn         # Blue orb prefab
├── red_orb.tscn          # Red orb prefab
└── half_solid_orb.tscn   # Half-solid orb prefab

scripts/
├── generic_orb.gd        # Wrapper script, selects child orb based on OrbProps.Type
├── blue_orb.gd           # Nearly identical to red_orb.gd
├── red_orb.gd            # Nearly identical to blue_orb.gd
├── half_solid_orb.gd     # Similar but with extra collision shape
├── orb_spawner.gd        # Timer-based spawning
├── orb_mngr.gd           # Event handler → score mapping
└── utils/orb_properties.gd  # Simple Resource with Type enum
```

## Spawning Flow

```
OrbSpawner._on_timeout()
  └── create_orb_copy(props)
      └── generic_orb_scene.instantiate()
      └── orb.set_type(props)  # Sets _props
      └── add_child(orb)

GenericOrb._ready()
  └── update_orb()
      └── converge_orb(_props.Type)  # Match on type, set _child_orb
      └── Queue free other children
```

## Collection Flow

```
Ball enters Area2D of orb (body.name == "ball")
  └── orb_collected()
      └── OrbCollectedEvent.invoke(_props)
      └── SoundPlayEvent.invoke(SFX, ORB_COLLECTED)
      └── queue_free()

OrbManager.orb_event_handler(event)
  └── match event._props.Type
      └── AddScoreEvent.invoke(Constants.orb_score_*)
```

## Current Orb Types

| Type | Score | Lifespan | Special |
|------|-------|----------|---------|
| BLUE | 2 | 30s | None |
| RED | 3 | 30s | None |
| HALF_SOLID | 8 | 18s | Has collision polygon, slows ball on hit |

## Code Duplication Analysis

**BlueOrb vs RedOrb:** 95% identical
- Same structure: Sprite2D + Area2D + Timer
- Same methods: orb_collected(), setup_timer(), set_sprite_opacity(), set_collision_enable()
- Only difference: `_props.Type` and `_lifespan` constant value

**HalfSolidOrb:** 80% similar
- Extra: StaticBody2D with CollisionPolygon2D (half-solid collision)
- Extra: Collect Area2D separate from collision
- Ball interaction: `linear_velocity = linear_velocity/3` on collision

## Key Dependencies

1. **OrbProps** - Resource class, only has `Type: Enums.OrbType`
2. **OrbCollectedEvent** - Event fired on collection, carries OrbProps
3. **Constants** - Score values and lifespans (not in OrbProps!)
4. **Events (EventManager)** - Event bus singleton
5. **Ball** - Checks for `"ball"` name in collision

## Issues to Address

1. **Hardcoded values in scripts** - Score/lifespan in Constants, not OrbProps
2. **No effect system** - All orbs just add score via event
3. **Name-based collision check** - `body.name == "ball"` is fragile
4. **Scene coupling** - All orb types embedded in generic_orb.tscn
5. **No extensibility** - Adding new orb requires new scene + script

## What Must Be Preserved

1. Orb spawning via OrbSpawner with OrbProps array
2. OrbCollectedEvent pattern (other systems listen for it)
3. Sound effect on collection
4. Ball collision detection (but use groups, not name)
5. Half-solid physics interaction (ball bounces off)
6. Score values (for backwards compatibility if needed)
