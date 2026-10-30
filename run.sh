#!/usr/bin/env bash
# Startet Kyphi. Neue oder geänderte Assets werden vorher importiert.
set -euo pipefail
cd "$(dirname "$0")"

marker=.godot/last_import
if [[ ! -f $marker ]] || [[ -n $(find assets game -newer "$marker" -print -quit) ]]; then
	godot --headless --path . --import >/dev/null 2>&1 || true
	touch "$marker"
fi

exec godot --path . "$@"
