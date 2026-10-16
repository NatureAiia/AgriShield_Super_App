import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Offline farm illustrations for heroes and cards — drawn in code, so no
/// image downloads (the app must work on weak / no signal) and crisp on
/// any screen. Same artwork as the web app's FieldArt.jsx.
enum FieldArtVariant { day, sunrise, wheat, storage, map, leaf }

class FieldArt extends StatelessWidget {
  final FieldArtVariant variant;
  const FieldArt({super.key, this.variant = FieldArtVariant.day});

  /// Optional real photos: put JPGs in frontend/app/assets/photos/ with
  /// these names and they replace the drawings — no code changes needed.
  /// A missing file just keeps the drawing.
  static const photoFor = {
    FieldArtVariant.sunrise: 'onboarding',
    FieldArtVariant.day: 'home',
    FieldArtVariant.storage: 'storage',
    FieldArtVariant.leaf: 'scan',
    FieldArtVariant.map: 'map',
    FieldArtVariant.wheat: 'advice',
  };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final drawing = CustomPaint(painter: _FieldPainter(variant), size: Size.infinite);
    Widget art = Image.asset(
      'assets/photos/${photoFor[variant]}.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => drawing,
    );
    if (dark) {
      // Dim slightly so illustrations sit well on dark surfaces.
      art = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.78, 0, 0, 0, 0, //
          0, 0.78, 0, 0, 0, //
          0, 0, 0.78, 0, 0, //
          0, 0, 0, 1, 0,
        ]),
        child: art,
      );
    }
    return ClipRect(child: art);
  }
}

class _Pal {
  final List<Color> sky;
  final Color sun, hill, hill2, rowA, rowB, plant, plant2;
  const _Pal(this.sky, this.sun, this.hill, this.hill2, this.rowA, this.rowB, this.plant, this.plant2);
}

const _pals = {
  FieldArtVariant.sunrise: _Pal([Color(0xFF1F3D5C), Color(0xFFE9874C), Color(0xFFFFC978)], Color(0xFFFFF0C4),
      Color(0xFF4C7A55), Color(0xFF3A6345), Color(0xFF3F7F45), Color(0xFF2F6A39), Color(0xFF7FCF6B), Color(0xFF5FB455)),
  FieldArtVariant.day: _Pal([Color(0xFF7CC8EE), Color(0xFFBFE6F7), Color(0xFFEAF8FD)], Color(0xFFFFF7D6),
      Color(0xFF97CC86), Color(0xFF7CB871), Color(0xFF5AA64F), Color(0xFF478F40), Color(0xFF9BE27F), Color(0xFF6CC35C)),
  FieldArtVariant.wheat: _Pal([Color(0xFFF7C873), Color(0xFFFDE3A7), Color(0xFFFFF4D8)], Color(0xFFFFFBEA),
      Color(0xFFD8A646), Color(0xFFC6923A), Color(0xFFE5B453), Color(0xFFCF9A37), Color(0xFFF6D27A), Color(0xFFE0B24F)),
  FieldArtVariant.storage: _Pal([Color(0xFF9FD4EA), Color(0xFFD3EEF8), Color(0xFFF1FAFD)], Color(0xFFFFF7D6),
      Color(0xFFA9D394), Color(0xFF8FC37C), Color(0xFF69B25B), Color(0xFF57A04B), Color(0xFF9BE27F), Color(0xFF6CC35C)),
};

/// Painter works in a 400×260 design space, scaled to cover the box
/// (like CSS `object-fit: cover`).
class _FieldPainter extends CustomPainter {
  final FieldArtVariant v;
  _FieldPainter(this.v);

