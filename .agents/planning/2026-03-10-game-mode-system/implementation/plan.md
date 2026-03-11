# Game Mode System - Implementation Plan

## Implementation Checklist

- [ ] Step 1: Mode Data Foundation
- [ ] Step 2: ModeManager Singleton Core
- [ ] Step 3: ModeBase and EndlessMode
- [ ] Step 4: Integrate ModeManager with Game Flow
- [ ] Step 5: Mode Selection UI
- [ ] Step 6: Time Attack Mode
- [ ] Step 7: Orb Hunt Mode
- [ ] Step 8: Survival Mode
- [ ] Step 9: Mode-Specific Orb Pools
- [ ] Step 10: High Score Persistence
- [ ] Step 11: HUD Mode Display
- [ ] Step 12: Final Integration and Polish

---

## Step 1: Mode Data Foundation

**Objective:** Create the data structures for mode configuration.

**Implementation Guidance:**
1. Create `scripts/data/mode_config.gd` - Resource class with mode properties
2. Create `resources/modes/` directory
3. Create `resources/modes/endless_mode.tres` with basic config

**Code Structure:**
```gdscript
# scripts/data/mode_config.gd
class_name ModeConfig extends Resource

@export var mode_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var implementation: GDScript
@export var orb_pool: Array[OrbData] = []
@export var spawn_interval: float = 0.0
@export var max_orbs: int = 0
@export var hud_metric: String = "score"
@export var has_win: bool = false
```

**Test Requirements:**
- Unit test: `test_mode_config.gd`
  - Test default values
  - Test resource loading
  - Test validation (mode_id not empty)

**Integration:**
- No integration yet - standalone data structures

**Demo:**
- Run test suite, verify ModeConfig can be instantiated and loaded from .tres file

---

## Step 2: ModeManager Singleton Core

**Objective:** Create the ModeManager singleton with basic lifecycle management.

**Implementation Guidance:**
1. Create `scripts/core/mode_manager.gd`
2. Register as autoload "ModeManager" in project.godot
3. Implement core methods: `start_mode()`, `end_mode()`, `get_current_mode()`
4. Add signals: `mode_started`, `mode_ended`

**Code Structure:**
```gdscript
# scripts/core/mode_manager.gd
class_name ModeManager extends Node

signal mode_started(mode_id: String)
signal mode_ended(mode_id: String, result: Dictionary)

var current_mode: ModeConfig = null
var _available_modes: Dictionary = {}

func _ready() -> void:
    _load_mode_configs()

func _load_mode_configs() -> void:
    # Load all mode configs from resources/modes/
    pass

func start_mode(mode_id: String) -> void:
    # Set current_mode, emit signal
    pass

func end_mode(result: Dictionary) -> void:
    # Clear current_mode, emit signal
    pass

func get_mode_config(mode_id: String) -> ModeConfig:
    return _available_modes.get(mode_id, null)
```

**Test Requirements:**
- Unit test: `test_mode_manager.gd`
  - Test mode loading
  - Test start_mode sets current_mode
  - Test end_mode clears current_mode
  - Test signals emit correctly

**Integration:**
- Registered as autoload, accessible globally

**Demo:**
- Call `ModeManager.start_mode("endless")` from a test, verify current_mode is set

---

## Step 3: ModeBase and EndlessMode

**Objective:** Create abstract ModeBase and implement EndlessMode.

**Implementation Guidance:**
1. Create `scripts/modes/` directory
2. Create `scripts/modes/mode_base.gd` - abstract base class
3. Create `scripts/modes/endless_mode.gd` - concrete implementation
4. Update `resources/modes/endless_mode.tres` to reference implementation

