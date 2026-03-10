# Idea Honing - Orb System Expansion

This document captures the requirements clarification process.

---

## Q1: Architecture Direction

The current orb system has three nearly-identical orb scripts (BlueOrb, RedOrb, HalfSolidOrb) with hardcoded properties. For the new modular orb system, which architectural approach do you prefer?

**Options:**

A) **Single Unified Orb Scene + Data-Driven Config**
- One Orb scene with a configurable behavior component
- All orb properties (sprite, score, effects, lifespan) defined in Resource files
- New orb types = new Resource definitions, no new scripts unless truly unique behavior

B) **Behavior Component System**
- Base Orb scene with attachable behavior components
- Each behavior (ScoringEffect, TimedEffect, MovementPattern) is a separate component
- Orbs are composed of multiple behaviors at runtime

C) **Hybrid: Base Class + Specialized Subclasses**
- Abstract BaseOrb with common functionality
- Specialized subclasses only when behavior diverges significantly
- Properties still data-driven via Resources

**Which direction aligns best with your vision for maintainability and extensibility?**

### Answer: Option A - Single Unified Orb Scene + Data-Driven Config (with behavior resources)

**Rationale:**
- Most orb types differ only in data (sprite, score value, lifespan, visual effects)
- Complex behaviors (movement, chain reactions, timed modifiers) can be encoded as `OrbBehavior` resources
- New orb types = new `OrbData` resource definitions, no new scripts for 90% of cases
- When truly unique behavior is needed, create a custom `OrbBehavior` subclass
- Eliminates code duplication across BlueOrb, RedOrb, HalfSolidOrb
- Aligns with Godot's Resource system for data-driven design
- Testable: orb logic centralized in one place

**Architecture Sketch:**
```
OrbData (Resource)
├── display_name: String
├── texture: Texture2D
├── base_score: int
├── lifespan: float
├── collision_shape: Shape2D (optional override)
├── behaviors: Array[OrbBehavior]  ← Pluggable behaviors

OrbBehavior (Abstract Resource)
├── OnCollectEffect (adds score, triggers events)
├── TimedModifierEffect (applies temp modifier to player/ball)
├── ChainReactionEffect (triggers nearby orbs)
├── MovementBehavior (drifting, orbiting, etc.)
└── ... (extensible)

Orb (Scene + Script)
├── Single unified orb scene
├── Reads OrbData at spawn
├── Configures sprite, collision, timer from data
├── Executes behaviors on collection
```

---

## Q2: Effect Application Model

For orbs that apply effects to the player, ball, or game state (e.g., slow motion, sticky head, double value), how should these effects be managed?

**Options:**

A) **Singleton Effect Manager** - A central `EffectManager` autoload tracks all active effects, handles stacking/refresh/expiration, and broadcasts changes to interested systems

B) **Component on Target** - Effects attach directly to the player/ball as child nodes, each managing its own lifetime

C) **State-Based in Existing Singletons** - Integrate effect tracking into existing `GameState` or `ScoreManager` autoloads (e.g., a `multiplier` property in ScoreManager, a `time_scale` in GameState)

**Which model fits your mental model of how effects should work?**

### Answer: Option A - Singleton Effect Manager

**Rationale:**
- Centralized tracking makes stack/refresh/replace rules straightforward
- Single source of truth for "what effects are active"
- Easy to query from any system (UI, player, ball, scoring)
- Clear separation of concerns - effect management is its own domain
- Supports complex conflict resolution (e.g., "only one time modifier active")
- Testable: can verify effect state transitions in isolation
- Aligns with existing pattern (GameState, ScoreManager are singletons)

**Key Structure:**
```
EffectManager (Autoload)
├── active_effects: Dictionary  # effect_id -> ActiveEffect
├── apply_effect(effect_data) -> void
├── remove_effect(effect_id) -> void
├── has_effect(effect_id) -> bool
├── get_effect_value(effect_id) -> Variant
└── signals: effect_applied, effect_removed, effect_expired

ActiveEffect
├── effect_data: EffectData (Resource)
├── remaining_duration: float (-1 for instant/permanent)
├── stack_count: int
└── source: Node (the orb that caused it)
```