  static const double w = 400, h = 260;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = math.max(size.width / w, size.height / h);
    final dx = (size.width - w * scale) / 2;
    final dy = (size.height - h * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final p = _pals[v];
    if (v == FieldArtVariant.map) {
      _map(canvas);
    } else if (v == FieldArtVariant.leaf) {
      _leaf(canvas);
    } else if (v == FieldArtVariant.sunrise) {
      _sky(canvas, p!, const Offset(200, 132), 18);
      _hills(canvas, p, 140);
      _rows(canvas, p, 150);
    } else if (v == FieldArtVariant.wheat) {
      _sky(canvas, p!, const Offset(310, 60), 24);
      _clouds(canvas, 40, 0.6);
      _hills(canvas, p, 128);
      _rows(canvas, p, 138, wheat: true);
    } else if (v == FieldArtVariant.storage) {
      _sky(canvas, p!, const Offset(80, 50), 20);
      _clouds(canvas, 36, 0.85);
      _hills(canvas, p, 140);
      _barn(canvas);
      _rows(canvas, p, 150, plants: false);
    } else {
      _sky(canvas, p!, const Offset(320, 52), 22);
      _clouds(canvas, 46, 0.85);
      _hills(canvas, p, 128);
      _rows(canvas, p, 140);
    }
    canvas.restore();
  }