**Code Structure:**
```gdscript
# scripts/modes/mode_base.gd
class_name ModeBase extends RefCounted

var config: ModeConfig

func _on_start() -> void:
    pass

func _on_process(_delta: float) -> void:
    pass

func _on_orb_collected(_orb_data: OrbData, base_score: int) -> int:
    return base_score

func _check_win() -> bool:
    return false

func _check_lose() -> bool:
    return false

func _on_end() -> void:
    pass

func _get_metric() -> Dictionary:
    return {"name": "score", "value": 0, "max": 0}

func _get_final_score() -> int:
    return ScoreManager.get_score()
```

```gdscript
# scripts/modes/endless_mode.gd
class_name EndlessMode extends ModeBase

# No win condition, lose on ball drop
# Metric is current score
```

**Test Requirements:**
- Unit test: `test_mode_base.gd`
  - Test default implementations return expected values
- Unit test: `test_endless_mode.gd`
  - Test _check_win returns false
  - Test _get_metric returns score

**Integration:**
- ModeManager instantiates ModeBase subclass from config

**Demo:**
- Start endless mode, verify mode implementation is active

---

## Step 4: Integrate ModeManager with Game Flow

**Objective:** Connect ModeManager to existing game lifecycle events.

**Implementation Guidance:**
1. Modify `scripts/world_builder.gd` to call `ModeManager.start_mode()` when game starts
2. Connect ModeManager to GameOverEvent and ReplayEvent
3. Extract game-over-trigger logic from `ball.gd` to be mode-aware

**Changes to world_builder.gd:**
```gdscript
func load_world():
    # Add: Start default mode if none set
    if ModeManager.current_mode == null:
        ModeManager.start_mode("endless")
    # ... existing code
```

**Changes to ball.gd:**
```gdscript
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("ground") && !game_over:
        game_over = true
        # ModeManager will handle this via GameOverEvent
        GameOverEvent.invoke()
        # ... rest unchanged
```

**Test Requirements:**
- Integration test: `test_mode_transitions.gd`
  - Test game start initializes mode
  - Test game over triggers mode end
  - Test replay restarts mode

**Integration:**
- Connects to existing event system
- Uses existing GameOverEvent, ReplayEvent

**Demo:**
- Play game from main menu, verify ModeManager.current_mode is set
- Drop ball, verify mode ends correctly

---

## Step 5: Mode Selection UI

**Objective:** Create mode selection screen and integrate with main menu.

**Implementation Guidance:**
1. Create `scenes/mode_selection.tscn` with VBoxContainer of mode buttons
2. Create `scripts/mode_selection.gd` controller
3. Modify `scripts/main_menu.gd` to add "Select Mode" button
4. Add to `scripts/utils/enums.gd`: `MainScene.MODE_SELECTION`

**Code Structure:**
```gdscript
# scripts/mode_selection.gd
extends Control

@onready var vbox: VBoxContainer = $VBoxContainer

func _ready() -> void:
    _populate_modes()

func _populate_modes() -> void:
    for mode_id in ModeManager._available_modes:
        var config = ModeManager.get_mode_config(mode_id)
        var btn = Button.new()
        btn.text = config.display_name
        btn.pressed.connect(_on_mode_selected.bind(mode_id))
        vbox.add_child(btn)

func _on_mode_selected(mode_id: String) -> void:
    ModeManager.start_mode(mode_id)
    ButtonEvent.invoke(Enums.MainButtonType.PLAY)
```

**Changes to main_menu.gd:**
```gdscript
func _on_select_mode_pressed() -> void:
    ButtonEvent.invoke(Enums.MainButtonType.SELECT_MODE)
```

**Test Requirements:**
- Integration test: `test_mode_selection.gd`
  - Test mode buttons are created for each available mode
  - Test selecting a mode sets ModeManager.current_mode

**Integration:**
- Connected to main menu via ButtonEvent
- Uses ModeManager to start modes

**Demo:**
- Click "Select Mode" from main menu
- See list of modes
- Click a mode, verify game starts with that mode

---

## Step 6: Time Attack Mode

**Objective:** Implement Time Attack mode with 2-minute timer.

