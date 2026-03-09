README_FOR_AGENT.md

AGENT CONTRACT
You are an automated coding agent running via Claude Code + Ralph on this repository.
You have full read/write access to the repo and can execute shell commands.

You MUST:
- Treat this file as the source of truth for how to work in this project.
- Keep changes minimal and targeted to the current task.
- Validate your work using the commands listed below before claiming completion.
- Prefer code and text assets; placeholders are OK for art.

PROJECT SUMMARY
- Engine: Godot 4.x
- Language: GDScript
- Goal: Work mainly on code (.gd) and text scenes/resources (.tscn/.tres).
- The game must be runnable/testable via CLI (no editor clicking required for normal iterations).

IMPORTANT MAIN SCENE SETTING
The smoke test loads the configured Main Scene. Make sure it is set in the editor:
Project -> Project Settings -> Application -> Run -> Main Scene

REPO LAYOUT (AUTHORITATIVE)
Repo root = folder containing project.godot (this is also Godot project root, res://)

Inside the Godot project (must be under repo root so Godot can load them):
- scenes/   : .tscn scenes
- scripts/  : gameplay GDScript (.gd)
- assets/   : sprites/audio/etc (placeholders OK)
- addons/   : optional addons (e.g., GUT)
- tools/    : automation helper scripts used by CLI (e.g., tools/smoke_test.gd)

Outside runtime game content (still in repo root):
- devscripts/ : shell scripts for Ralph/CI automation (do NOT treat as game assets)

Expected automation files:
- tools/smoke_test.gd
- devscripts/_common.sh
- devscripts/import.sh
- devscripts/smoke_test.sh
- devscripts/test.sh
- devscripts/export.sh (optional)

If the repo uses different names (e.g. src/ instead of scripts/ or scripts/ instead of devscripts/),
follow the existing structure and update paths consistently.

DEFINITION OF DONE (MANDATORY COMMANDS)
Before declaring any task complete, these must pass from repo root:

1) Import step (safe to run repeatedly):
   ./devscripts/import.sh

2) Smoke test (fast boot check; must pass):
   ./devscripts/smoke_test.sh

3) Tests (falls back to smoke test if no test framework is installed):
   ./devscripts/test.sh

Optional (only if required by the task and export presets exist):
   ./devscripts/export.sh "<Preset Name>" build/output_file

Rule: If any command fails, fix the issue and rerun until all required commands succeed.

Each major step must be committed in git.

GODOT CLI REQUIREMENTS
- Godot must be callable from terminal:
  godot --version  (or)  godot4 --version

Scripts auto-detect godot4 then godot.

If detection fails, run with an explicit binary path:
  GODOT_BIN=/absolute/path/to/Godot_v4.x.x_linux.x86_64 ./devscripts/test.sh

Automation runs headlessly. Godot 4 uses --headless.



Godot may print leak warnings (ObjectDB/RID/resources in use) during headless runs; treat them as non-fatal if ./devscripts/test.sh exits 0 and GUT passes.

ASSET AND FILE FORMAT RULES (VERY IMPORTANT)
Prefer text formats:
- .tscn (text scene)
- .tres (text resource)
- .gd   (scripts)

Avoid binary formats unless explicitly requested:
- .scn
- .res

Do not modify large imported assets unless the task explicitly requires it.
Placeholders are acceptable; focus on code correctness.

CODING RULES (GDSCRIPT)
Typed GDScript:
- Use typed variables and typed function signatures where possible.
- Prefer enums/constants for state.

Keep changes small:
- Do not reformat unrelated files.
- Do not rename/move many files unless required.
- Do not change unrelated gameplay behavior.

Prefer code-driven setup:
- Prefer spawning/configuring nodes from code.
- Keep scenes small and modular.
- Avoid relying on manual drag/drop + inspector tweaking unless unavoidable.

SAFETY BOUNDARIES (MUST NOT DO)
- Do not delete major folders (scenes/, scripts/, assets/, etc.) unless explicitly instructed.
- Do not change project settings (input map, rendering settings, main scene, etc.) unless required.
- Do not introduce editor-only steps as the only way to validate correctness.
- Do not add complex systems when a simpler solution meets the requirement.

TESTING GUIDANCE
This repo uses a smoke test to ensure "the game boots headlessly":
- It loads the configured Main Scene and exits with code 0 on success.
- It exits non-zero on failure.
- Tests live under: tests/ (e.g., tests/unit, tests/integration)
- Naming convention: files start with test_ and end with .gd
- Running tests: ./devscripts/test.sh now runs GUT (not just smoke)
- .gutconfig.json is used automatically by GUT CLI (so the agent shouldn’t hardcode test dirs).

If a unit test framework (like GUT) is installed:
- ./devscripts/test.sh should run it headlessly.
- Add tests for new pure logic (state machines, movement math, inventory, etc.).
- Prefer designing gameplay logic in testable modules (minimal engine dependencies).

LOGGING / DEBUGGING
- Prefer push_error() / push_warning() for issues.
- Avoid leaving noisy print() spam in final code.
- Remove temporary debug logs before finishing a task.

EXPORTING NOTES (OPTIONAL)
Exporting requires:
- export templates installed
- an export preset defined in the editor (export_presets.cfg)

If exporting is needed:
  ./devscripts/export.sh "<Preset Name>" build/output_file

WORKING STYLE FOR RALPH LOOPS
To keep iteration stable and fast:
1) Read this file first.
2) Identify the smallest set of files to change.
3) Implement the change.
4) Run:
   ./devscripts/import.sh (if needed)
   ./devscripts/test.sh
5) Repeat until green.

Exit criteria: all required commands succeed with exit code 0.
