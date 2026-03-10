# Broken Windows - Orb System Expansion

Low-risk code smells identified in files that will be touched during implementation.

---

## scripts/blue_orb.gd

### [line 24-25] Body name string comparison
**Type:** magic-values
**Risk:** Low
**Fix:** Use `body.is_in_group("ball")` instead of `body.name == "ball"`
**Code:**
```gdscript
func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```
**Note:** Same issue exists in `red_orb.gd:24-25` and `half_solid_orb.gd:47-49`

---

## scripts/red_orb.gd

### [line 24-25] Body name string comparison
**Type:** magic-values
**Risk:** Low
**Fix:** Use `body.is_in_group("ball")` instead of `body.name == "ball"`
**Code:**
```gdscript
func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```

---

## scripts/half_solid_orb.gd

### [line 47-49] Body name string comparison
**Type:** magic-values
**Risk:** Low
**Fix:** Use `body.is_in_group("ball")` instead of `body.name == "ball"`
**Code:**
```gdscript
func _on_collect_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```

---

## scripts/generic_orb.gd

### [line 24] Missing newline after function
**Type:** formatting
**Risk:** Low
**Fix:** Add blank line between `_ready()` and `_process()`
**Code:**
```gdscript
func _ready() -> void:
    update_orb()
    init_timer()
    disable_child_orb()
func _process(delta: float) -> void:  # No blank line
```

### [line 27-36] Match without default handling
**Type:** complexity
**Risk:** Low
**Fix:** Already has `_:` case returning null - acceptable

---

## scripts/orb_spawner.gd

### [line 4] Hardcoded spawn zone
**Type:** magic-values
**Risk:** Low (already configurable via export)
**Fix:** No fix needed - @export with default is appropriate

---

## scripts/ball.gd

### [line 16] Empty pass statement
**Type:** dead-code
**Risk:** Low
**Fix:** Remove `pass # Replace with function body.` comment
**Code:**
```gdscript
func _ready() -> void:
    add_to_group("ball")
    load_constants()
    pass # Replace with function body.
```

### [line 21] Empty _process function
**Type:** dead-code
**Risk:** Low
**Fix:** Remove empty `_process()` function if not needed
**Code:**
```gdscript
func _process(delta: float) -> void:
    pass
```

### [line 64-66] Empty apply_constants function
**Type:** dead-code
**Risk:** Low
**Fix:** Remove unused `apply_constants()` function
**Code:**
```gdscript
func apply_constants():
    pass
```

---

## scripts/utils/Constants.gd

### [line 1] Missing class_name
**Type:** naming
**Risk:** Low (autoload makes it globally accessible)
**Fix:** Consider adding `class_name Constants extends Node` for consistency
**Note:** Works fine without it due to autoload registration

---

## scripts/orb_mngr.gd

### [line 10-11] Empty _process function
**Type:** dead-code
**Risk:** Low
**Fix:** Remove empty `_process()` function if not needed
**Code:**
```gdscript
func _process(delta: float) -> void:
    pass
```

---

## Summary

| File | Issues | Types |
|------|--------|-------|
| blue_orb.gd | 1 | magic-values |
| red_orb.gd | 1 | magic-values |
| half_solid_orb.gd | 1 | magic-values |
| generic_orb.gd | 1 | formatting |
| ball.gd | 3 | dead-code |
| orb_mngr.gd | 1 | dead-code |

**Total:** 8 low-risk issues

**Recommendation:** These files will be deleted or significantly modified during migration. Fix only if touching the code anyway - do not make dedicated passes to fix these.