  void _sky(Canvas c, _Pal p, Offset sun, double r) {
    const rect = Rect.fromLTWH(0, 0, w, h);
    c.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: p.sky,
          stops: const [0, 0.6, 1],
        ).createShader(rect),
    );
    c.drawCircle(
      sun,
      r * 3,
      Paint()
        ..shader = RadialGradient(colors: [
          p.sun,
          p.sun.withValues(alpha: 0.55),
          p.sun.withValues(alpha: 0),
        ], stops: const [0, 0.45, 1])
            .createShader(Rect.fromCircle(center: sun, radius: r * 3)),
    );
    c.drawCircle(sun, r, Paint()..color = p.sun);
  }

  void _clouds(Canvas c, double y, double op) {
    final paint = Paint()..color = Colors.white.withValues(alpha: op);
    c.drawOval(Rect.fromCenter(center: Offset(70, y), width: 68, height: 22), paint);
    c.drawOval(Rect.fromCenter(center: Offset(92, y - 8), width: 44, height: 24), paint);
    c.drawOval(Rect.fromCenter(center: Offset(190, y + 18), width: 52, height: 16), paint);
    c.drawOval(Rect.fromCenter(center: Offset(206, y + 12), width: 32, height: 18), paint);
  }

  void _hills(Canvas c, _Pal p, double y) {
    final back = Path()
      ..moveTo(0, y)
      ..quadraticBezierTo(70, y - 34, 150, y - 8)
      ..quadraticBezierTo(225, y + 10, 300, y - 14)
      ..quadraticBezierTo(360, y - 34, w, y - 26)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    c.drawPath(back, Paint()..color = p.hill);
    final front = Path()
      ..moveTo(0, y + 10)
      ..quadraticBezierTo(110, y - 12, 210, y + 6)
      ..quadraticBezierTo(310, y + 24, w, y)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    c.drawPath(front, Paint()..color = p.hill2);
  }

  /// Perspective crop rows converging on a vanishing point, plus sprouts.
  void _rows(Canvas c, _Pal p, double horizon, {bool plants = true, bool wheat = false}) {
    const vx = w / 2;
    final vy = horizon - 70;
    const n = 14;
    const span = 110.0;
    c.drawRect(Rect.fromLTWH(0, horizon, w, h - horizon), Paint()..color = p.rowB);
    final t = (horizon - vy) / (h - vy);
    for (var i = -n; i < n; i++) {
      final x0 = vx + i * span * 0.5;
      final x1 = vx + (i + 1) * span * 0.5;
      final path = Path()
        ..moveTo(vx + (x0 - vx) * t, horizon)
        ..lineTo(vx + (x1 - vx) * t, horizon)
        ..lineTo(x1, h)
        ..lineTo(x0, h)
        ..close();
      c.drawPath(path, Paint()..color = i.isOdd ? p.rowA : p.rowB);
    }
    if (!plants) return;
    for (var i = -n; i < n; i++) {
      final cx = vx + (i + 0.5) * span * 0.5;
      for (var k = 0; k < 6; k++) {
        final tt = 0.15 + k * 0.17;
        final y = horizon + (h - horizon) * tt;
        final t2 = (y - vy) / (h - vy);
        final x = vx + (cx - vx) * t2;
        if (x < -20 || x > w + 20) continue;
        final s = 0.25 + tt * 1.1;
        if (wheat) {
          _stalk(c, x, y, s, p);
        } else {
          _sprout(c, x, y, s, p);
        }
      }
    }
  }

  void _rotOval(Canvas c, Offset center, double rx, double ry, double deg, Color color) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(deg * math.pi / 180);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), Paint()..color = color);
    c.restore();
  }

  void _sprout(Canvas c, double x, double y, double s, _Pal p) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    c.drawLine(Offset.zero, const Offset(0, -12), Paint()
      ..color = p.plant2
      ..strokeWidth = 1.6);
    _rotOval(c, const Offset(-5, -9), 6, 3, -30, p.plant);
    _rotOval(c, const Offset(5, -11), 6, 3, 25, p.plant2);
    c.drawOval(Rect.fromCenter(center: const Offset(0, -15), width: 6.4, height: 10), Paint()..color = p.plant);
    c.restore();
  }

  void _stalk(Canvas c, double x, double y, double s, _Pal p) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    c.drawLine(Offset.zero, const Offset(0, -18), Paint()
      ..color = p.plant2
      ..strokeWidth = 1.4);
    c.drawOval(Rect.fromCenter(center: const Offset(0, -20), width: 4.8, height: 12), Paint()..color = p.plant);
    _rotOval(c, const Offset(-3, -13), 2, 4.4, -25, p.plant);
    _rotOval(c, const Offset(3, -13), 2, 4.4, 25, p.plant);
    c.restore();
  }

  void _barn(Canvas c) {
    RRect rr(double l, double t, double ww, double hh) => RRect.fromLTRBR(l, t, l + ww, t + hh, const Radius.circular(4));
    // silos
    c.drawRRect(rr(236, 88, 34, 62), Paint()..color = const Color(0xFFE8EEF0));
    c.drawPath(Path()
      ..moveTo(236, 92)
      ..quadraticBezierTo(253, 68, 270, 92)
      ..close(), Paint()..color = const Color(0xFFC9D6DB));
    c.drawRRect(rr(276, 76, 38, 74), Paint()..color = const Color(0xFFF3F6F7));
    c.drawPath(Path()
      ..moveTo(276, 80)
      ..quadraticBezierTo(295, 52, 314, 80)
      ..close(), Paint()..color = const Color(0xFFD6E1E5));
    for (final yy in [100.0, 112.0, 124.0, 136.0]) {
      c.drawRect(Rect.fromLTWH(276, yy, 38, 1.4), Paint()..color = const Color(0xFFCFD9DD));
    }
    // barn
    c.drawPath(Path()
      ..moveTo(120, 150)
      ..lineTo(120, 108)
      ..lineTo(160, 84)
      ..lineTo(200, 108)
      ..lineTo(200, 150)
      ..close(), Paint()..color = const Color(0xFFB5523B));
    c.drawPath(
      Path()
        ..moveTo(114, 110)
        ..lineTo(160, 80)
        ..lineTo(206, 110),
      Paint()
        ..color = const Color(0xFF8F3C2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeJoin = StrokeJoin.round,
    );
    c.drawRect(const Rect.fromLTWH(146, 118, 28, 32), Paint()..color = const Color(0xFF7A2F20));
    final x = Paint()
      ..color = const Color(0xFFE9C9BD)
      ..strokeWidth = 2;
    c.drawLine(const Offset(146, 118), const Offset(174, 150), x);
    c.drawLine(const Offset(174, 118), const Offset(146, 150), x);
    c.drawRect(const Rect.fromLTWH(128, 112, 12, 10), Paint()..color = const Color(0xFFF6E0B5));
    c.drawRect(const Rect.fromLTWH(180, 112, 12, 10), Paint()..color = const Color(0xFFF6E0B5));
  }

  void _map(Canvas c) {
    const cells = [
      [0xFF4F9D4A, 0xFF6FB85F, 0xFFD9B25A, 0xFF3F8A43, 0xFF86C06E],
      [0xFF89C36F, 0xFF3F8A43, 0xFF5AA64F, 0xFFC99A3C, 0xFF5AA64F],
      [0xFFD9B25A, 0xFF5AA64F, 0xFF2F6A39, 0xFF7CB871, 0xFF3F8A43],
      [0xFF6FB85F, 0xFFC99A3C, 0xFF7CB871, 0xFF4F9D4A, 0xFFD9B25A],
    ];
    c.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFCFE3C4));
    c.save();
    c.translate(200, 130);
    c.rotate(-8 * math.pi / 180);
    c.translate(-230, -160);
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.12);
    for (var r = 0; r < cells.length; r++) {
      for (var ci = 0; ci < cells[r].length; ci++) {
        c.drawRRect(
          RRect.fromLTRBR(ci * 96.0, r * 82.0, ci * 96.0 + 92, r * 82.0 + 78, const Radius.circular(6)),
          Paint()..color = Color(cells[r][ci]),
        );
        for (var k = 0; k < 6; k++) {
          c.drawRect(Rect.fromLTWH(ci * 96.0 + 6, r * 82.0 + 8 + k * 11, 80, 2), stripe);
        }
      }
    }
    c.restore();
    final river = Path()
      ..moveTo(-10, 190)
      ..cubicTo(90, 150, 160, 230, 260, 170)
      ..cubicTo(320, 135, 380, 120, 420, 140);
    c.drawPath(
      river,
      Paint()
        ..color = const Color(0xFF7EC3E6).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
    c.drawCircle(const Offset(218, 118), 10, Paint()..color = Colors.white);
    c.drawCircle(const Offset(218, 118), 5, Paint()..color = const Color(0xFF2E6A4F));
    c.drawCircle(
      const Offset(218, 118),
      22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _leaf(Canvas c) {
    const rect = Rect.fromLTWH(0, 0, w, h);
    c.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD9F0D8), Color(0xFF9FD39A)],
        ).createShader(rect),
    );
    c.drawCircle(const Offset(320, 40), 80, Paint()..color = Colors.white.withValues(alpha: 0.35));
    c.save();
    c.translate(200, 140);
    c.rotate(-28 * math.pi / 180);
    final leaf = Path()
      ..moveTo(-150, 0)
      ..cubicTo(-90, -90, 90, -90, 150, 0)
      ..cubicTo(90, 90, -90, 90, -150, 0)
      ..close();
    c.drawPath(
      leaf,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFF7FCF6B), Color(0xFF2F7D3C)])
            .createShader(const Rect.fromLTWH(-150, -70, 300, 140)),
    );
    final vein = Paint()
      ..color = const Color(0xFFD9F5CF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    c.drawLine(const Offset(-150, 0), const Offset(150, 0), vein);
    for (final x in [-100.0, -55.0, -10.0, 35.0, 80.0]) {
      c.drawPath(Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + 25, -30, x + 45, -50), vein);
      c.drawPath(Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + 25, 30, x + 45, 50), vein);
    }
    c.drawCircle(const Offset(40, -22), 9, Paint()..color = const Color(0xFFB7791F).withValues(alpha: 0.75));
    c.drawCircle(const Offset(62, 18), 6, Paint()..color = const Color(0xFFB7791F).withValues(alpha: 0.6));
    c.restore();
    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final pth in [
      Path()..moveTo(70, 60)..lineTo(70, 40)..lineTo(90, 40),
      Path()..moveTo(330, 60)..lineTo(330, 40)..lineTo(310, 40),
      Path()..moveTo(70, 200)..lineTo(70, 220)..lineTo(90, 220),
      Path()..moveTo(330, 200)..lineTo(330, 220)..lineTo(310, 220),
    ]) {
      c.drawPath(pth, corner);
    }
  }

  @override
  bool shouldRepaint(covariant _FieldPainter old) => old.v != v;
}
