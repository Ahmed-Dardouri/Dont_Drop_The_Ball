# Scratchpad - Orb Content Pack Implementation

## 2026-03-10 - Architect Answer: Sticky Head Orb Clarification

### Research Summary

**Codebase Analysis:**
1. Ball (`ball.gd`) is a RigidBody2D with velocity clamping and air friction
2. Player (`physics_player.gd`) is a RigidBody2D with jump/movement logic
3. Bounce mechanic relies on Godot's physics engine - no explicit "head bounce" code
4. EffectManager already supports: `slow_fall`, `time_slow`, `score_multiplier`, `combo_chain`, `double_value`
5. Core constraint: "Keep player bouncing mechanic unchanged"

**Options Analysis:**
1. **Pause-and-release**: Would require storing velocity, pausing physics, then releasing - complex and feels "glitchy"
2. **Damping-zone**: Reduces ball's vertical velocity near player head - least disruptive, integrates well with existing EffectManager
3. **Anchor-point**: Would require ball to become child of player or use position locking - most disruptive to physics

### Answer Summary
Recommend Option 2 (Damping-zone) with:
- Duration: 0.3-0.5 seconds (configurable)
- No player direction influence
- Implemented as new effect "sticky_head" in EffectManager
- Uses velocity dampening factor when ball is in detection zone near player

---

## 2026-03-10 - Architect Answer: Drifter Orb Movement Pattern

### Question
Q2: Drifter Orb movement pattern - horizontal drift vs vertical bounce vs circular vs diagonal?

### Research Summary

**Codebase Analysis:**
1. Game is a "keep the ball up" vertical physics game
2. Camera at (960, 540) suggests 1920x1080 resolution
3. Orbs spawn in configurable zone: `Rect2(Vector2(-200, -200), Vector2(400, 400))`
4. OrbBehavior has `process(_orb, _delta)` method for per-frame logic
5. Ball physics is RigidBody2D with vertical gravity focus

**Options Analysis:**

| Pattern | Pros | Cons | Complexity |
|---------|------|------|------------|
| Horizontal drift | Simple, predictable, stays in view, doesn't interfere with vertical gameplay | None significant | Low |
| Vertical bounce | Familiar to game theme | Confuses player tracking of falling ball vs moving orb, could overlap with ball trajectory | Medium |
| Circular | Visually interesting | Complex implementation, unpredictable for players, might drift off-screen | High |
| Diagonal | Dynamic movement | Could drift off-screen, interferes with spawn zone boundaries, harder to collect | Medium-High |

### Recommendation: Horizontal Drift

**Properties:**
| Property | Value | Rationale |
|----------|-------|-----------|
| Pattern | Horizontal oscillation | Most readable, least disruptive |
| Movement | Sine wave (`sin(time * speed) * amplitude`) | Smooth, predictable |
| Amplitude | 50-100 pixels (configurable) | Visible movement without leaving spawn zone |
| Speed | 1-2 cycles/second (configurable) | Readable but dynamic |

**Implementation:**
- Use OrbBehavior `process()` method
- Store initial X position on spawn
- Apply sine-based horizontal offset each frame
- Configurable via export vars in DrifterBehavior resource

**Why NOT others:**
- Vertical: Conflicts with vertical ball gameplay, harder to distinguish from falling
- Circular: Too complex, unpredictable trajectory
- Diagonal: Tendency to drift outside play area, harder to tune for spawn zones

---

## 2026-03-10 - Inquisitor: Q2 Accepted, Q3 Asked

### Pending Event Handled
- `answer.proposed` for Q2 (Drifter Orb movement) - **ACCEPTED**
- Answer was comprehensive and already captured in requirements.md as REQ-2

### Gap Analysis
Reviewed remaining orb types for critical ambiguities:
- **Burst Orb**: Radius definition needed but secondary to line orb question
- **Line Orbs**: "Line through position" is fundamental ambiguity - full screen vs limited range?
- **Slow Fall / Double Value / Combo Starter**: Already exist in EffectManager per scratchpad research

### Q3 Asked: Line Orb Definition
Asked about what defines the "line" for Vertical/Horizontal Line Orbs:
1. Full-screen sweep (all orbs with same X/Y)
2. Limited range (configurable distance, e.g., 200px)
3. Raycast-based (physics-based line)

Additional clarifications:
- Visual effect for cleared orbs?
- Max orbs cleared per line?
- Is line orb itself consumed?

### Event Emitted
`question.asked` - Q3: Line Orb definition

---

## 2026-03-10 - Architect Answer: Line Orb Definition

### Question
Q3: What defines the "line" for Vertical/Horizontal Line Orbs - full-screen sweep vs limited range vs raycast-based?

### Research Summary