**Implementation Guidance:**
1. Create `scripts/modes/time_attack_mode.gd`
2. Create `resources/modes/time_attack_mode.tres`
3. Add timer logic with win on time expire

**Code Structure:**
```gdscript
# scripts/modes/time_attack_mode.gd
class_name TimeAttackMode extends ModeBase

const DURATION: float = 120.0  # 2 minutes

var _time_remaining: float = DURATION

func _on_start() -> void:
    _time_remaining = DURATION

func _on_process(delta: float) -> void:
    _time_remaining -= delta
    if _time_remaining <= 0:
        _time_remaining = 0
        ModeManager.end_mode({"win": true, "reason": "time_up"})

func _check_win() -> bool:
    return _time_remaining <= 0

func _get_metric() -> Dictionary:
    return {"name": "timer", "value": _time_remaining, "max": DURATION}
```

**Test Requirements:**
- Unit test: `test_time_attack_mode.gd`
  - Test initial time is 120 seconds
  - Test _on_process decrements time
  - Test _check_win returns true when time <= 0
  - Test _get_metric returns correct values

**Integration:**
- Loaded via ModeManager when time_attack selected

**Demo:**
- Select Time Attack mode
- Play for 2 minutes
- Verify win screen shows when time expires

---

## Step 7: Orb Hunt Mode

**Objective:** Implement Orb Hunt mode with target score from specific orbs.

**Implementation Guidance:**
1. Create `scripts/modes/orb_hunt_mode.gd`
2. Create `resources/modes/orb_hunt_mode.tres`
3. Add target orb types and target score to config

**Code Structure:**
```gdscript
# scripts/modes/orb_hunt_mode.gd
class_name OrbHuntMode extends ModeBase

var _target_score: int = 100  # Configurable via config
var _current_progress: int = 0
var _target_orb_names: Array[String] = []  # From config

func _on_start() -> void:
    _current_progress = 0
    # Load target score and orb names from config metadata

func _on_orb_collected(orb_data: OrbData, base_score: int) -> int:
    if orb_data.display_name in _target_orb_names:
        _current_progress += base_score
        if _current_progress >= _target_score:
            ModeManager.end_mode({"win": true, "reason": "target_reached"})
        return base_score
    return 0  # Non-target orbs give 0 points

func _check_win() -> bool:
    return _current_progress >= _target_score

func _get_metric() -> Dictionary:
    return {"name": "progress", "value": _current_progress, "max": _target_score}
```

**Test Requirements:**
- Unit test: `test_orb_hunt_mode.gd`
  - Test only target orbs contribute to progress
  - Test win triggers at target score
  - Test non-target orbs return 0 score
  - Test _get_metric returns progress %

**Integration:**
- ModeManager passes orb_data to _on_orb_collected

**Demo:**
- Select Orb Hunt mode
- Collect target orbs, see progress increase
- Reach target, verify win screen shows

---

## Step 8: Survival Mode

**Objective:** Implement Survival mode with wave progression.

**Implementation Guidance:**
1. Create `scripts/modes/survival_mode.gd`
2. Create `resources/modes/survival_mode.tres`
3. Implement wave tracking and difficulty scaling

**Code Structure:**
```gdscript
# scripts/modes/survival_mode.gd
class_name SurvivalMode extends ModeBase

var _current_wave: int = 1
var _orbs_collected_this_wave: int = 0
var _orbs_needed_per_wave: int = 5  # Base value

# Difficulty scaling
var _base_spawn_interval: float = 2.0
var _spawn_interval_decrease: float = 0.1
var _orbs_per_wave_increase: int = 2

func _on_start() -> void:
    _current_wave = 1
    _orbs_collected_this_wave = 0

func _on_orb_collected(_orb_data: OrbData, base_score: int) -> int:
    _orbs_collected_this_wave += 1
    if _orbs_collected_this_wave >= _get_orbs_needed():
        _advance_wave()
    return base_score

func _get_orbs_needed() -> int:
    return _orbs_per_wave_increase * (_current_wave - 1) + 5

func _get_spawn_interval() -> float:
    return max(0.5, _base_spawn_interval - _spawn_interval_decrease * (_current_wave - 1))

func _advance_wave() -> void:
    _current_wave += 1
    _orbs_collected_this_wave = 0
    ModeManager.metric_updated.emit("wave", _current_wave)

func _get_metric() -> Dictionary:
    return {"name": "wave", "value": _current_wave, "max": 0}

func _get_final_score() -> int:
    return _current_wave  # Score = waves survived
```

