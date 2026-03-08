#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$ROOT_DIR"
echo "[import] Using: $GODOT $HEADLESS_FLAG"

"$GODOT" $HEADLESS_FLAG --path "$ROOT_DIR" --import
echo "[import] Done."