**Codebase Analysis:**
1. Game resolution is 1920x1080 (camera at 960, 540)
2. Orbs spawn in configurable zone: `Rect2(Vector2(-200, -200), Vector2(400, 400))`
3. Orbs use group "orbs" for scene tree queries
4. Existing task-13 design already specifies LineClearBehavior with tolerance-based matching
5. Burst orb (ChainReactionBehavior) uses radius-based detection from same origin

**Existing Design (task-13-line-clear-behavior.code-task.md):**
- Uses `tolerance: float = 20.0` for alignment matching
- Finds all orbs in "orbs" group
- Matches if `abs(orb.x - source.x) < tolerance` (vertical) or `abs(orb.y - source.y) < tolerance` (horizontal)
- Effectively full-screen sweep with coordinate tolerance

**Options Analysis:**

| Option | Pros | Cons | Complexity |
|--------|------|------|------------|
| Full-screen with tolerance | Simplest, dramatic visual, matches existing design | Could clear many orbs at once | Low |
| Limited range | More balanced, controllable impact | Requires extra distance parameter, less dramatic | Medium |
| Raycast-based | "Realistic" physics | Unnecessary collision complexity, orbs aren't obstacles | High |

### Recommendation: Full-screen Sweep with Tolerance

**Rationale:**
1. **Existing design alignment**: task-13 already specifies this exact approach
2. **Simplicity**: Uses standard `get_tree().get_nodes_in_group()` pattern
3. **Predictability**: Players can see all aligned orbs, clear expectation
4. **Dramatic effect**: "Power move" feel for special orbs

**Properties:**
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

**Why NOT limited range:**
- Adds extra configuration parameter
- Creates unclear visual feedback (where does line end?)
- Less dramatic/satisfying

**Why NOT raycast-based:**
- Orbs aren't physical obstacles requiring raycast logic
- Unnecessary collision complexity
- No gameplay benefit over tolerance matching

---

## 2026-03-10 - Inquisitor: Requirements Complete

### Pending Event Handled
- `answer.proposed` for Q3 (Line Orb definition) - **ACCEPTED**
- REQ-3 (Line Orbs) and REQ-4 (Burst Orb) already captured in requirements.md

### Final Gap Analysis

All 8 orb types now have complete specifications:

| Orb Type | Specification | Source |
|----------|---------------|--------|
| Burst Orb | REQ-4: 150px radius chain reaction | Design decision |
| Vertical Line Orb | REQ-3: Full-screen sweep, 20px tolerance | Q3/A3 |
| Horizontal Line Orb | REQ-3: Full-screen sweep, 20px tolerance | Q3/A3 |
| Slow Fall Orb | Existing `slow_fall` effect | EffectManager |
| Sticky Head Orb | REQ-1: Damping-zone, 0.3-0.5s duration | Q1/A1 |
| Double Value Orb | Existing `double_value` effect | EffectManager |
| Combo Starter Orb | Existing `combo_chain` effect | EffectManager |
| Drifter Orb | REQ-2: Horizontal drift, sine wave | Q2/A2 |

### Critical Ambiguities Resolved
1. ✅ Sticky Head behavior mechanism (damping-zone chosen)
2. ✅ Drifter movement pattern (horizontal drift chosen)
3. ✅ Line Orb definition (full-screen sweep with tolerance)
4. ✅ Burst Orb radius (150px)

### Success Criteria Defined
- All 8 orb types implemented
- Integrated into spawning system
- Tests pass (`./devscripts/test.sh` exits 0)
- Existing gameplay preserved

---

## 2026-03-10 - Architect: Design Document Complete

### Design Document Created
Created comprehensive design document at `specs/orb-content-pack/design.md`

### Document Contents
1. **Overview** - Problem statement and solution summary
2. **Detailed Requirements** - All 4 REQs from Q&A consolidated
3. **Architecture Overview** - Mermaid diagram showing component relationships
4. **Components and Interfaces** - 6 behavior classes with GDScript signatures
5. **Data Models** - Class diagram for OrbData/OrbBehavior hierarchy
6. **Orb Pack Specification** - Table of all 8 orbs with behaviors
7. **Implementation Sequence** - 5-phase flowchart
8. **Error Handling** - Edge cases for behaviors
9. **Testing Strategy** - Unit and integration tests
10. **Manual Verification Steps** - Step-by-step for each orb
11. **File Changes Summary** - New and modified files
12. **Constraints and Limitations** - Design decisions and tradeoffs

13. **Acceptance Criteria** - Definition of done checklist

### Key Behaviors Designed
1. **ScoreBehavior** - Centralized scoring with multiplier/double-value support
2. **ChainReactionBehavior** - 150px radius, excludes source orb
3. **LineClearBehavior** - 20px tolerance, full-screen sweep
4. **MovementBehavior** - Sine-wave oscillation, stores initial position
5. **TimedModifierBehavior** - Reusable for all timed effects
6. **StickyHeadBehavior** - New effect type, requires ball.gd update

