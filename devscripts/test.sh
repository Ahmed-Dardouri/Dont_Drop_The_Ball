#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"

cd "$ROOT_DIR"

"$ROOT_DIR/devscripts/import.sh"
"$ROOT_DIR/devscripts/smoke_test.sh"

if [[ ! -f "$ROOT_DIR/addons/gut/gut_cmdln.gd" ]]; then
  echo "GUT not found; smoke test passed."
  exit 0
fi

tmp="$(mktemp)"
set +e
"$GODOT" $HEADLESS_FLAG --path "$ROOT_DIR" -s addons/gut/gut_cmdln.gd -gexit 2>&1 | tee "$tmp"
code=${PIPESTATUS[0]}
set -e

if grep -q "SCRIPT ERROR" "$tmp"; then
  echo "GUT had a script error."
  exit 1
fi

if grep -q "Nothing was run" "$tmp"; then
  echo "GUT ran zero tests."
  exit 1
fi

exit "$code"
