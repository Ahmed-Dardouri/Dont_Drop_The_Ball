---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Create OrbBehavior Abstract Base Class

## Description
Create the abstract `OrbBehavior` resource class that serves as the base for all orb behaviors. This class defines the interface that concrete behaviors must implement.

## Background
The behavior system allows orbs to have pluggable functionality. Each behavior can execute on collection, process each frame, and respond to spawn events. The abstract base class defines the contract that all behaviors follow.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/orb_behavior.gd` extending Resource
2. Define virtual methods:
   - `execute(context: Dictionary) -> void` - called on collection
   - `process(orb: Node, delta: float) -> void` - called each frame
   - `on_spawn(orb: Node, progress: float) -> void` - during spawn animation
3. All methods should have empty default implementations (do nothing)
4. Add `class_name OrbBehavior` for type reference

## Dependencies
- None (this is Step 2, can run parallel with Step 1)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_orb_behavior.gd`
   - Test that base execute() is callable without crash
   - Test that process() is callable with null orb
2. **Implement minimal code to pass**
   - Create abstract OrbBehavior class with virtual methods
3. **Refactor while keeping tests green**
   - Ensure methods have correct signatures

## Acceptance Criteria

1. **Base Execute Callable**
   - Given a new OrbBehavior instance
   - When execute({}) is called with empty context
   - Then no crash occurs

2. **Process Callable**
   - Given a new OrbBehavior instance
   - When process(null, 0.016) is called
   - Then no crash occurs

3. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_orb_behavior.gd pass

## Metadata
- **Complexity**: Low
- **Labels**: core, behavior, abstract
- **Required Skills**: GDScript, Godot Resources