---

## Q3: First Orb Pack Selection

You suggested 10 potential orb types. For the first content pack (6-10 orbs), prioritizing implementation complexity, effect type coverage, and fun factor.

**Final First Orb Pack (9 orbs):**

| # | Orb Name | Effect Type | Description | Complexity |
|---|----------|-------------|-------------|------------|
| 1 | **Score Multiplier** | Timed/Stack | 2x score for 10s | Low |
| 2 | **Slow Fall** | Timed | Ball falls 50% slower for 8s | Low-Med |
| 3 | **Burst** | Instant/Chain | Collects all orbs within radius, cashes them in | Medium |
| 4 | **Drifter** | Movement | Slowly drifts horizontally while active | Low |
| 5 | **Double Value** | Instant/State | Next orb collected worth 2x (one-time) | Low |
| 6 | **Time Slow** | Timed/Game | Slow motion (0.5x) for 5s | Medium |
| 7 | **Combo Starter** | Timed/Stack | 5s window: each orb collected increases chain multiplier by 0.5x | Medium |
| 8 | **Vertical Line** | Instant/Area | Collects all orbs in vertical column (same X position) | Medium |
| 9 | **Horizontal Line** | Instant/Area | Collects all orbs in horizontal row (same Y position) | Medium |

**Deferred to future packs:**
- Sticky Head (requires player collision physics changes)
- Risk/Reward orb (design complexity, needs more thought on risk mechanic)

**Visual Approach for Line Orbs:**
- Mono-color rectangular sprite that spawns on hit
- Simple flash animation, then despawns
- Can be enhanced later with VFX (line flash, particle trail)

---

## Q4: Effect Stacking & Duration Rules

When the same effect is applied while already active, how should it behave?

**Options:**

A) **Stack** - Add another instance, increasing potency (2x + 2x = 4x)

B) **Refresh** - Reset timer to full duration, no power increase

C) **Replace** - Remove old, apply fresh instance

D) **Configurable per effect** - Each effect defines its own stack_rule

### Answer: Option A - Stack (with duration adjustment)

**Rationale:**
- Stacking rewards skilled play and consecutive catches
- Creates exciting "run" moments when player chains multipliers
- Simpler mental model: more orbs = stronger effect

**Duration Adjustment:**
- Game is relaxed/slow-paced
- Effects should last **45 seconds** (not 10s)
- Time Slow: **10 seconds** (more impactful, doesn't overstay welcome)

**Revised Effect Parameters:**

| Effect | Duration | Stack Behavior |
|--------|----------|----------------|
| Score Multiplier | 45s | Stack (2x + 2x = 4x) |
| Slow Fall | 45s | Stack (50% + 25% = 75% slower, cap at 90%) |
| Time Slow | 10s | Stack (0.5x + 0.25x = 0.25x, cap at 0.25x) |
| Combo Starter | 10s | Refresh timer, stack count increases |
| Double Value | Until used | N/A (one-time state) |

---

## Q5: Orb Spawning System

Current `OrbSpawner` uses simple timer + random from array. For 12+ orb types, what spawn model?

**Options:**

A) **Keep current** - Random from array, weights via duplicate entries

B) **Weighted spawn table** - `spawn_weight` on OrbData, weighted random selection

C) **Rarity tiers** - Common/Uncommon/Rare levels, spawner respects distribution

D) **Dynamic spawner** - Adjusts rates based on game state (more value orbs when low score)

### Answer: B + C Combined - Weighted Spawning with Rarity Tiers

**Rationale:**
- Rarity provides clear categorization for designers
- Weights give fine-tuning control when needed
- Simple to implement, easy to balance
- Dynamic spawning can be added later as enhancement

