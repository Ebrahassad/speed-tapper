#!/usr/bin/env bash
set -euo pipefail

FILE="lib/features/game/widgets/game_painter.dart"

echo "===== SAFE PAINTER PATCH V4 ====="

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="painter_v4_backup_$STAMP"

mkdir -p "$BACKUP"

cp "$FILE" "$BACKUP/game_painter.dart"

echo "Backup:"
echo "$BACKUP/game_painter.dart"

python3 - <<'PY'
from pathlib import Path

p = Path("lib/features/game/widgets/game_painter.dart")
s = p.read_text()

# ------------------------------------------------------------
# 1. Add imports only if missing
# ------------------------------------------------------------

imports = [
    "import '../models/power_up.dart';",
    "import '../effects/ball_trail.dart';",
    "import '../effects/pro_effects.dart';",
    "import 'power_up_painter.dart';",
]

anchor = "import '../models/particle.dart';"

for imp in imports:
    if imp not in s:
        s = s.replace(anchor, anchor + "\n" + imp)

# ------------------------------------------------------------
# 2. Add fields
# ------------------------------------------------------------

field_anchor = "final List<Particle> particles;"

new_fields = """final List<PowerUp> powerUps;
  final List<ProEffect> effects;
  final BallTrail ballTrail;"""

if "final List<PowerUp> powerUps;" not in s:
    s = s.replace(
        field_anchor,
        field_anchor + "\n  " + new_fields
    )

# ------------------------------------------------------------
# 3. Add constructor parameters
# ------------------------------------------------------------

constructor_anchor = "required this.particles,"

new_params = """required this.powerUps,
    required this.effects,
    required this.ballTrail,"""

if "required this.ballTrail," not in s:
    s = s.replace(
        constructor_anchor,
        constructor_anchor + "\n    " + new_params
    )

# ------------------------------------------------------------
# 4. Paint effects in correct order
#
# Background
# Atmosphere
# Bricks
# Ball trail
# Ball
# Paddle
# PowerUps
# Particles
# Pro effects
# ------------------------------------------------------------

paint_anchor = """_paintBricks(canvas);
    _paintBall(canvas);"""

paint_replacement = """_paintBricks(canvas);
    _paintBallTrail(canvas);
    _paintBall(canvas);"""

if "_paintBallTrail(canvas);" not in s:
    s = s.replace(paint_anchor, paint_replacement)

particles_anchor = """_paintPaddle(canvas, size);
    _paintParticles(canvas);"""

particles_replacement = """_paintPaddle(canvas, size);
    PowerUpPainter.paint(canvas, powerUps);
    _paintParticles(canvas);
    ProEffects.paint(canvas, effects);"""

if "PowerUpPainter.paint(canvas, powerUps);" not in s:
    s = s.replace(
        particles_anchor,
        particles_replacement
    )

# ------------------------------------------------------------
# 5. Add BallTrail painter method before paddle section
# ------------------------------------------------------------

if "void _paintBallTrail(Canvas canvas)" not in s:

    marker = "// ============================================================\n    //"

    method = r'''// ============================================================
  // BALL TRAIL
  // ============================================================

  void _paintBallTrail(Canvas canvas) {
    if (ballTrail.points.isEmpty) return;

    final Paint trailPaint = Paint()
      ..style = PaintingStyle.fill;

    for (final point in ballTrail.points) {
      if (point.alpha <= 0) continue;

      final double radius = ballRadius * point.scale;

      trailPaint.color = GameConstants.neonCyan.withValues(
        alpha: point.alpha * 0.35,
      );

      canvas.drawCircle(
        Offset(point.x, point.y),
        radius,
        trailPaint,
      );
    }
  }

  '''

    # Insert before first major section following atmosphere/bricks.
    # Prefer insertion immediately before _paintBricks.
    target = "void _paintBricks(Canvas canvas) {"

    if target in s:
        s = s.replace(target, method + target, 1)
    else:
        raise SystemExit(
            "Could not find _paintBricks(). File was not changed."
        )

p.write_text(s)

print("Painter patch applied.")
PY

echo
echo "===== CHECKING PAINTER ====="

grep -n "power_up.dart" "$FILE" || true
grep -n "ball_trail.dart" "$FILE" || true
grep -n "pro_effects.dart" "$FILE" || true
grep -n "PowerUpPainter" "$FILE" || true
grep -n "ballTrail" "$FILE" || true
grep -n "_paintBallTrail" "$FILE" || true

echo
echo "===== ANALYZE GAME PAINTER ====="

flutter analyze lib/features/game/widgets/game_painter.dart

echo
echo "===== ANALYZE LIB ====="

flutter analyze lib

echo
echo "=========================================="
echo " V4 PAINTER PATCH FINISHED"
echo "=========================================="
echo
echo "Backup:"
echo "$BACKUP/game_painter.dart"
