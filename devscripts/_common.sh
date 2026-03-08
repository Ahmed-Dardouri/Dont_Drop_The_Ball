#!/usr/bin/env bash
set -euo pipefail

# Repo root = parent of scripts/
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Allow overriding the Godot binary:
GODOT_BIN=/home/abyss/Desktop/GameDev/Godot_v4.4.1-stable_linux.x86_64
# ./scripts/smoke_test.sh
detect_godot_bin() {
  if [[ -n "${GODOT_BIN:-}" ]]; then
    echo "$GODOT_BIN"
    return
  fi

  if command -v godot4 >/dev/null 2>&1; then
    echo "godot4"
    return
  fi
  if command -v godot >/dev/null 2>&1; then
    echo "godot"
    return
  fi

  echo "ERROR: Could not find Godot binary. Install it or set GODOT_BIN=/path/to/godot" >&2
  exit 2
}

# Godot 4 uses --headless; Godot 3 uses --no-window
detect_headless_flag() {
  local bin="$1"
  if "$bin" --help 2>/dev/null | grep -q -- "--headless"; then
    echo "--headless"
  else
    echo "--no-window"
  fi
}

GODOT="$(detect_godot_bin)"
HEADLESS_FLAG="$(detect_headless_flag "$GODOT")"