**Structure:**
```
OrbRarity (Enum)
├── COMMON    (weight: 100, ~50% of spawns)
├── UNCOMMON  (weight: 40,  ~30% of spawns)
└── RARE      (weight: 10,  ~10% of spawns)

OrbData additions:
├── rarity: OrbRarity = COMMON
├── custom_weight: int = -1  # -1 = use rarity default, else override

SpawnTable (Resource)
├── orb_pool: Array[OrbData]
├── get_weighted_random() -> OrbData
└── Can be swapped for different game modes/levels
```

**First Pack Rarity Distribution:**

| Orb | Rarity | Notes |
|-----|--------|-------|
| Blue (existing) | COMMON | Baseline orb |
| Red (existing) | COMMON | Slightly more valuable |
| Score Multiplier | UNCOMMON | Power orb |
| Slow Fall | UNCOMMON | Defensive utility |
| Drifter | UNCOMMON | Movement variety |
| Double Value | UNCOMMON | Setup orb |
| Half-Solid (existing) | RARE | High value, physics interaction |
| Burst | RARE | Clear effect |
| Combo Starter | RARE | High skill ceiling |
| Time Slow | RARE | Dramatic effect |
| Vertical Line | RARE | Area clear |
| Horizontal Line | RARE | Area clear |

---

## Q6: Migration Strategy

Existing orbs (Blue, Red, Half-Solid) have separate scenes and scripts. How to migrate to the unified system?

**Options:**

A) **Big bang migration** - Convert all existing orbs to new system in one refactor, delete old scenes/scripts

B) **Parallel systems** - New unified orb coexists with old orbs, migrate incrementally

C) **Hybrid** - Convert Blue/Red immediately, keep Half-Solid as special case

### Answer: Option A - Big Bang Migration

**Rationale:**
- Cleanest result - no legacy code to maintain
- Single testing phase rather than multiple migrations
- Avoids confusion between old and new orb systems
- Forces complete implementation of new architecture
- Existing orbs are simple - migration is straightforward

**Migration Steps:**
1. Implement new OrbData, OrbBehavior, Orb classes
2. Create OrbData resources for Blue, Red, Half-Solid
3. Update OrbSpawner to use new system
4. Update OrbManager (now EffectManager) for new effect flow
5. Delete old scenes: blue_orb.tscn, red_orb.tscn, half_solid_orb.tscn, generic_orb.tscn
6. Delete old scripts: blue_orb.gd, red_orb.gd, half_solid_orb.gd, generic_orb.gd
7. Run all tests, fix issues
8. Manual gameplay verification

---

## Q7: Line Orb Scoring

When Vertical/Horizontal Line orbs collect other orbs, how are they scored?

**Options:**

A) **Score normally** - Each collected orb awards its full point value

B) **Score at reduced rate** - Collected orbs worth 50% (area clear trade-off)

C) **Don't score** - Just clears them, no points (risk/reward)

D) **Configurable per orb** - Each line orb defines its own scoring mode

### Answer: Option A - Score Normally

**Rationale:**
- Simple and intuitive - player gets full reward for clever positioning
- Encourages strategic play (position yourself to hit line orbs when many orbs are aligned)
- Feels rewarding, not punishing
- No special case logic needed in scoring system

---

## Q8: Active Effects UI

Players need visibility into active effects (45s duration). How much UI support?

**Options:**

A) **Minimal** - No UI for this phase, add later

B) **Simple HUD indicators** - Icons with timer bars for active effects

C) **Full effect panel** - Detailed list showing all effects, stacks, time

### Answer: Option A - Minimal (Low Priority)

**Rationale:**
- Focus scope on core orb system first
- Effects are visible through gameplay (slow fall = ball moves slower, etc.)
- Can add simple indicators in a follow-up pass
- Keep this phase lean and shippable

**Future Enhancement:**
- Add to HUD when time permits
- Simple icon + timer bar for each active effect
- Low engineering effort when prioritized

---
