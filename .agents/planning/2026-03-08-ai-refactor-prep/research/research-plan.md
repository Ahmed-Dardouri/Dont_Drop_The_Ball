# Research Plan

## Research Complete ✓

All five research topics have been investigated:

### 1. Orb System Deep Dive ✓
- Document: `01-orb-system-analysis.md`
- Key Findings: ~80% code duplication across orb types, wasteful scene instantiation, 8 steps to add new orb type

### 2. Event System Analysis ✓
- Document: `02-event-system-analysis.md`
- Key Findings: 14 event classes, PauseEvent.state static global state issue, no listener cleanup

### 3. Scene Dependency Analysis ✓
- Document: `03-scene-dependency-analysis.md`
- Key Findings: Heavy @onready coupling, hardcoded name checks, limited dependency injection

### 4. Test Infrastructure Review ✓
- Document: `04-test-infrastructure-review.md`
- Key Findings: Tests duplicate logic to avoid scenes, GUT has good capabilities for integration tests

### 5. Godot Best Practices for Extensibility ✓
- Document: `05-godot-extensibility-patterns.md`
- Key Findings: Composition over inheritance, Resource-based definitions, proper singleton patterns

---

## Research Summary

### Critical Issues Identified

1. **Orb System**: Massive duplication, wasteful instantiation, hard to extend
2. **Global State**: `PauseEvent.state` is static, creates hidden dependencies
3. **Scene Coupling**: Hardcoded paths and name checks throughout
4. **Test Gaps**: Logic duplicated in tests rather than testing actual code

### Recommended Architecture

1. **OrbDefinition** - Resource-based orb configurations
2. **GameState Singleton** - Replace static state with proper singleton
3. **Pure Logic Classes** - Extract physics from nodes
4. **Factory Pattern** - Centralized orb creation
5. **Behavior Components** - Pluggable orb behaviors

### Next Step

Ready to proceed to **detailed design** phase.
