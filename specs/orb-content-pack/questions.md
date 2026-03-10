# Orb Content Pack - Clarification Questions

## Question 1 (2026-03-10)

**Context:** Implementing 8 new orb types. Most types are straightforward, but the **Sticky Head Orb** directly interacts with the core bounce mechanic and requires clarification.

**Question:** For the Sticky Head Orb behavior - what exactly should "stick briefly to the player's head" mean in practice?

**Options I'm considering:**
1. **Pause-and-release**: Ball velocity becomes zero on contact, then after X seconds it bounces with stored velocity
2. **Damping-zone**: Ball's vertical velocity is heavily dampened while near player's head area, then gradually released
3. **Anchor-point**: Ball attaches to a specific point on the player sprite for X seconds, then detaches with bounce

**Why this matters:** Each option has different implications for:
- Player control feel (option 1 = pause, option 2 = floaty, option 3 = anchored)
- Code complexity (option 3 requires modifying ball physics more)
- Core bounce mechanic preservation (option 2 is least disruptive)

**Additional clarification needed:**
- What duration range is "briefly"? (0.1s? 0.5s? 1.0s?)
- Should the player be able to influence the ball's direction while it's "stuck"?
- Should this override the normal bounce behavior entirely or modify it?

---

## Answer 1 (2026-03-10)

**Architect Answer:**

**Recommended Approach: Option 2 - Damping-zone**

After analyzing the codebase:
- Ball is a RigidBody2D relying on Godot's physics engine for collision response
- No explicit "head bounce" code exists - bounces happen naturally via physics
- EffectManager already handles `slow_fall` and `time_slow` which modify physics behavior

**Implementation Details:**

| Property | Value | Rationale |
|----------|-------|-----------|
| Behavior Type | Damping-zone | Least disruptive to existing physics, integrates cleanly with EffectManager |
| Duration | 0.3-0.5 seconds | "Briefly" - enough to feel control improvement without being annoying |
| Effect ID | `sticky_head` | New effect type in EffectManager |
| Mechanism | Reduces ball's vertical velocity by configurable factor (e.g., 0.3x) when ball is near player head collision area | Preserves core bounce, just dampens it |
| Player Direction Influence | NO | Too complex, would require modifying ball physics significantly |
| Override Normal Bounce | NO | Dampens but doesn't replace the physics response |

**Why this choice:**
- Option 1 (pause-and-release) feels glitchy and requires pausing physics
- Option 3 (anchor-point) is too disruptive to RigidBody2D physics
- Option 2 integrates cleanly with existing EffectManager pattern and preserves the "feel" of the bounce

**Effect stacking:** Not applicable - single instance, refresh duration on re-pickup

---

## Question 2 (2026-03-10)

**Context:** Implementing the **Drifter Orb** - the only orb with a movement behavior that needs specification.

**Question:** What movement pattern should the Drifter Orb use?

**Options I'm considering:**
1. **Horizontal drift**: Moves left-right in a sine wave pattern (simplest, most readable)
2. **Vertical bounce**: Bounces up and down in place (predictable, easy to target)
3. **Circular orbit**: Moves in a small circle around spawn point (visually interesting, medium complexity)
4. **Diagonal sweep**: Moves diagonally across screen (challenging to catch, adds tension)

**Why this matters:**
- Different patterns create different gameplay experiences
- Affects how players need to time their bounces
- Horizontal drift is simplest to implement and most readable
- Diagonal/circular patterns add visual variety but increase complexity

**Additional clarification:**
- Should speed be slow enough that it's always catchable?
- Should it stay within screen bounds or wrap around?

---

## Answer 2 (2026-03-10)

**Architect Answer:**

**Recommended Approach: Horizontal Drift (Option 1)**

After analyzing the codebase:
- Game is a "keep the ball up" vertical physics game
- Orbs spawn in configurable zone: `Rect2(Vector2(-200, -200), Vector2(400, 400))`
- OrbBehavior has `process(_orb, _delta)` method for per-frame logic

**Implementation Details:**

| Property | Value | Rationale |
|----------|-------|-----------|
| Pattern | Horizontal oscillation | Most readable, least disruptive |
| Movement | Sine wave (`sin(time * speed) * amplitude`) | Smooth, predictable |
| Amplitude | 50-100 pixels (configurable) | Visible movement without leaving spawn zone |
| Speed | 1-2 cycles/second (configurable) | Readable but dynamic |

