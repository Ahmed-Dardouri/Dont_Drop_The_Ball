# Game Mode System - Broken Windows (Code Smells)

Low-risk improvement opportunities in files that will be touched during implementation.

---

## 1. [scripts/utils/saved_game.gd:4-6] Inconsistent Naming Convention

**Type**: naming
**Risk**: Low
**Fix**: Change `Sfx_volume` and `Music_volume` to snake_case to match GDScript conventions

**Code**:
```gdscript
# Current (inconsistent)
@export var Sfx_volume: int
@export var Music_volume: int

# Should be
@export var sfx_volume: int
@export var music_volume: int
```

**Note**: This is a breaking change for existing saves. Defer unless save migration is already planned.

---

## 2. [scripts/game_over_screen.gd:29-30] Uses Variables singleton instead of ScoreManager

**Type**: duplication
**Risk**: Low
**Fix**: Use `ScoreManager.get_score()` instead of `Variables.current_score`

**Code**:
```gdscript
# Current
func get_current_score() -> int :
	return Variables.current_score

# Should be
func get_current_score() -> int:
	return ScoreManager.get_score()
```

**Note**: There's inconsistency in the codebase - `Variables.current_score` and `ScoreManager` both track score. Mode system should use ScoreManager consistently.

---

## 3. [scripts/utils/variables.gd:1-6] Redundant Singleton

**Type**: duplication
**Risk**: Medium (requires audit of all usages)
**Fix**: Consider deprecating `Variables` in favor of `ScoreManager`

**Code**:
```gdscript
# Current - variables.gd
extends Node
var current_score: int = 0

# ScoreManager already has this
func get_score() -> int:
	return _current_score
```

**Note**: This is a larger refactor. Document but don't fix as part of mode system work.

---

## 4. [scripts/ball.gd:15-16] Empty _ready() body with pass comment

**Type**: dead-code
**Risk**: Low
**Fix**: Remove the pass statement and comment

**Code**:
```gdscript
# Current
func _ready() -> void:
	add_to_group("ball")
	load_constants()
	pass # Replace with function body.

# Should be
func _ready() -> void:
	add_to_group("ball")
	load_constants()
```

---

## 5. [scripts/hud.gd:10-12] Commented-out debug code

**Type**: dead-code
**Risk**: Low
**Fix**: Remove commented debug code

**Code**:
```gdscript
# Current
#func _process(delta: float) -> void:
#	print(button_controls.visible)

# Should be - remove entirely
```

---

## 6. [scripts/main_menu.gd:5-6] Empty _ready() with pass comment

**Type**: dead-code
**Risk**: Low
**Fix**: Remove unnecessary pass comment

**Code**:
```gdscript
# Current
func _ready() -> void:
	pass # Replace with function body.

# Should be - remove if empty or keep minimal
func _ready() -> void:
	pass
```

---

## 7. [scripts/utils/game_save_mngr.gd:28-30] Unused initialization function

**Type**: dead-code
**Risk**: Low
**Fix**: `_init_saved_game()` sets pb=0 but this is overwritten by load_game()

**Code**:
```gdscript
# Current - this function's work is immediately overwritten
func _init_saved_game():
	_saved_game.pb = 0

# Consider: Remove if load_game() always overwrites
```

---

## 8. [scripts/world_builder.gd:77-81] Magic numbers for frame delays

**Type**: magic-values
**Risk**: Low
**Fix**: Extract to named constant

**Code**:
```gdscript
# Current
func back_button_handle():
	# ...
	#wait for _input to run
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame

# Could be
const INPUT_PROCESS_FRAMES := 2

# But this is minor - defer
```

---

## Summary

| Priority | File | Issue | Action |
|----------|------|-------|--------|
| Defer | `saved_game.gd` | Naming convention | Breaking change |
| Fix if touching | `game_over_screen.gd` | Use ScoreManager | Low effort |
| Document only | `variables.gd` | Redundant singleton | Out of scope |
| Fix if touching | `ball.gd` | Dead code comment | Trivial |
| Fix if touching | `hud.gd` | Commented code | Trivial |
| Fix if touching | `main_menu.gd` | Dead code comment | Trivial |
| Document only | `game_save_mngr.gd` | Unused init | Out of scope |
| Document only | `world_builder.gd` | Magic numbers | Minor |

**Recommendation**: Fix items 4, 5, 6 when touching those files. Item 2 (ScoreManager consistency) is important for mode system - standardize on ScoreManager.