### Handoff
Publishing `design.drafted` event for Design Critic review.

---

## 2026-03-10 - Design Critic: Review Complete - REJECTED

### Design Review Summary

**Document Reviewed:** `specs/orb-content-pack/design.md`
**Decision:** REJECT
**Critical Issue:** Sticky head implementation approach is fundamentally broken

### Review Checklist Results

#### Completeness
| Criterion | Status | Notes |
|-----------|--------|-------|
| All requirements from Q&A addressed | PASS | All 4 REQs present |
| Error handling specified | CONCERN | "Log warning" but no logger mechanism defined |
| Edge cases have strategies | PASS | Sections 8.2-8.3 cover chain/line edge cases |

#### Feasibility
| Criterion | Status | Notes |
|-----------|--------|-------|
| Implementable with available tools | PASS | EffectManager, ScoreManager, OrbBehavior all verified |
| No magic steps | FAIL | Sticky head physics is wrong (see below) |
| Integration points realistic | PASS | ball.gd, orb_spawner.gd modifications reasonable |

#### Simplicity (YAGNI/KISS)
| Criterion | Status | Notes |
|-----------|--------|-------|
| No speculative features | CONCERN | VERTICAL_OSCILLATE enum not needed by any orb |
| Could be simpler | PASS | Design is appropriately lean |
| Abstractions justified | PASS | Behavior classes map to actual needs |

#### Testability
| Criterion | Status | Notes |
|-----------|--------|-------|
| Testing strategy concrete | PASS | Specific test files and cases listed |
| Success criteria measurable | PASS | `./devscripts/test.sh exits 0` |
| E2E scenario defined | PASS | Manual verification steps for each orb |

#### Clarity
| Criterion | Status | Notes |
|-----------|--------|-------|
| Implementable from design alone | FAIL | Sticky head physics is ambiguous/wrong |
| No ambiguous language | PASS | Values are concrete |
| Diagrams match text | PASS | Mermaid diagrams consistent |

### Critical Issue: Sticky Head Implementation

**Design Proposal (Section 4.6):**
```gdscript
# In ball.gd _physics_process
if EffectManager.has_effect("sticky_head"):
    var damping: float = EffectManager.get_effect_value("sticky_head")
    linear_velocity.y *= damping  # damping = 0.3
```

**Problem:**
This applies damping **every frame** for the effect's duration. With:
- damping = 0.3
- 60 FPS
- Duration = 0.4 seconds (24 frames)

After 24 frames: `velocity = initial * (0.3)^24 ≈ 0`

**This does NOT "briefly stick then release" - it stops the ball instantly.**

The requirement (REQ-1) says:
> "Temporarily makes the ball 'stick' very briefly to the player's head before bouncing away"
> "Mechanism: Reduces ball's vertical velocity when near player head"

The design's implementation does NOT achieve this. It would kill all vertical motion within ~0.1 seconds.

**Possible Correct Approaches:**
1. **Collision-based:** Apply damping only when ball collides with player (not every frame)
2. **Proximity-based:** Apply damping only when ball is within detection zone of player head
3. **Bounce modification:** Modify bounce velocity on player collision, not during physics process

### Minor Concerns

1. **VERTICAL_OSCILLATE not required** - REQ-2 specifies horizontal only. The enum has vertical option that no orb uses.

2. **Logger not defined** - Error handling says "Log warning" but no logging mechanism is specified.

### Questions for Inquisitor

1. **Sticky head timing:** When exactly should damping apply?
   - Every frame (current design - broken)
   - Only on player collision
   - Only in proximity zone near player head

2. **What does "sticky" mean behaviorally?**
   - Ball pauses briefly then continues with original velocity?
   - Ball bounces with reduced velocity?
   - Ball's vertical component is dampened while horizontal preserved?

### Event Emitted
`design.rejected` - Critical issue with sticky head physics implementation

---

## 2026-03-10 - Inquisitor: Q4 Asked - Sticky Head Behavior

### Pending Event Handled
- `design.rejected` with issue `sticky_head_physics`

### Design Critic Analysis Reviewed

The Design Critic correctly identified that the proposed implementation is broken:
- Proposed: Apply 0.3 damping every frame for 0.4s duration
- Result: `velocity = initial * (0.3)^24 ≈ 0` (ball stops instantly)
- Requirement: "Briefly stick to player's head before bouncing away"

### Gap Identified

The original Q1/A1 exchange specified a "damping-zone" mechanism but didn't clarify:
1. **When** damping applies (every frame vs collision vs proximity)
2. **What** "sticky" means behaviorally

These are fundamentally different experiences:
- **Pause-and-release**: Ball pauses briefly, then continues with original velocity
- **Reduced bounce**: Ball bounces off player with reduced vertical velocity
- **Gravity dampening**: Ball falls slower but still moves