**Why NOT other options:**
- Vertical: Conflicts with vertical ball gameplay, harder to distinguish from falling
- Circular: Too complex, unpredictable trajectory
- Diagonal: Tendency to drift outside play area, harder to tune for spawn zones

**Implementation:**
- Use OrbBehavior `process()` method
- Store initial X position on spawn
- Apply sine-based horizontal offset each frame
- Configurable via export vars in DrifterBehavior resource

---

## Question 3 (2026-03-10)

**Context:** Implementing the **Vertical Line Orb** and **Horizontal Line Orb** - both clear orbs in a "line" but the line definition is ambiguous.

**Question:** What exactly defines the "line" for these orbs?

**Options I'm considering:**
1. **Full-screen sweep**: Clears ALL orbs sharing the same X (vertical) or Y (horizontal) coordinate, regardless of distance
2. **Limited range**: Clears orbs within a configurable distance (e.g., 200 pixels) from the trigger orb in that direction
3. **Raycast-based**: Uses physics raycast to find orbs in a line, potentially stopping at first obstacle

**Why this matters:**
- Full-screen sweep is most powerful/dramatic but could clear many orbs at once
- Limited range is more balanced but needs a clear default (100px? 300px?)
- Raycast-based is more "realistic" but adds collision complexity

**Additional clarification:**
- Should cleared orbs have any visual effect (flash, chain reaction animation)?
- Should there be a limit on how many orbs can be cleared per line?
- Should the line orb itself be consumed (collected) as part of the effect?

---

## Answer 3 (2026-03-10)

**Architect Answer:**

**Recommended Approach: Full-screen Sweep with Tolerance (Option 1)**

After analyzing the codebase:
- Game resolution is 1920x1080
- Orbs use group "orbs" for scene tree queries
- Existing task-13 design already specifies this exact approach with `tolerance: float = 20.0`

**Implementation Details:**

| Property | Value | Rationale |
|----------|-------|-----------|
| Line Definition | Coordinate tolerance matching | Simplest implementation |
| Tolerance | 20 pixels (configurable) | Forgiving alignment without being too generous |
| Range | Full scene | Maximum dramatic effect, simplest code |
| Max Orbs | No limit | Let it clear all matching orbs |

**Additional Clarifications:**

| Question | Answer | Rationale |
|----------|--------|-----------|
| Visual effect for cleared orbs? | NO (for MVP) | Keep implementation simple; can add VFX later |
| Max orbs cleared per line? | NO limit | Full-screen sweep is the power fantasy |
| Line orb itself consumed? | YES | Standard collection behavior applies |

**Matching Logic:**
- **Vertical Line**: Clear orbs where `abs(orb.x - source.x) < tolerance`
- **Horizontal Line**: Clear orbs where `abs(orb.y - source.y) < tolerance`

**Why NOT limited range:**
- Adds extra configuration parameter
- Creates unclear visual feedback (where does line end?)
- Less dramatic/satisfying

**Why NOT raycast-based:**
- Orbs aren't physical obstacles requiring raycast logic
- Unnecessary collision complexity
- No gameplay benefit over tolerance matching

---

## Question 4 (2026-03-10)

**Context:** Design review of **Sticky Head Orb** implementation found a critical issue. The proposed approach applies 0.3x damping every frame for 0.4 seconds, which mathematically results in `velocity * (0.3)^24 ≈ 0` - the ball stops instantly instead of "briefly sticking."

**Question:** When the ball "sticks" to the player's head, what should the player actually experience?

**Options I'm considering:**
1. **Collision dampening**: Ball bounces off player with reduced vertical velocity (e.g., 50% of normal bounce height), making timing easier. Applies only on player collision, not every frame.
2. **Gravity reduction**: Ball's gravity is temporarily reduced while effect is active, making it fall slower overall and giving more reaction time. Applies every frame but doesn't compound.
3. **Brief pause on collision**: Ball pauses for ~0.2 seconds when it collides with player, then bounces with normal velocity. Applies only on collision.

**Why this matters:**
- Option 1 modifies the bounce itself (feels like "softer bounces")
- Option 2 modifies global ball behavior (feels like "slow fall" but different)
- Option 3 creates a distinct "stick" moment (most like true sticky behavior)

**Original requirement said:** "Temporarily makes the ball 'stick' very briefly to the player's head before bouncing away"

**Additional clarification:**
- Should the effect last for multiple bounces or just one?
- Should horizontal velocity be affected at all?
