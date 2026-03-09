# Broken Windows (Code Smells)

Low-risk improvement opportunities in files that will be touched during the refactor.

---

## [scripts/ball.gd:49] Hardcoded Ground Name Check

**Type**: magic-values
**Risk**: Low
**Fix**: Replace with group check `body.is_in_group("ground")`
**Code**:
```gdscript
if body.name == "ground_static" && !game_over:
```

---

## [scripts/ball.gd:54] Hardcoded Half-Solid Name Check

**Type**: magic-values
**Risk**: Low
**Fix**: Replace with group check or type check `body is HalfSolidOrb`
**Code**:
```gdscript
elif body.name == "half_static":
```

---

## [scripts/blue_orb.gd:25] Hardcoded Ball Name Check

**Type**: magic-values
**Risk**: Low
**Fix**: Replace with group check `body.is_in_group("ball")`
**Code**:
```gdscript
if body.name == "ball":
```

---

## [scripts/red_orb.gd:24] Hardcoded Ball Name Check

**Type**: magic-values
**Risk**: Low
**Fix**: Replace with group check `body.is_in_group("ball")`
**Code**:
```gdscript
if body.name == "ball":
```

---

## [scripts/half_solid_orb.gd:48] Hardcoded Ball Name Check

**Type**: magic-values
**Risk**: Low
**Fix**: Replace with group check `body.is_in_group("ball")`
**Code**:
```gdscript
if body.name == "ball":
```

---

## [scripts/physics_player.gd:18] Inconsistent Variable Naming

**Type**: naming
**Risk**: Low
**Fix**: Rename to `jump_ended_early_gravity_modifier` (snake_case)
**Code**:
```gdscript
var Jump_ended_early_gravity_modifier : float = 0
```

---

## [scripts/physics_player.gd:35-36] Inconsistent Private Variable Naming

**Type**: naming
**Risk**: Low
**Fix**: Consistent snake_case: `_jump_held`, `_jump_held_prev`
**Code**:
```gdscript
var _JumpHeld : bool = false
var _JumpHeldPrev : bool = false
```

---

## [scripts/main.gd:38-45] Repetitive Await Pattern

**Type**: complexity
**Risk**: Low (already working, but could be cleaner)
**Fix**: Use a loop: `for i in range(8): await Engine.get_main_loop().process_frame`
**Code**:
```gdscript
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
await Engine.get_main_loop().process_frame
```

---

## [scripts/score_mngr.gd:17-18] Empty _process Function

**Type**: dead-code
**Risk**: Low
**Fix**: Remove unused `_process` function
**Code**:
```gdscript
func _process(delta: float) -> void:
    pass
```

---

## [scripts/ground.gd:9-11] Empty _process Function

**Type**: dead-code
**Risk**: Low
**Fix**: Remove unused `_process` function
**Code**:
```gdscript
func _process(delta: float) -> void:
    pass
```

---

## Summary

| Type | Count | Files Affected |
|------|-------|----------------|
| magic-values | 5 | ball.gd, blue_orb.gd, red_orb.gd, half_solid_orb.gd |
| naming | 2 | physics_player.gd |
| complexity | 1 | main.gd |
| dead-code | 2 | score_mngr.gd, ground.gd |

**Total**: 10 broken windows identified

---

## Recommendation

The magic-values issues (hardcoded name checks) will be resolved as part of the collision system migration to groups (Step 17 in plan). The naming inconsistencies are cosmetic and can be addressed during the physics extraction refactor (Steps 5-6).