### Q4 Asked: Sticky Head Behavioral Intent

Asked the user to clarify what "sticky" should feel like:

**Question:** When the ball "sticks" to the player's head, what should the player experience?

**Options presented:**
1. **Collision dampening** - Ball bounces off player with reduced vertical velocity (e.g., 50% slower), making timing easier
2. **Gravity reduction** - Ball falls slower overall while effect is active, giving more reaction time
3. **Brief pause** - Ball pauses for ~0.2 seconds on player collision, then bounces normally

### Event Emitted
`question.asked` - Q4: Sticky head behavioral intent

---

## 2026-03-10 - Architect Answer: Sticky Head Behavioral Intent (Q4)

### Question
Q4: When the ball "sticks" to the player's head, what should the player experience?
- Option 1: Collision dampening - Ball bounces with reduced velocity
- Option 2: Gravity reduction - Ball falls slower overall
- Option 3: Brief pause - Ball pauses then bounces normally

### Research Summary

**Codebase Analysis:**
1. Ball (`ball.gd`) is RigidBody2D with `_on_body_entered()` signal handler
2. Player (`physics_player.gd`) is also RigidBody2D - needs to be in "player" group
3. Ball-player bounce happens via Godot physics engine (no explicit handling currently)
4. Ball already detects collisions: ground (game over), half_solid (velocity/3)
5. `slow_fall` effect already exists - modifies fall_speed in `_physics_process()`

**Key Insight:** Option 2 (Gravity reduction) is **redundant with Slow Fall Orb** - both would do the same thing.

**Options Analysis:**

| Option | Implementation | Feel | Complexity | Issue |
|--------|---------------|------|------------|-------|
| Collision dampening | Add player collision detection, reduce bounce velocity | "Slower bounce" - more time to position | Low-Medium | Unique, viable |
| Gravity reduction | Same as slow_fall | "Floaty ball" | Very Low | **DUPLICATE of Slow Fall** |
| Brief pause | Detect collision, store velocity, pause timer, restore | True "sticky" | High | Complex, risky |

### Recommendation: Option 1 - Collision Dampening

**Rationale:**
1. **Unique from Slow Fall** - Different mechanic, different feel
2. **Simplest non-trivial option** - Add player detection to existing `_on_body_entered()`
3. **Readable behavior** - Player sees bounces are slower, gives more control
4. **EffectManager integration** - Check effect on collision, apply dampening

**Implementation Approach:**
```gdscript
# In ball.gd _on_body_entered(body):
if body.is_in_group("player") and EffectManager.has_effect("sticky_head"):
    var dampening: float = EffectManager.get_effect_value("sticky_head")
    linear_velocity.y *= dampening  # e.g., 0.5 = 50% slower bounce
```

**Properties:**
| Property | Value | Rationale |
|----------|-------|-----------|
| Effect ID | `sticky_head` | Consistent with existing naming |
| Value | 0.5 (50% velocity) | Meaningful but not game-breaking |
| Duration | 15-20 seconds | Multiple bounces, not too long |
| Trigger | On player collision | Only affects bounces off player |
| Stacking | Replace | Simple, predictable |

**Why NOT Option 2 (Gravity reduction):**
- Would be identical to `slow_fall` effect
- Two orbs doing the same thing is poor design
- Wastes an orb slot

**Why NOT Option 3 (Brief pause):**
- Complex: requires velocity storage, timer, restoration
- Risk of physics glitches with RigidBody2D
- Over-engineered for MVP
- Hard to test deterministically

### REQ-1 Update Required

Update REQ-1 to clarify:
- **Trigger:** On player collision (NOT every frame, NOT proximity zone)
- **Effect:** Reduce bounce velocity by configurable factor (0.5 = 50%)
- **Duration:** 15-20 seconds (applies to all bounces during this time)

---

## 2026-03-10 - Inquisitor: Q4 Accepted - Requirements Complete

### Pending Event Handled
- `answer.proposed` for Q4 (Sticky head behavioral intent) - **ACCEPTED**

### Answer Analysis
The architect correctly identified:
1. **Option 2 (Gravity reduction)** = Redundant with Slow Fall Orb ❌
2. **Option 3 (Brief pause)** = Over-engineered, risky physics ❌
3. **Option 1 (Collision dampening)** = Unique, simple, testable ✅

### Requirements.md Updated
REQ-1 now specifies:
- Trigger: On player collision via `_on_body_entered(body)`
- Effect: `linear_velocity.y *= 0.5` (50% bounce velocity)
- Duration: 15-20 seconds (configurable)
- Different from Slow Fall (which affects gravity, not bounce)

### Final Requirements Status

