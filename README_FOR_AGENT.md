README_FOR_AGENT.md

AGENT CONTRACT
You are an automated coding agent running via Claude Code + Ralph on this repository.
You have full read/write access to the repo and can execute shell commands.

You MUST:
- Treat this file as the source of truth for how to work in this project.
- Keep changes minimal and targeted to the current task.
- Validate your work using the commands listed below before claiming completion.
- Prefer code and text assets; placeholders are OK for art.
- Always add ALL files when committing (use `git add .` before commit).

================================================================================
CRITICAL: GAME MUST ALWAYS RUN
================================================================================

**THE GAME MUST ALWAYS BE ABLE TO RUN AFTER YOUR CHANGES.**

If any of these commands fail, STOP and report the error to the user immediately:
1. `./devscripts/smoke_test.sh` - Must output "[smoke] OK."
2. `./devscripts/test.sh` - Must output "All tests passed!"

**DO NOT:**
- Pretend the game works when it doesn't
- Ignore errors or warnings that indicate the game won't run
- Claim completion if the game fails to start

**When you see errors:**
1. Report them to the user immediately with the exact error message
2. Work with the user to debug and fix the issue
3. Only claim completion after ALL validation commands pass

Common issues to watch for:
- Wrong UIDs in .tres files (copying UIDs from other files)
- Scripts not inheriting from the correct base class
- Missing @export variables that exist in the resource file
- Resource files in wrong directories (e.g., ModeManager loads ALL .tres from resources/modes/)

================================================================================

================================================================================
PROJECT SUMMARY
================================================================================

Engine: Godot 4.4
Language: GDScript (typed)

Game Concept:
A physics-based arcade game where the player controls a head to keep a ball
bouncing while collecting orbs that fall from above. The ball bounces off the
player's head and half-solid orbs. Collecting orbs awards points with a combo
system that grows exponentially between ball-player hits.

Core Gameplay Loop:
1. Ball bounces on player's head
2. Orbs spawn and fall
3. Ball collects orbs (collision)
4. Combo grows with each orb collected (1, 2, 4, 8, 16...)
5. Ball hits player head -> combo resets
6. Ball hits ground -> game over

================================================================================
REPO LAYOUT (AUTHORITATIVE)
================================================================================

