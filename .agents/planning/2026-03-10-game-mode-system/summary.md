# Game Mode System - Planning Summary

## Project Overview

This document summarizes the planning phase for adding a modular game mode system to "Don't Drop the Ball".

---

## Artifacts Created

```
.agents/planning/2026-03-10-game-mode-system/
├── rough-idea.md              # Initial concept and requirements
├── idea-honing.md             # 13 Q&A clarifications with decisions
├── research/
│   └── existing-codebase-analysis.md   # Current architecture analysis
├── design/
│   └── detailed-design.md     # Architecture, components, data models
├── implementation/
│   └── plan.md                # 12-step implementation checklist
└── summary.md                 # This document
```

---

## The 4 Game Modes

| Mode | Win Condition | Lose Condition | Score Metric | HUD Display |
|------|---------------|----------------|--------------|-------------|
| **Classic Endless** | N/A (endless) | Ball drops | Total score | Score |
| **Time Attack** | Survive 2 minutes | Ball drops before time | Score in 2 min | Timer countdown |
| **Orb Hunt** | Reach target from specific orbs | Ball drops | Progress % | Percentage |
| **Survival Waves** | N/A (endless) | Ball drops | Waves survived | Wave number |

---

## Architecture Summary

### New Singletons
- **ModeManager**: Orchestrates mode lifecycle, holds current mode state

### New Resources
- **ModeConfig**: Defines mode properties (orb pool, win/lose, UI hints)

### New Classes
- **ModeBase**: Abstract base for mode implementations
- **EndlessMode, TimeAttackMode, OrbHuntMode, SurvivalMode**: Concrete modes

### Modified Files
- `saved_game.gd`: Add `mode_high_scores` dictionary
- `ball.gd`: Extract game over trigger (mode-aware)
- `main_menu.gd`: Add mode selection button
- `hud.gd`: Add mode badge and metric display
- `world_builder.gd`: Integrate with ModeManager
- `orb_spawner.gd`: Support mode-specific orb pools

---

## Implementation Phases

| Phase | Steps | Description |
|-------|-------|-------------|
| Foundation | 1-3 | Data structures, ModeManager, ModeBase |
| Integration | 4-5 | Connect to game flow, add mode selection UI |
| Modes | 6-8 | Implement Time Attack, Orb Hunt, Survival |
| Features | 9-11 | Orb pools, high scores, HUD |
| Polish | 12 | Final testing and verification |

---

## Key Decisions Recap

- **Mode Selection**: Quick Play + Mode Button (Quick Play = Classic Endless)
- **High Scores**: Separate per mode, persisted via existing save system
- **Orb Pools**: Mode-specific, each mode defines which orbs spawn
- **Unlock System**: All modes unlocked from start
- **HUD**: Mode badge + one key metric (minimal, clean)

---

## Testing Strategy

### Unit Tests (8 files)
- test_mode_config.gd
- test_mode_manager.gd
- test_mode_base.gd
- test_endless_mode.gd
- test_time_attack_mode.gd
- test_orb_hunt_mode.gd
- test_survival_mode.gd
- test_hud_mode_display.gd

### Integration Tests (3 files)
- test_mode_transitions.gd
- test_mode_orb_spawner.gd
- test_mode_high_scores.gd

### Validation
- All tests must pass: `./devscripts/test.sh`
- Smoke test must pass: `./devscripts/smoke_test.sh`
- Manual verification of each mode

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing gameplay | Extensive integration tests in Step 4 |
| Save file migration | Handle missing `mode_high_scores` gracefully |
| UI complexity | Keep HUD minimal, defer fancy animations |
| Performance impact | Mode checks are simple comparisons |

---

## Next Steps

1. Review the detailed design document
2. Review the implementation plan
3. Begin implementation with Step 1

### To Start Implementation with Ralph Loop

After you've reviewed and approved this plan, you can start the implementation using:

```bash
ralph run --config presets/pdd-to-code-assist.yml --prompt "Implement the game mode system following the plan at .agents/planning/2026-03-10-game-mode-system/implementation/plan.md. Start with Step 1: Mode Data Foundation."
```

Or for a more guided approach:

```bash
ralph run --config presets/spec-driven.yml --prompt "Implement game mode system step by step. Reference: .agents/planning/2026-03-10-game-mode-system/"
```