| Orb Type | Requirement | Status |
|----------|-------------|--------|
| Sticky Head Orb | REQ-1 | ✅ Collision dampening |
| Drifter Orb | REQ-2 | ✅ Horizontal sine wave |
| Line Orbs (V/H) | REQ-3 | ✅ Full-screen, 20px tolerance |
| Burst Orb | REQ-4 | ✅ 150px radius |
| Slow Fall Orb | Existing | ✅ EffectManager: `slow_fall` |
| Double Value Orb | Existing | ✅ EffectManager: `double_value` |
| Combo Starter Orb | Existing | ✅ EffectManager: `combo_chain` |

### All Critical Ambiguities Resolved
1. ✅ Sticky Head mechanism → Collision dampening (not per-frame damping)
2. ✅ Drifter pattern → Horizontal sine wave (not vertical/circular)
3. ✅ Line Orb definition → Full-screen sweep with tolerance
4. ✅ Burst Orb radius → 150px

### Event Emitted
`requirements.complete` - All 8 orb types have clear, implementable specifications

---

## 2026-03-10 - Architect: Design Document Fixed

### Event Handled
`requirements.complete` - All 8 orb types have clear, implementable specifications

### Design Document Updates
Fixed `specs/orb-content-pack/design.md` to address Design Critic rejection:

1. **REQ-1 (Section 2)** - Updated to collision-based dampening:
   - Trigger: On player collision (via `_on_body_entered`)
   - Duration: 15-20 seconds
   - Effect Value: 0.5 (50% bounce velocity)

2. **Section 4.6 StickyHeadBehavior** - Fixed implementation approach:
   - Changed from per-frame damping in `_physics_process` (BROKEN)
   - To collision-based damping in `_on_body_entered(body)` (CORRECT)
   - Added CRITICAL note about when dampening applies

3. **Section 6 Orb Pack Specification** - Updated Sticky Head parameters:
   - `StickyHeadBehavior(0.5, 15.0)` instead of `StickyHeadBehavior(0.3, 0.4)`

4. **Section 10 Manual Verification** - Updated Sticky Head steps:
   - 15-20 second duration
   - Applies to ALL bounces during effect time
   - Different from Slow Fall (bounce velocity vs gravity)

### Critical Fix Summary
The original design would have stopped the ball instantly (`velocity * 0.3^24 ≈ 0`). The fixed design applies dampening only on player collision, preserving the bounce mechanic while giving players more control.

### Event Emitted
`design.drafted` - Design document fixed, ready for Design Critic re-review

---

## 2026-03-10 - Design Critic: Re-Review Complete - APPROVED

### Pending Event Handled
- `design.drafted` with fix for `sticky_head_physics` issue

### Review Summary

**Document Reviewed:** `specs/orb-content-pack/design.md`
**Decision:** APPROVE
**Previous Critical Issue:** Sticky head implementation (per-frame damping) - **FIXED**

### Review Checklist Results

#### Completeness
| Criterion | Status | Notes |
|-----------|--------|-------|
| All requirements from Q&A addressed | PASS | All 4 REQs present, updated with Q4 answer |
| Error handling specified | PASS | "Log warning" uses Godot's built-in push_warning() |
| Edge cases have strategies | PASS | Sections 8.2-8.3 cover chain/line edge cases |

#### Feasibility
| Criterion | Status | Notes |
|-----------|--------|-------|
| Implementable with available tools | PASS | EffectManager, ScoreManager, OrbBehavior all verified |
| No magic steps | PASS | Sticky head now uses collision-based approach (correct) |
| Integration points realistic | PASS | ball.gd, orb_spawner.gd modifications reasonable |

#### Simplicity (YAGNI/KISS)
| Criterion | Status | Notes |
|-----------|--------|-------|
| No speculative features | CONCERN (minor) | VERTICAL_OSCILLATE enum unused but negligible cost |
| Could be simpler | PASS | Design is appropriately lean |
| Abstractions justified | PASS | Behavior classes map to actual needs |

#### Testability
| Criterion | Status | Notes |
|-----------|--------|-------|
| Testing strategy concrete | PASS | Specific test files and cases listed |
| Success criteria measurable | PASS | `./devscripts/test.sh exits 0` |
| E2E scenario defined | PASS | Manual verification steps for each orb |

#### Clarity
| Criterion | Status | Notes |
|-----------|--------|-------|
| Implementable from design alone | PASS | Sticky head now unambiguous with CRITICAL note |
| No ambiguous language | PASS | Values are concrete (0.5 dampening, 150px radius, etc.) |
| Diagrams match text | PASS | Mermaid diagrams consistent with descriptions |

### Critical Issue: RESOLVED

**Previous Problem (Section 4.6):**
```gdscript
# In ball.gd _physics_process  ← WRONG: applies every frame
if EffectManager.has_effect("sticky_head"):
    linear_velocity.y *= damping  # Result: ball stops instantly
```

