#!/usr/bin/env bash
set -euo pipefail

echo "================================================"
echo " SPEED TAPPER — SAFE V4"
echo " Boss + PowerUp + BallTrail + ProEffects"
echo "================================================"

ROOT="$(pwd)"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$ROOT/safe_v4_backup_$STAMP"

echo
echo "[1/7] Checking project..."

if [ ! -f "pubspec.yaml" ]; then
  echo "ERROR: Run this script from the Flutter project root."
  exit 1
fi

if [ ! -d "lib" ]; then
  echo "ERROR: lib/ directory not found."
  exit 1
fi

echo "Project: $ROOT"

echo
echo "[2/7] Creating isolated backup..."

mkdir -p "$BACKUP/lib"

cp -a lib/. "$BACKUP/lib/"

echo "Backup created:"
echo "$BACKUP"

echo
echo "[3/7] Checking required original files..."

FILES=(
  "lib/main.dart"
  "lib/core/constants/game_constants.dart"
  "lib/features/game/models/brick.dart"
  "lib/features/game/models/particle.dart"
  "lib/features/game/models/power_up.dart"
  "lib/features/game/engine/power_up_engine.dart"
  "lib/features/game/engine/combo_engine.dart"
  "lib/features/game/effects/ball_trail.dart"
  "lib/features/game/effects/pro_effects.dart"
  "lib/features/game/effects/screen_effect_controller.dart"
  "lib/features/game/painters/game_painter.dart"
  "lib/features/game/widgets/game_painter.dart"
  "lib/features/game/widgets/power_up_painter.dart"
)

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "ERROR: Missing required file:"
    echo "  $f"
    echo
    echo "NO MODIFICATIONS WERE MADE."
    exit 1
  fi
done

echo "All required files exist."

echo
echo "[4/7] Removing only stale imports/references if present..."

python3 - <<'PY'
from pathlib import Path

root = Path("lib")

# IMPORTANT:
# Only files inside lib/ are touched.
# Backup directories outside lib/ are completely ignored.

main = root / "main.dart"
text = main.read_text()

# Fix duplicate/stale PowerUpPainter import only if it exists.
lines = text.splitlines()

seen = set()
out = []

for line in lines:
    stripped = line.strip()

    if stripped.startswith("import ") and "power_up_painter.dart" in stripped:
        if stripped in seen:
            continue
        seen.add(stripped)

    out.append(line)

new_text = "\n".join(out) + ("\n" if text.endswith("\n") else "")
main.write_text(new_text)

print("Safe import cleanup complete.")
PY

echo
echo "[5/7] Verifying V4 integration..."

python3 - <<'PY'
from pathlib import Path
import re

root = Path("lib")

main = (root / "main.dart").read_text()
painter = (root / "features/game/painters/game_painter.dart").read_text()
widget = (root / "features/game/widgets/game_painter.dart").read_text()

checks = {
    "Boss updater call": "_updateBoss();" in main,
    "PowerUp engine update": "PowerUpEngine.update(" in main,
    "BallTrail add": "ballTrail.add(" in main,
    "BallTrail update": "ballTrail.update();" in main,
    "ProEffects update": "ProEffects.update(proEffects);" in main,
    "ProEffects paint": "ProEffects.paint(canvas, effects);" in painter,
    "PowerUpPainter paint": "PowerUpPainter.paint(canvas, powerUps);" in painter,
    "GamePainter receives BallTrail": "ballTrail: ballTrail" in widget,
}

failed = []

for name, ok in checks.items():
    print(("  [OK] " if ok else "  [FAIL] ") + name)
    if not ok:
        failed.append(name)

if failed:
    print()
    print("V4 STOPPED.")
    print("Missing integration:")
    for item in failed:
        print(" -", item)
    raise SystemExit(1)

print()
print("All V4 integration points are present.")
PY

echo
echo "[6/7] Analyzing ONLY lib/ ..."
echo "Backup folders are intentionally excluded."

flutter analyze lib

echo
echo "[7/7] Final verification..."

if flutter analyze lib >/tmp/speed_tapper_v4_analyze.txt 2>&1; then
  echo
  echo "================================================"
  echo " V4 SAFE CHECK PASSED"
  echo "================================================"
  echo
  echo "No analyzer errors in lib/."
  echo
  echo "Backup:"
  echo "$BACKUP"
  echo
  echo "IMPORTANT:"
  echo "Do NOT delete the backup until the APK is tested."
else
  echo
  echo "================================================"
  echo " V4 CHECK FAILED"
  echo "================================================"
  echo
  cat /tmp/speed_tapper_v4_analyze.txt
  echo
  echo "Restoring original lib/ from backup..."

  rm -rf lib
  mkdir -p lib
  cp -a "$BACKUP/lib/." lib/

  echo
  echo "Original lib/ restored."
  echo "Backup kept at:"
  echo "$BACKUP"
  exit 1
fi
