# Broken Windows - Orb Content Pack

Low-risk code smells identified in files that will be touched during implementation.

---

## [scripts/ball.gd:9] Missing type annotation

**Type:** typing
**Risk:** Low
**Fix:** Add type annotation to game_over variable

```gdscript
// current
var game_over : bool = false

// fixed
var game_over: bool = false
```

---

## [scripts/ball.gd:16] Empty pass statement

**Type:** dead-code
**Risk:** Low
**Fix:** Remove unnecessary pass statement

```gdscript
// current
func _ready() -> void:
    add_to_group("ball")
    load_constants()
    pass # Replace with function body.

// fixed
func _ready() -> void:
    add_to_group("ball")
    load_constants()
```

---

## [scripts/ball.gd:21] Empty _process function

**Type:** dead-code
**Risk:** Low
**Fix:** Remove empty _process if not needed

```gdscript
// current
func _process(delta: float) -> void:
    pass

// fixed (remove entirely if unused)
```

---

## [scripts/physics_player.gd:54-58] Empty pass statement

**Type:** dead-code
**Risk:** Low
**Fix:** Remove unnecessary pass statement in _ready()

---

## [scripts/physics_player.gd:57] Missing player group

**Type:** missing-feature
**Risk:** Low (but CRITICAL for sticky head)
**Fix:** Add player to "player" group in _ready()

```gdscript
func _ready() -> void:
    add_to_group("player")  # ADD THIS LINE
    load_constants()
    apply_constants()
    ...
```

---

## [scripts/blue_orb.gd:9] Missing type annotation

**Type:** typing
**Risk:** Low
**Fix:** Add type annotation

```gdscript
// current
var _props : OrbProps = null

// fixed
var _props: OrbProps = null
```

---

## [scripts/orb_spawner.gd:50-52] Hardcoded scene reference

**Type:** coupling
**Risk:** Low
**Fix:** Not a blocker - current design is intentional for existing system

---

## Summary

| File | Issues | Priority |
|------|--------|----------|
| ball.gd | 3 minor | Low |
| physics_player.gd | 2 (1 critical) | High - player group needed |
| blue_orb.gd | 1 minor | Low |

**Critical Fix Required:**
- `physics_player.gd:54` - Must add `add_to_group("player")` for sticky head collision detection