Repo root = folder containing project.godot (this is also Godot project root, res://)

scripts/
  core/           - Singleton managers (ScoreManager, ComboManager, ModeManager, GameState)
  data/           - Data resources (OrbData, configs, behaviors)
    behaviors/    - OrbBehavior implementations (ScoreBehavior, MovementBehavior, etc.)
  events/         - Event classes for the event system
  modes/          - Game mode implementations (EndlessMode, ModeBase)
  systems/        - Physics and input systems
    physics/      - Ball and player physics
    input/        - Player input state machine
  utils/          - Utilities (Constants, Enums, Variables, adapters)

scenes/            - .tscn scene files
  main.tscn       - Main game scene
  world.tscn      - Game world with ball, player, orbs
  hud.tscn        - HUD with score display
  generic_orb.tscn - Data-driven orb scene

resources/
  orbs/           - OrbData .tres files defining orb types
  modes/          - ModeConfig .tres files

tests/
  unit/           - Unit tests for isolated logic
  integration/    - Integration tests for system interactions

assets/            - Sprites, audio, etc. (placeholders OK)
addons/            - GUT (testing), dynamic_event_manager, phantom_camera
tools/             - CLI automation helpers (smoke_test.gd)
devscripts/        - Shell scripts for CI/automation

================================================================================
AUTOLOAD SINGLETONS (load order)
================================================================================

PhantomCameraManager - Camera system (addon)
Events               - Event bus for decoupled communication
Constants            - Game constants loaded from config
GameSaveMngr         - Save/load system
Variables            - Runtime game variables
GameState            - Game state machine (MENU, PLAYING, PAUSED, GAME_OVER)
ScoreManager         - Score tracking with signals
ModeManager          - Game mode management
EffectManager        - Timed effects system (double_value, slow_fall, etc.)
ComboManager         - Combo tracking with exponential growth

================================================================================
EVENT-DRIVEN ARCHITECTURE
================================================================================

The game uses an event system (dynamic_event_manager addon) for decoupled communication.

Creating a new event:
```gdscript
class_name MyEvent extends Event

var _data: String

func _init(data: String) -> void:
    _data = data

static func invoke(data: String) -> void:
    Events.invoke(MyEvent.new(data))
```

Listening to events:
```gdscript
func _ready() -> void:
    Events.add_listener(MyEvent, _on_my_event)

func _on_my_event(event: MyEvent) -> void:
    print(event._data)
```

Key Events:
- BallHeadHitEvent   - Ball hits player head (resets combo)
- OrbCollectedEvent  - Orb collected by ball
- GameOverEvent      - Ball hits ground
- PauseEvent         - Game pause/unpause
- ScoreChanged       - Via ScoreManager.score_changed signal

================================================================================
DATA-DRIVEN ORB SYSTEM
================================================================================

Orbs are defined via OrbData resources (.tres files) with attached behaviors.

OrbData properties:
- display_name: String
- texture: Texture2D
- scale: Vector2
- base_score: int
- lifespan: float
- rarity: Enums.OrbRarity
- collision_radius: float
- is_half_solid: bool
- behaviors: Array[OrbBehavior]

Creating a new orb type:
1. Create OrbData resource in resources/orbs/
2. Add ScoreBehavior (required for scoring)
3. Add optional behaviors (MovementBehavior, BurstBehavior, etc.)
4. Add to OrbSpawner.orb_data_array

Available Behaviors:
- ScoreBehavior         - Awards base score + combo bonus
- MovementBehavior      - Horizontal drift movement
- TimedModifierBehavior - Applies timed effects (slow_fall, double_value)
- StickyBehavior        - Dampens ball velocity on bounce
- BurstBehavior         - Destroys nearby orbs in radius
- LineClearBehavior     - Clears orbs in horizontal/vertical line

================================================================================
COMBO SYSTEM
================================================================================

Combo bonus grows exponentially between ball-player head hits:
- First orb:  +1 combo bonus
- Second orb: +2 combo bonus
- Third orb:  +4 combo bonus
- Fourth orb: +8 combo bonus
- etc.

Combo resets when:
- Ball hits player's head (BallHeadHitEvent)

FloatingScore display:
- White label: base score
- Gold label: combo bonus
- Floats up and fades out

================================================================================
DEFINITION OF DONE (MANDATORY COMMANDS)
================================================================================

Before declaring any task complete, run from repo root:

1) Import step (safe to run repeatedly):
   ./devscripts/import.sh

2) Smoke test (fast boot check; must pass):
   ./devscripts/smoke_test.sh

3) Full test suite (311 tests):
   ./devscripts/test.sh

Rule: If any command fails, fix the issue and rerun until all succeed.

================================================================================
GIT COMMIT GUIDELINES
================================================================================

IMPORTANT: Always add ALL files when committing.

Correct approach:
```bash
git add .
git status  # Verify all files are staged
git commit -m "type: description"
```

Commit message format:
- feat:     New feature
- fix:      Bug fix
- refactor: Code restructuring
- test:     Adding/updating tests
- docs:     Documentation changes
- tweak:    Minor adjustments
- chore:    Maintenance tasks

Include "AI assisted" at the end of commit messages.

================================================================================
GODOT CLI REQUIREMENTS
================================================================================

Godot must be callable from terminal:
  godot --version  (or)  godot4 --version

Scripts auto-detect godot4 then godot.

If detection fails:
  GODOT_BIN=/path/to/Godot_v4.x.x_linux.x86_64 ./devscripts/test.sh

Automation runs headlessly. Godot 4 uses --headless.

Godot may print leak warnings during headless runs; treat as non-fatal if
./devscripts/test.sh exits 0 and GUT passes.

================================================================================
ASSET AND FILE FORMAT RULES
================================================================================

Prefer text formats:
- .tscn (text scene)
- .tres (text resource)
- .gd   (scripts)

Avoid binary formats unless explicitly requested:
- .scn, .res

================================================================================
CODING RULES (GDSCRIPT)
================================================================================

Typed GDScript:
- Use typed variables and typed function signatures.
- Prefer enums/constants for state.
- Use class_name for globally accessible classes.

Keep changes small:
- Do not reformat unrelated files.
- Do not rename/move many files unless required.
- Do not change unrelated gameplay behavior.

