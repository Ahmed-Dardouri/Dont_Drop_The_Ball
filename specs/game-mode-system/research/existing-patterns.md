# Game Mode System - Existing Patterns Research

## 1. Singleton Pattern

### Source: `scripts/core/game_state.gd:1-35`
```gdscript
extends Node
## Centralized game state management with signal-based notifications.

signal pause_changed(is_paused: bool)
signal mode_changed(new_mode: Enums.GameMode)

var is_paused: bool = false:
	set(value):
		if is_paused != value:
			is_paused = value
			pause_changed.emit(is_paused)

func reset() -> void:
	is_paused = false
	current_mode = Enums.GameMode.MENU
```

**Pattern Notes:**
- Singletons extend `Node`
- Use signal-based notifications for state changes
- Setter pattern with change detection (only emit when value changes)
- `reset()` function to restore defaults

### Source: `scripts/core/score_manager.gd:1-51`
```gdscript
extends Node
## Score tracking with signal-based UI updates.

signal score_changed(new_score: int)
signal high_score_changed(new_high: int)

var _current_score: int = 0
var _high_score: int = 0

func add_score(amount: int) -> int:
	_current_score += amount
	score_changed.emit(_current_score)
	if _current_score > _high_score:
		_high_score = _current_score
		high_score_changed.emit(_high_score)
	return _current_score
```

**Pattern Notes:**
- Private variables with public getter functions
- Emit signals on state changes
- High score logic built-in

---

## 2. Resource Pattern

### Source: `scripts/data/orb_data.gd:1-57`
```gdscript
class_name OrbData extends Resource
## Data resource defining all orb properties for the data-driven orb system.

#region Display Properties
@export var display_name: String = "Orb"
@export var texture: Texture2D
@export var scale: Vector2 = Vector2.ONE
#endregion

#region Gameplay Properties
@export var base_score: int = 1
@export var lifespan: float = 30.0
@export var rarity: Enums.OrbRarity = Enums.OrbRarity.COMMON
#endregion

#region Behaviors
@export var behaviors: Array[OrbBehavior] = []
#endregion
```

**Pattern Notes:**
- `class_name` for type registration
- `@export` for editor configuration
- Region comments for organization
- Arrays of typed resources (behaviors)

### Source: `scripts/utils/saved_game.gd:1-7`
```gdscript
class_name SavedGame
extends Resource

@export var pb: int
@export var Sfx_volume: int
@export var Music_volume: int
```

**Pattern Notes:**
- Simple Resource with @export vars for persistence
- Used by `GameSaveMngr` for save/load

---

## 3. Event System Pattern

### Source: `addons/dynamic_event_manager/src/Event.gd:16`
```gdscript
class_name Event extends RefCounted
```

### Source: `scripts/events/game_over_event.gd:1-5`
```gdscript
class_name GameOverEvent extends Event

static func invoke():
	if PauseEvent.state == false:
		Events.invoke(GameOverEvent.new())
```

### Source: `scripts/events/orb_collected_event.gd:1-11`
```gdscript
class_name OrbCollectedEvent extends Event

var _props: OrbProps

func _init(props: OrbProps) -> void:
	_props = props

static func invoke(props : OrbProps):
	if PauseEvent.state == false:
		Events.invoke(OrbCollectedEvent.new(props))
```

**Pattern Notes:**
- Events extend `Event` (which extends `RefCounted`)
- Static `invoke()` method for easy invocation
- Optional payload via `_init()` constructor
- Pause check in `invoke()` is common pattern

### Source: `scripts/game_over_screen.gd:7-8`
```gdscript
func _ready() -> void:
	Events.add_listener(GameOverEvent, handle_game_over)
```

**Pattern Notes:**
- Use `Events.add_listener(EventClass, callback)` to subscribe
- Callback receives event instance

---

## 4. Orb Spawning Pattern

### Source: `scripts/orb_spawner.gd:1-75`
```gdscript
class_name OrbSpawner
extends Node2D

@export var generic_orb_scene: PackedScene
@export var orb_data_array: Array[OrbData] = []
@export var spawn_interval: float = 2.0
@export var max_orbs: int = 10

func _spawn_from_props() -> Node:
	# Check for mode override (integration point)
	var pool_size := orb_props.size() + orb_data_array.size()
	if pool_size == 0:
		return null

	var idx := randi() % pool_size
	# First part of pool is OrbProps, second is OrbData
	if idx < orb_props.size():
		return create_orb_copy(orb_props[idx])

	var data_idx := idx - orb_props.size()
	return OrbAdapter.create_orb_from_data(generic_orb_scene, orb_data_array[data_idx])
```

**Integration Point for Mode-Specific Pools:**
- `orb_data_array` can be overridden by ModeManager
- Already supports Array[OrbData] which matches ModeConfig.orb_pool type

---

## 5. World Builder / Scene Management

