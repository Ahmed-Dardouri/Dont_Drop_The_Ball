# Idea Honing: Requirements Clarification

This document captures the Q&A process to refine requirements for the AI-friendly refactor.

---

## Question 1: Primary Refactor Focus

**Question**: Which area is the highest priority for this refactor?

**Options presented**:
- A. Orb system - Focus on making orbs data-driven and eliminating code duplication
- B. Physics/testability - Focus on extracting pure logic from player/ball for easier testing
- C. Global state cleanup - Focus on reducing/eliminating static global state usage
- D. Equal priority - All areas should be addressed with equal importance
- E. Other - Different priority

**Answer**: All areas are high priority (Option D - Equal priority). User wants orb system, physics/testability, and global state cleanup all addressed.

---

## Question 2: Refactor Approach

**Question**: Incremental small changes vs systematic larger restructures?

**Options presented**:
- A. Incremental - Small, safe changes with tests passing after each step
- B. Systematic - Larger cohesive restructures, accepting bigger diffs
- C. Hybrid - Mix of both approaches

**Answer**: Option B - Systematic approach. User prefers larger cohesive restructures for cleaner end result.

---

## Question 3: Data-Driven Architecture Depth

**Question**: How far should data-driven architecture go for orbs/game elements?

**Options presented**:
- A. Resource-based definitions - Orb types as .tres files, code still needs updating for behaviors
- B. Fully data-driven - New orb types via data files only, no code changes needed
- C. Code-first with better patterns - Keep definitions in code but use cleaner inheritance/composition

**Answer**: Option C - Code-first with better patterns. Keep orb definitions in code but use inheritance/composition patterns that are cleaner and easier to extend. Pragmatic approach without over-engineering.

---

## Question 4: Test Coverage Expectations

**Question**: What's the target test coverage, and should tests require scene instantiation?

**Options presented**:
- A. Critical paths only - Tests for scoring, core orb logic, game state transitions
- B. Comprehensive - Tests for all refactored systems including edge cases
- C. Match current level - Similar coverage ratio for new architecture

**Additional question**: Pure unit tests vs scene-dependent tests?

**Answer**: Option B - Comprehensive tests including edge cases. Additionally, user wants integration tests that set up scenes in specific scenarios and verify the game works correctly. This should be "within reason" - practical and achievable.

---

## Question 5: Global State Strategy

**Question**: How to handle global state like PauseEvent.state?

**Options presented**:
- A. Singleton pattern - Convert to proper autoload singleton with explicit state management
- B. Event-only (stateless) - Remove static state, consumers track their own state from events
- C. State manager - Create dedicated GameState manager/autoload for all game state

**Answer**: Option A - Singleton pattern. Convert to proper autoload singleton with explicit state management.

---

## Question 6: Code Preservation Boundaries

**Question**: Any parts of current codebase that should be preserved as-is?

**Options presented**:
- A. Event system - Keep Events.gd dynamic event manager pattern
- B. Scene structure - Keep .tscn files and node hierarchy mostly unchanged
- C. Constants pattern - Keep Constants.gd autoload pattern
- D. Everything fair game - All code can be restructured
- E. Specific exclusions - User specifies particular files/patterns

**Answer**: Option D - Everything fair game. All code can be restructured as needed.

---

## Question 7: Future Expansion Priorities

**Question**: Which types of expansions are most likely after this refactor?

**Options presented**:
- A. More orb types - Different behaviors, effects, power-ups
- B. Game modes - Time attack, endless, challenge modes
- C. Environment variants - Backgrounds, physics modifiers, obstacles
- D. All equally likely - Prepare for all types equally
- E. Other - Different priority

**Answer**: Option D - All equally likely. Prepare extension points for orb types, game modes, and environment variants equally.

---

## Question 8: Success Criteria

**Question**: How will you measure refactor success?

**Options presented**:
- A. AI can add new orb types easily
- B. Tests give confidence - comprehensive test suite
- C. Clean architecture - well-organized, follows patterns
- D. All of the above - all criteria matter equally
- E. Specific criteria - other measures

**Answer**: Option D - All of the above. Success means: AI can easily add features, comprehensive tests provide confidence, and architecture is clean and organized.

---

## Question 9: Additional Constraints or Preferences

**Question**: Any additional constraints, preferences, or concerns?

**Answer**: None. Ready to proceed to design phase.

---

## Requirements Clarification Summary

### Confirmed Requirements:

1. **Scope**: All areas high priority - orb system, physics/testability, global state cleanup
2. **Approach**: Systematic restructures (larger cohesive changes, not incremental)
3. **Architecture Style**: Code-first with better patterns (inheritance/composition), pragmatic
4. **Test Coverage**: Comprehensive unit tests + integration tests (within reason)
5. **State Management**: Singleton pattern (convert static state to autoload singletons)
6. **Code Preservation**: Everything fair game for restructuring
7. **Future Expansion**: Prepare extension points for all: orbs, game modes, environments
8. **Success Criteria**: AI-friendly + comprehensive tests + clean architecture

**Status**: Requirements clarification COMPLETE

---

## Question 9: Additional Constraints or Preferences

**Question**: Any additional constraints, preferences, or concerns?

**Answer**: None. Ready to proceed to design phase.

---

## Design Phase Complete

The detailed design document has been created at:
- `.agents/planning/2026-03-08-ai-refactor-prep/design/detailed-design.md`

**Status**: Design COMPLETE