**Fixed Implementation (Section 4.6):**
```gdscript
# In ball.gd _on_body_entered(body)  ← CORRECT: applies only on collision
if body.is_in_group("player") and EffectManager.has_effect("sticky_head"):
    var damping: float = EffectManager.get_effect_value("sticky_head")
    linear_velocity.y *= damping  # e.g., 0.5 = 50% slower bounce
```

**CRITICAL Note Added:**
> Dampening applies only on player collision, NOT every frame. This preserves the bounce mechanic while giving the player more control.

This is now **correct**. The ball will bounce with reduced vertical velocity on player collisions while the effect is active, giving players more control without breaking the physics.

### Minor Concerns (Non-blocking)

1. **VERTICAL_OSCILLATE enum** - REQ-2 only uses horizontal, but the enum has vertical option. This is a negligible cost (one enum value) and doesn't justify a rejection.

2. **Logger mechanism** - "Log warning" references Godot's built-in `push_warning()` which is standard. Not a real concern.

### Verification of Requirements Alignment

| REQ | Design Section | Status |
|-----|----------------|--------|
| REQ-1: Sticky Head (collision dampening, 0.5, 15s) | Section 2, 4.6 | ✅ Fixed |
| REQ-2: Drifter (horizontal sine, 75px, 2Hz) | Section 2, 4.4 | ✅ Matched |
| REQ-3: Line Orbs (full-screen, 20px tolerance) | Section 2, 4.2 | ✅ Matched |
| REQ-4: Burst Orb (150px radius) | Section 2, 4.1 | ✅ Matched |
| Existing effects (slow_fall, double_value, combo_chain) | Section 2 | ✅ Referenced |

### Decision: APPROVE

All critical issues from previous review have been addressed. The design is now:
- Implementable without ambiguity
- Correct in its physics approach
- Aligned with all Q&A answers
- Testable with concrete success criteria

Ready for Explorer to research codebase patterns and begin implementation.

### Event Emitted
`design.approved` - All critical issues resolved, design ready for implementation

---

## 2026-03-10 - Explorer: Codebase Research Complete

### Pending Event Handled
- `design.approved` - Design ready for implementation research

### Research Summary

**Files Created:**
- `specs/orb-content-pack/research/existing-patterns.md` - Code patterns and conventions
- `specs/orb-content-pack/research/technologies.md` - Dependencies and frameworks
- `specs/orb-content-pack/research/broken-windows.md` - Low-risk code smells
- `specs/orb-content-pack/context.md` - Implementation context and integration points

### Key Findings

#### 1. OrbBehavior System (Verified)
- Abstract `Resource` class with `execute()`, `process()`, `on_spawn()` methods
- Context dictionary: `{ "orb": Node, "orb_data": OrbData, "collector": Node }`
- Located at `scripts/data/behaviors/orb_behavior.gd`

#### 2. EffectManager (Verified)
- Singleton with stacking rules: multiplicative_ceiling, multiplicative_floor, increment, replace
- Existing effects: `slow_fall`, `score_multiplier`, `time_slow`, `combo_chain`, `double_value`
- Default stacking is "replace" - sticky_head will work without modification
- Located at `scripts/effect_manager.gd`

#### 3. CRITICAL: Player Group Missing
- `physics_player.gd` does NOT add itself to "player" group
- **Required fix:** Add `add_to_group("player")` in `_ready()`
- Without this, sticky head collision detection will fail

#### 4. Ball Collision Integration
- `_on_body_entered(body)` in `scripts/ball.gd:49-56`
- Currently handles: ground (game over), half_solid (velocity/3)
- Integration point for sticky_head player collision

#### 5. Testing Patterns
- GUT framework with `extends GutTest`
- Assertions: `assert_eq`, `assert_true`, `assert_false`, `assert_null`
- Async: `await wait_seconds()`
- Setup: `before_each()` for test isolation

### Integration Points Identified

| Component | File | Change Required |
|-----------|------|-----------------|
| Sticky head detection | ball.gd:49-56 | Add player collision check |
| Player group | physics_player.gd:53 | Add `add_to_group("player")` |
| Behavior classes | scripts/data/behaviors/ | Create 6 new behavior files |
| Orb resources | resources/orbs/ | Create 8 new .tres files |
| Tests | tests/unit/ | Create behavior tests |

### Open Questions for Builder

1. **Spawner Integration:** Current spawner uses old OrbProps system. Need to determine integration approach for OrbData-based orbs.

2. **Orb Scene:** Current GenericOrb uses OrbProps. May need new scene or modification for OrbData behaviors.

3. **Textures:** Check `sprites/` directory for existing orb textures or create placeholders.

### Event Emitted
`context.ready` - Research complete, ready for Planner to create implementation plan

---

## 2026-03-10 - Planner: Implementation Plan Complete

