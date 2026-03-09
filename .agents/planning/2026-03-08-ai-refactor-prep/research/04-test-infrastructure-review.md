# Research: Test Infrastructure Review

## Current Test Configuration

### GUT Configuration (.gutconfig.json)

```json
{
  "dirs": ["res://tests/"],
  "include_subdirs": true,
  "prefix": "test_",
  "suffix": ".gd",
  "log_level": 2,
  "should_exit": true
}
```

### Test Directory Structure

```
tests/
├── unit/
│   ├── test_sanity.gd           # Basic sanity check
│   ├── test_ball_physics.gd     # Ball physics logic
│   ├── test_events.gd           # Event system tests
│   ├── test_orb_scoring.gd      # Orb score mapping
│   ├── test_orb_properties.gd   # OrbProps resource tests
│   ├── test_saved_game.gd       # Save data tests
│   ├── test_pause_state.gd      # Pause state tests
│   └── test_player_movement.gd  # Player physics tests
└── integration/
    └── test_score_accumulation.gd  # Score through events
```

## Test Coverage Analysis

### Currently Tested

| System | Test File | Coverage |
|--------|-----------|----------|
| Ball physics | test_ball_physics.gd | clamp_max_speed, clamp_fall_speed, apply_air_friction |
| Player movement | test_player_movement.gd | update_move, can_coyote, has_buffered_jump |
| Event system | test_events.gd | add_listener, remove_listener, invoke |
| Orb scoring | test_orb_scoring.gd | Score values, ordering |
| Orb properties | test_orb_properties.gd | OrbProps creation, types |
| Saved game | test_saved_game.gd | SavedGame properties, duplication |
| Pause state | test_pause_state.gd | PauseEvent.state behavior |
| Score integration | test_score_accumulation.gd | Score through event system |

### Not Tested (Gaps)

| System | Why Missing |
|--------|-------------|
| Orb spawner | Scene-dependent, random elements |
| Orb collision/collection | Scene-dependent |
| Game state transitions | Scene-dependent |
| World builder | Scene-dependent |
| Sound manager | Audio system |
| Menu navigation | UI/Input |
| Save/load file I/O | File system |

## Test Patterns Used

### 1. Inline Script Creation (Avoiding Scene Dependencies)

```gdscript
# test_ball_physics.gd
func _create_ball_test_script() -> GDScript:
    var script = GDScript.new()
    script.source_code = """
extends RigidBody2D
var max_speed := 900.0
func clamp_max_speed(): ...
"""
    script.reload()
    return script
```

**Pros**: No scene files needed, fast tests
**Cons**: Logic duplicated, tests can drift from implementation

### 2. Direct State Manipulation

```gdscript
# test_pause_state.gd
func before_each() -> void:
    PauseEvent.state = false  # Direct static state manipulation
```

**Pros**: Simple
**Cons**: Tests are coupled to global state, need cleanup

### 3. Event Listener Testing

```gdscript
# test_score_accumulation.gd
func test_score_accumulation_single() -> void:
    Events.add_listener(AddScoreEvent, Callable(self, "_add_score_handler"))
    await AddScoreEvent.invoke(10)
    assert_eq(_score, 10)
    Events.remove_listener(AddScoreEvent, Callable(self, "_add_score_handler"))
```

**Pros**: Tests actual event flow
**Cons**: Requires cleanup, uses global Events singleton

### 4. Pure Function Testing

```gdscript
# test_player_movement.gd
func _update_move(left_held: bool, right_held: bool) -> float:
    if right_held: return 1.0
    elif left_held: return -1.0
    else: return 0.0

func test_update_move_right() -> void:
    var move_x := _update_move(false, true)
    assert_eq(move_x, 1.0)
```

**Pros**: No dependencies, deterministic
**Cons**: Tests copy of logic, not actual code

## GUT Capabilities for Integration Testing

### Available Features

1. **`add_child_autofree(node)`**: Auto-freed after test
2. **`double_scene(path)`**: Create test double of scene
3. **`partial_double(path)`**: Partial mock
4. **`stub()`**: Method stubbing
5. **`spy_on()`**: Call tracking
6. **`await` support**: For async tests

### Current Underutilization

- Not using `double_scene` for scene-dependent tests
- Not using spies/stubs for isolation
- Not testing signal emissions

## Recommended Test Improvements

### 1. Extract Pure Logic Classes

```gdscript
# scripts/utils/ball_physics.gd
class_name BallPhysics

static func clamp_max_speed(velocity: Vector2, max_speed: float) -> Vector2:
    if max_speed > 0.0:
        var s := velocity.length()
        if s > max_speed:
            return velocity * (max_speed / s)
    return velocity
```

Then test directly:
```gdscript
func test_clamp_max_speed():
    var result = BallPhysics.clamp_max_speed(Vector2(1000, 0), 900.0)
    assert_almost_eq(result.x, 900.0, 0.1)
```

### 2. Use GUT Doubles for Scene Tests

```gdscript
func test_orb_collection():
    var orb = partial_double("res://scenes/blue_orb.tscn")
    add_child_autofree(orb)
    # Test orb behavior with mocked dependencies
```

### 3. Integration Test Patterns

```gdscript
# tests/integration/test_orb_collection.gd
func test_orb_awardes_correct_score():
    # Set up fresh event system state
    var score := 0
    Events.add_listener(AddScoreEvent, func(e): score += e._score)

    # Create orb and simulate collection
    var orb = auto_free(blue_orb_scene.instantiate())
    add_child(orb)
    orb.orb_collected()

    # Wait for event propagation
    await get_tree().process_frame

    assert_eq(score, Constants.orb_score_blue)
```

### 4. State Reset Utilities

```gdscript
# tests/test_utils.gd
class_name TestUtils

static func reset_global_state():
    PauseEvent.state = false
    Variables.current_score = 0
    # ... other resets
```

## Test Infrastructure Goals

1. **Pure unit tests**: Logic classes with no scene/node dependencies
2. **Integration tests**: Scene-based tests with proper cleanup
3. **State isolation**: Each test starts with clean global state
4. **No logic duplication**: Test actual code, not copies
5. **Comprehensive coverage**: All refactored systems tested
