# Game Mode System - Rough Idea

## Project Context
- Engine: Godot 4.4.1
- Language: GDScript
- Game: "Don't Drop the Ball" - A casual bouncing game where the player uses a semi-round head to bounce an object

## Core Mechanic (MUST PRESERVE)
The player bounces an object using a semi-round head, and the object can deflect sideways.

## Main Objective
Create a simple, extensible mode infrastructure that allows new game modes to be added easily, then plan the first set of modes.

## Target First Modes
1. Classic Endless (current behavior)
2. Time Attack
3. Orb Hunt
4. One additional mode chosen based on current codebase suitability (Combo Mode, Target Score, or Survival Waves)

## Mode System Requirements
- Mode-specific goals
- Mode-specific lose/win conditions
- Optional mode-specific scoring rules
- Future mode-specific orb pools or environment modifiers
- UI-friendly status reporting

## Constraints
- Preserve the core bounce mechanic
- Keep onboarding simple for casual players
- Keep diffs small
- Prefer typed GDScript
- Validate all work through ./devscripts/test.sh
- Do not add monetization in this phase

## Deliverable
Produce a concrete mode-system development plan that includes:
1. Target mode architecture
2. First 4 modes to implement and why
3. Mode-specific win/lose conditions
4. What needs to be extracted from current game flow
5. Task breakdown in safe implementation order
6. Automated verification for mode transitions and outcomes
7. Manual verification steps for each mode
8. Risks, unknowns, and fallback options