### Pending Event Handled
- `context.ready` - Research complete, ready for Planner to create implementation plan

### Plan Created
**File:** `specs/orb-content-pack/plan.md`

### Plan Structure

**10 TDD Implementation Steps:**

| Step | Component | Tests | Key Deliverable |
|------|-----------|-------|-----------------|
| 1 | Player Group Fix | test_player_in_group | Prerequisite for sticky_head |
| 2 | ScoreBehavior | 4 unit tests | Base scoring + multipliers |
| 3 | TimedModifierBehavior | 3 unit tests | Generic effect application |
| 4 | ChainReactionBehavior | 4 unit tests | Burst orb (150px radius) |
| 5 | LineClearBehavior | 4 unit tests | Line orbs (20px tolerance) |
| 6 | MovementBehavior | 4 unit tests | Drifter (sine wave) |
| 7 | StickyHeadBehavior + Ball | 6 tests | Collision dampening |
| 8 | Orb Resources | Existing | 8 .tres files |
| 9 | Spawn Integration | Integration | Orbs spawn in-game |
| 10 | Final Validation | ./devscripts/test.sh | All tests pass |

### Test Strategy Summary

**Unit Tests:** 25+ new tests covering:
- Score calculation with multipliers
- Chain reaction radius detection
- Line clear tolerance matching
- Movement behavior oscillation
- Sticky head effect application
- Ball collision integration

**Integration Tests:**
- Burst orb chain reaction
- Line orb clearing
- Drifter movement
- Effect stacking

**E2E Manual Verification:**
- All 8 orb types spawnable
- Each orb's unique behavior verified
- No existing gameplay broken

### Critical Path
```
Step 1 (Player Group) ──┐
                        ├──> Step 7 (StickyHead + Ball) ──┐
Steps 2-6 (Behaviors) ──┘                                  │
                                                           ├──> Step 8-10
```

### Files Summary
- **New:** 17 files (6 behaviors, 8 tests, 8 resources)
- **Modified:** 2 files (ball.gd, physics_player.gd)

### Event Emitted
`plan.ready` - Implementation plan ready for Task Writer

---

## 2026-03-10 - Task Writer: Code Tasks Complete

### Pending Event Handled
- `plan.ready` - Implementation plan ready for conversion to code tasks

### Task Files Created
Created 10 code task files in `specs/orb-content-pack/tasks/`:

| Task | File | Description |
|------|------|-------------|
| 1 | task-01-player-group-fix.code-task.md | Add player to "player" group |
| 2 | task-02-score-behavior.code-task.md | ScoreBehavior with multipliers |
| 3 | task-03-timed-modifier-behavior.code-task.md | TimedModifierBehavior for effects |
| 4 | task-04-chain-reaction-behavior.code-task.md | ChainReactionBehavior for Burst Orb |
| 5 | task-05-line-clear-behavior.code-task.md | LineClearBehavior for Line Orbs |
| 6 | task-06-movement-behavior.code-task.md | MovementBehavior for Drifter Orb |
| 7 | task-07-sticky-head-behavior.code-task.md | StickyHeadBehavior + Ball integration |
| 8 | task-08-orb-data-resources.code-task.md | 8 OrbData resource files |
| 9 | task-09-spawn-system-integration.code-task.md | Spawn system integration |
| 10 | task-10-final-validation.code-task.md | Final validation and manual verification |

### Task Format
Each task follows the standard code-task.md format:
- Frontmatter: status, created, started, completed
- Description and Background
- Reference Documentation (design.md, plan.md)
- Technical Requirements
- Dependencies on previous tasks
- TDD Implementation Approach
- Acceptance Criteria in Given-When-Then format
- Metadata (complexity, labels, required skills)

### Dependency Chain
```
Task 1 ─────────────────────────────────────────────┐
                                                    │
Tasks 2-6 (independent) ────────────────────────────┤
                                                    │
Task 7 (requires Task 1) ───────────────────────────┤
                                                    │
Task 8 (requires Tasks 2-7) ────────────────────────┤
                                                    │
Task 9 (requires Task 8) ───────────────────────────┤
                                                    │
Task 10 (requires all) ─────────────────────────────┘
```

### Event Emitted
`tasks.ready` - All 10 code tasks ready for Builder

---

## 2026-03-10 - Builder: Task 01 Complete

### Event Handled
`tasks.ready` - 10 code tasks ready for implementation

### Task Implemented
**Task 01: Player Group Fix**
- File: `specs/orb-content-pack/tasks/task-01-player-group-fix.code-task.md`
- Status: ✅ Completed

### TDD Cycle
1. **RED**: Created `tests/unit/test_player_in_group.gd` with 2 tests
   - `test_player_in_player_group()` - Test via scene instantiation
   - `test_player_group_after_ready()` - Test via script loading
   - Result: 2 tests failing ❌