### Source: `scripts/world_builder.gd:1-93`
```gdscript
extends Node2D

var _current_scene : Enums.WorldScene = Enums.WorldScene.GAME

func _ready() -> void:
	_add_events()
	WorldBuiltEvent.invoke()
	switch_scene(Enums.WorldScene.GAME)

func switch_scene(scene: Enums.WorldScene):
	_current_scene = scene
	hide_scenes()
	match _current_scene:
		Enums.WorldScene.GAME:
			PauseEvent.invoke(false)
		Enums.WorldScene.GAME_OVER_SCREEN:
			game_over_screen.visible = true

func replay_button_handle():
	switch_scene(Enums.WorldScene.GAME)
	ReplayEvent.invoke()
```

**Integration Points:**
- `load_world()` - called when game starts (mode initialization)
- `replay_button_handle()` - calls `ReplayEvent.invoke()` (mode restart)

---

## 6. Game Over Flow

### Source: `scripts/ball.gd:49-54`
```gdscript
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground") && !game_over:
		game_over = true
		GameOverEvent.invoke()
		PauseEvent.invoke(true)
		SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)
```

**Integration Point:**
- ModeManager should listen to `GameOverEvent`
- Mode can check `_check_lose()` when game over occurs

### Source: `scripts/game_over_screen.gd:11-19`
```gdscript
func handle_game_over(event: GameOverEvent) -> void:
	var saved_game := GameSaveMngr.get_saved_game()
	var curr_score = get_current_score()
	saved_game.pb = max(curr_score, saved_game.pb)
	GameSaveMngr.set_saved_game(saved_game)
	GameSaveMngr.save_game()
	visible = true
	replay_btn.grab_focus()
```

**Integration Points:**
- High score logic currently handles single "pb" (personal best)
- Needs extension for mode-specific high scores

---

## 7. Save System Pattern

### Source: `scripts/utils/game_save_mngr.gd:1-30`
```gdscript
extends Node

const _SAVED_GAME_PATH := "user://savegame.tres"
var _saved_game : SavedGame = SavedGame.new()

func load_game():
	if ResourceLoader.exists(_SAVED_GAME_PATH):
		_saved_game = load(_SAVED_GAME_PATH)
	else:
		save_game()
	GameLoadEvent.invoke(_saved_game)

func save_game():
	ResourceSaver.save(_saved_game, _SAVED_GAME_PATH)

func get_saved_game() -> SavedGame:
	return _saved_game
```

**Pattern Notes:**
- ResourceSaver for persistence
- `get_saved_game()` returns mutable reference
- `save_game()` persists to disk

---

## 8. Enums Structure

### Source: `scripts/utils/enums.gd:1-71`
```gdscript
class_name Enums extends Node

enum GameMode {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

enum MainButtonType {
	PLAY,
	SETTINGS,
	BACK,
	EXIT,
}

enum MainScene {
	WORLD_BUILDER,
	MAIN_MENU,
	SETTINGS_MENU,
	TUTORIAL
}

enum WorldScene {
	GAME,
	PAUSE_SCREEN,
	GAME_OVER_SCREEN
}
```

**Integration Points:**
- `GameMode` enum is for game STATE (menu/playing/paused) - NOT game play modes
- Need new enum `PlayMode` for endless/time_attack/orb_hunt/survival
- Need new `MainButtonType.SELECT_MODE` for mode selection button

---

## 9. Test Pattern

### Source: `tests/unit/test_game_state.gd:1-130`
```gdscript
extends GutTest

var _pause_changed_count: int = 0

func before_each() -> void:
	_pause_changed_count = 0
	GameState.reset()

func after_each() -> void:
	if GameState.pause_changed.is_connected(_on_pause_changed):
		GameState.pause_changed.disconnect(_on_pause_changed)

func test_initial_state_is_paused_false() -> void:
	assert_false(GameState.is_paused, "Initial is_paused should be false")
```

**Pattern Notes:**
- `extends GutTest`
- `before_each()` for setup, `after_each()` for cleanup
- Disconnect signals in `after_each()` to prevent accumulation
- Descriptive assertion messages

---

## 10. Project Autoloads

### Source: `project.godot:18-27`
```
[autoload]
Events="*res://addons/dynamic_event_manager/src/event_manager.gd"
Constants="*res://scripts/utils/Constants.gd"
GameSaveMngr="*res://scripts/utils/game_save_mngr.gd"
Variables="*res://scripts/utils/variables.gd"
GameState="*res://scripts/core/game_state.gd"
ScoreManager="*res://scripts/core/score_manager.gd"
EffectManager="*res://scripts/effect_manager.gd"
```

**ModeManager Integration:**
- Will need to add: `ModeManager="*res://scripts/core/mode_manager.gd"`
- Must be registered as autoload for global access

---

## Key Findings Summary

| Pattern | Source File | Relevance to Mode System |
|---------|-------------|--------------------------|
| Singleton with signals | `game_state.gd`, `score_manager.gd` | ModeManager pattern |
| Resource config | `orb_data.gd`, `saved_game.gd` | ModeConfig pattern |
| Event system | `events/*.gd` | Mode events (mode_started, mode_ended) |
| Orb spawning | `orb_spawner.gd` | Mode-specific orb pools |
| Scene management | `world_builder.gd` | Mode lifecycle integration |
| Save/load | `game_save_mngr.gd` | High score persistence |