Prefer code-driven setup:
- Prefer spawning/configuring nodes from code.
- Keep scenes small and modular.

================================================================================
TESTING GUIDANCE
================================================================================

Test structure:
- tests/unit/       - Isolated unit tests for pure logic
- tests/integration - Tests for system interactions

Naming convention:
- Files: test_*.gd
- Classes: TestClassName extends GutTest

GUT configuration in .gutconfig.json:
- Auto-discovers tests in tests/
- Runs headlessly
- Exits after completion

Key test patterns:
- Use before_each() to reset state (ScoreManager, ComboManager, EffectManager)
- Use autofree/autoqfree for nodes created in tests
- Test edge cases and boundary conditions

================================================================================
SAFETY BOUNDARIES (MUST NOT DO)
================================================================================

- Do not delete major folders unless explicitly instructed.
- Do not change project settings unless required.
- Do not introduce editor-only steps as the only validation method.
- Do not add complex systems when simpler solutions work.
- Do not leave files uncommitted after making changes.

================================================================================
EXPORT/MOBILE RESOURCE LOADING (CRITICAL)
================================================================================

**Exported/mobile builds do NOT have the same filesystem as the editor.**
Resources that load fine on desktop will silently fail on Android/iOS if
discovered or loaded via unsafe patterns.

**NEVER use these patterns for gameplay-critical resources:**

1. `DirAccess.open("res://...") + get_files()` — directory contents are NOT
   reliable on export. Files may be remapped, renamed, or bundled differently.

2. Filtering by extension (`.tres`, `.png`) and then `load(path)` — the
   extension may change on export (e.g., `.tres` → `.tres.remap`).

3. Dynamic `load(string_path)` where the path is built at runtime — if the
   path is known at authoring time, use `preload()` instead.

**ALWAYS use these export-safe patterns instead:**

- `preload("res://path/to/resource.tres")` — resolved at parse time, always works.
- `const MY_RESOURCE: ResourceType = preload(...)` — class-level const with preload.
- Explicit registries: a `const` array of preloaded resources instead of scanning.
- `@export` direct resource references in the editor for scene-assigned resources.

**Rules of thumb:**

- If a resource must exist in exported builds, it MUST be strongly referenced
  (preload, @export, or ext_resource in .tscn).
- Desktop success is NOT sufficient — always use export-safe patterns.
- When adding new resources (orbs, augments, etc.), add them to the relevant
  const registry rather than relying on directory scanning.

**Examples in this project:**

- `AugmentManager._AUGMENT_REGISTRY` — const array of preloaded AugmentData
- `AugmentChoiceUI.ICONS` — const dict of preloaded icon textures
- `HUD._LIFE_ORB_DATA` — const preload for orb texture lookup
- Behavior scripts use const preloaded PackedScene references

================================================================================
WORKING STYLE
================================================================================

1) Read this file first.
2) Evaluate the request and split into discrete tasks using TaskCreate.
3) Work through tasks one at a time, marking them in_progress and completed.
4) For each task, identify the smallest set of files to change.
5) Implement the change.
6) Run validation:
   ./devscripts/import.sh (if needed)
   ./devscripts/test.sh
7) Commit ALL files:
   git add .
   git commit -m "type: description\n\nAI assisted"
8) Repeat until all tasks are complete.

Exit criteria: All required commands succeed with exit code 0.

================================================================================
TASK WORKFLOW
================================================================================

For any non-trivial request (multiple features, bug fixes, or changes):

1. EVALUATE: Break down the request into discrete, actionable tasks.
2. CREATE: Use TaskCreate to add each task with a clear subject and description.
3. EXECUTE: Work through tasks in order, one at a time:
   - TaskUpdate(taskId, status="in_progress") before starting
   - Implement the change
   - TaskUpdate(taskId, status="completed") when done
4. TRACK: Use TaskList to monitor progress and find next available task.

Example task breakdown for "add new orb type and fix mobile UI":
- Task #1: Create OrbData resource for new orb
- Task #2: Add behavior script for new orb
- Task #3: Register orb in OrbSpawner
- Task #4: Fix mobile UI button positioning

This ensures systematic progress tracking and allows resumption if interrupted.