**Test Requirements:**
- Unit test: `test_survival_mode.gd`
  - Test wave starts at 1
  - Test _get_orbs_needed increases per wave
  - Test _get_spawn_interval decreases per wave
  - Test _advance_wave increments wave
  - Test final score is wave number

**Integration:**
- ModeManager calls _on_orb_collected
- OrbSpawner reads spawn interval from ModeManager

**Demo:**
- Select Survival mode
- Collect orbs, advance through waves
- Verify spawn rate increases each wave
- Drop ball, verify wave count shown as score

---

## Step 9: Mode-Specific Orb Pools

**Objective:** Enable modes to define which orbs spawn.

**Implementation Guidance:**
1. Modify `scripts/orb_spawner.gd` to check ModeManager for orb pool
2. If mode has custom orb_pool, use it instead of default
3. Update mode configs with appropriate orb pools

**Changes to orb_spawner.gd:**
```gdscript
func _spawn_from_props() -> Node:
    var pool_to_use: Array

    # Check if current mode has custom orb pool
    if ModeManager.current_mode != null and ModeManager.current_mode.orb_pool.size() > 0:
        pool_to_use = ModeManager.current_mode.orb_pool
        # Use OrbAdapter for OrbData items
        if pool_to_use.size() > 0:
            var idx := randi() % pool_to_use.size()
            return OrbAdapter.create_orb_from_data(generic_orb_scene, pool_to_use[idx])

    # Fall back to existing logic
    # ... existing code ...
```

**Mode-Specific Pools:**
- **Endless**: All orbs (current behavior)
- **Time Attack**: All orbs (current behavior)
- **Orb Hunt**: Target orbs + a few distractor orbs
- **Survival**: All orbs (current behavior)

**Test Requirements:**
- Integration test: `test_mode_orb_spawner.gd`
  - Test default pool when no mode
  - Test mode pool overrides default
  - Test fallback when mode pool empty

**Integration:**
- OrbSpawner reads from ModeManager.current_mode

**Demo:**
- Play Orb Hunt, verify only target + distractor orbs spawn
- Play other modes, verify all orbs spawn

---

## Step 10: High Score Persistence

**Objective:** Save and load high scores per mode.

**Implementation Guidance:**
1. Modify `scripts/utils/saved_game.gd` to add `mode_high_scores: Dictionary`
2. Modify `scripts/game_over_screen.gd` to use mode-specific high score
3. Add high score display in mode selection

**Changes to saved_game.gd:**
```gdscript
# Add to class
var mode_high_scores: Dictionary = {}  # {"endless": 1000, "time_attack": 500, ...}
```

**Changes to ModeManager:**
```gdscript
func get_high_score(mode_id: String) -> int:
    var saved := GameSaveMngr.get_saved_game()
    return saved.mode_high_scores.get(mode_id, 0)

func set_high_score(mode_id: String, score: int) -> void:
    var saved := GameSaveMngr.get_saved_game()
    if score > saved.mode_high_scores.get(mode_id, 0):
        saved.mode_high_scores[mode_id] = score
        GameSaveMngr.save_game()

func check_and_update_high_score() -> bool:
    if current_mode == null:
        return false
    var score := _mode_impl._get_final_score()
    var prev_high := get_high_score(current_mode.mode_id)
    if score > prev_high:
        set_high_score(current_mode.mode_id, score)
        return true
    return false
```