2. **GREEN**: Added `add_to_group("player")` to `physics_player.gd:53`
   - Result: All 214 tests passing ✅

3. **REFACTOR**: Verified convention alignment
   - Follows same pattern as `ball.gd` adding "ball" group
   - Test follows existing GutTest patterns
   - No additional changes needed

### Files Changed
- `scripts/physics_player.gd` - Added 1 line in `_ready()`
- `tests/unit/test_player_in_group.gd` - New file (2 tests)

### Event Emitted
`task.complete` - Task 01 (player group fix) complete, 1 of 10 tasks done

---

## 2026-03-10 - Builder: Task 02 Complete

### Event Handled
`task.complete` - Task 01 (player group fix) complete

### Task Implemented
**Task 02: ScoreBehavior Implementation**
- File: `specs/orb-content-pack/tasks/task-02-score-behavior.code-task.md`
- Status: ✅ Completed

### TDD Cycle
1. **RED**: Created `tests/unit/test_score_behavior.gd` with 6 tests
   - `test_base_score_awarded()` - Base score added correctly
   - `test_default_base_score_is_one()` - Default value check
   - `test_double_value_applied()` - Double value effect
   - `test_score_multiplier_applied()` - Score multiplier effect
   - `test_combined_multipliers()` - Both effects together
   - `test_no_effects_base_score_only()` - No effects case
   - Result: Tests failed (class not found) ❌

2. **GREEN**: Created `scripts/data/behaviors/score_behavior.gd`
   - Extends `OrbBehavior` base class
   - `@export var base_score: int = 1`
   - Checks `EffectManager.has_effect("double_value")`
   - Checks `EffectManager.get_effect_value("score_multiplier")`
   - Calls `ScoreManager.add_score(score)`
   - Result: All 220 tests passing ✅

3. **REFACTOR**: Verified convention alignment
   - Follows OrbBehavior pattern from design.md
   - Uses standard Godot typing and region organization
   - Test follows existing GutTest patterns
   - No additional changes needed

### Files Changed
- `scripts/data/behaviors/score_behavior.gd` - New file (ScoreBehavior class)
- `tests/unit/test_score_behavior.gd` - New file (6 tests)

### Acceptance Criteria Verified
| Criterion | Status |
|-----------|--------|
| Base score awarded | ✅ Pass |
| Double value applied | ✅ Pass |
| Score multiplier applied | ✅ Pass |
| Combined multipliers | ✅ Pass |
| All tests pass | ✅ 220/220 |

### Event Emitted
`task.complete` - Task 02 (ScoreBehavior) complete, 2 of 10 tasks done

---

## 2026-03-10 - Builder: Task 03 Complete

### Event Handled
`task.complete` - Task 02 (ScoreBehavior) complete

### Task Implemented
**Task 03: TimedModifierBehavior Implementation**
- File: `specs/orb-content-pack/tasks/task-03-timed-modifier-behavior.code-task.md`
- Status: ✅ Completed

### TDD Cycle
1. **RED**: Created `tests/unit/test_timed_modifier_behavior.gd` with 4 tests
   - `test_effect_applied()` - Effect is applied through EffectManager
   - `test_empty_effect_id_skipped()` - Empty effect_id does nothing
   - `test_value_passed_correctly()` - Value is passed correctly
   - `test_default_values()` - Defaults are correct
   - Result: Tests failed (class not found) ❌

2. **GREEN**: Created `scripts/data/behaviors/timed_modifier_behavior.gd`
   - Extends `OrbBehavior` base class
   - `@export var effect_id: String = ""`
   - `@export var value: float = 1.0`
   - `@export var duration: float = 10.0`
   - In `execute()`: calls `EffectManager.apply_effect()` if effect_id not empty
   - Result: All 224 tests passing ✅

3. **REFACTOR**: Verified convention alignment
   - Follows same pattern as ScoreBehavior and OrbBehavior
   - Uses standard Godot typing and region organization
   - Test follows existing GutTest patterns
   - No additional changes needed

### Files Changed
- `scripts/data/behaviors/timed_modifier_behavior.gd` - New file (TimedModifierBehavior class)
- `tests/unit/test_timed_modifier_behavior.gd` - New file (4 tests)
- `specs/orb-content-pack/tasks/task-03-timed-modifier-behavior.code-task.md` - Updated frontmatter

### Acceptance Criteria Verified
| Criterion | Status |
|-----------|--------|
| Effect Applied | ✅ Pass |
| Empty Effect ID Skipped | ✅ Pass |
| Value Passed Correctly | ✅ Pass |
| Default Values | ✅ Pass |
| All tests pass | ✅ 224/224 |

### Event Emitted
`task.complete` - Task 03 (TimedModifierBehavior) complete, 3 of 10 tasks done