**Test Requirements:**
- Integration test: `test_mode_high_scores.gd`
  - Test get_high_score returns 0 for new mode
  - Test set_high_score saves correctly
  - Test check_and_update_high_score only updates when higher

**Integration:**
- Uses existing GameSaveMngr
- Called on mode end

**Demo:**
- Play a mode, set high score
- Return to mode selection, verify high score shown
- Close and reopen game, verify high score persisted

---

## Step 11: HUD Mode Display

**Objective:** Add mode badge and metric to HUD.

**Implementation Guidance:**
1. Modify `scenes/hud.tscn` to add mode badge and metric label
2. Modify `scripts/hud.gd` to connect to ModeManager signals
3. Update metric display based on mode

**Changes to hud.gd:**
```gdscript
extends CanvasLayer

@onready var mode_label: Label = $ModeLabel
@onready var metric_label: Label = $MetricLabel

func _ready() -> void:
    ModeManager.mode_started.connect(_on_mode_started)
    ModeManager.metric_updated.connect(_on_metric_updated)

func _on_mode_started(mode_id: String) -> void:
    var config := ModeManager.get_mode_config(mode_id)
    if config:
        mode_label.text = config.display_name

func _on_metric_updated(_metric_name: String, _value: Variant) -> void:
    _update_metric_display()

func _update_metric_display() -> void:
    if ModeManager.current_mode == null:
        return
    var metric := ModeManager._mode_impl._get_metric()
    match metric.name:
        "score":
            metric_label.text = "Score: %d" % metric.value
        "timer":
            var time := int(metric.value)
            metric_label.text = "%d:%02d" % [time / 60, time % 60]
        "wave":
            metric_label.text = "Wave %d" % metric.value
        "progress":
            var pct := int(float(metric.value) / float(metric.max) * 100)
            metric_label.text = "%d%%" % pct
```

**Test Requirements:**
- Unit test: `test_hud_mode_display.gd`
  - Test mode label updates on mode start
  - Test metric formats correctly for each type

**Integration:**
- Connected to ModeManager signals

**Demo:**
- Play each mode, verify correct metric displays
- Time Attack shows countdown timer
- Survival shows wave number
- Orb Hunt shows progress %

---

## Step 12: Final Integration and Polish

**Objective:** Ensure all components work together correctly.

**Implementation Guidance:**
1. Run full test suite and fix any failures
2. Update `scripts/utils/enums.gd` with any new enums needed
3. Ensure all mode .tres files are properly configured
4. Add mode icons (placeholder art acceptable)
5. Verify smoke test passes

**Final Checklist:**
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] ./devscripts/test.sh exits 0
- [ ] ./devscripts/smoke_test.sh exits 0
- [ ] Manual test: All 4 modes playable
- [ ] Manual test: High scores persist
- [ ] Manual test: Mode selection works

**Test Requirements:**
- Full test suite run
- Manual verification of each mode

**Integration:**
- Complete system integration

**Demo:**
- Full playthrough of all modes
- Verify all features work end-to-end

---

## Implementation Order Rationale

1. **Foundation first** (Steps 1-3): Data structures and core manager before UI
2. **Integration early** (Step 4): Connect to game flow before adding more modes
3. **UI for testing** (Step 5): Mode selection enables manual testing of new modes
4. **Mode implementations** (Steps 6-8): One at a time, each fully tested
5. **Advanced features** (Steps 9-11): Orb pools and HUD after core works
6. **Polish last** (Step 12): Final integration when all pieces exist

## Risk Mitigation During Implementation

| Risk | Mitigation Step |
|------|-----------------|
| Breaking existing game | Step 4 includes extensive integration tests |
| Mode conflicts | Each mode is isolated in Step 6-8 |
| Save corruption | Step 10 handles missing keys gracefully |
| Performance | Mode checks are simple, tested in Step 12 |
