import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'palette.dart';
import 'sfx.dart';

/// Scale-down bounce + tap sound + haptic for any child widget.
class Pressable extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final String sfx;

  const Pressable({
    super.key,
    required this.onTap,
    required this.child,
    this.sfx = 'tap',
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: () {
        HapticFeedback.lightImpact();
        Sfx.play(widget.sfx);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

/// Big chunky button (min 72dp tall) with soft clay shadow.
class ClayButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;
  final String? emoji;
  final Color textColor;

  const ClayButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.fontSize = 22,
    this.emoji,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: Clay.softShadow(),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: 3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (emoji != null) ...<Widget>[
              Text(emoji!, style: TextStyle(fontSize: fontSize + 4)),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Clay.title(size: fontSize, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round clay icon button.
class IconClayButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const IconClayButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: Clay.softShadow(),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: 3,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.52),
      ),
    );
  }
}

/// 0-3 star row (static).
class StarRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarRow({super.key, required this.stars, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < stars ? Clay.sun : Clay.ink.withValues(alpha: 0.25),
            size: size,
          ),
      ],
    );
  }
}

/// Stars that pop in one by one (win screen).
class AnimatedStars extends StatefulWidget {
  final int stars;
  final double size;

  const AnimatedStars({super.key, required this.stars, this.size = 52});

  @override
  State<AnimatedStars> createState() => _AnimatedStarsState();
}

class _AnimatedStarsState extends State<AnimatedStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < 3; i++)
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _c,
              curve: Interval(0.2 * i, 0.55 + 0.2 * i, curve: Curves.elasticOut),
            ),
            child: Icon(
              i < widget.stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i < widget.stars
                  ? Clay.sun
                  : Clay.ink.withValues(alpha: 0.25),
              size: widget.size,
            ),
          ),
      ],
    );
  }
}

/// Gentle breathing/bounce idle animation wrapper.
class BreathingAnimal extends StatefulWidget {
  final Widget child;
  final double amount;
  final int periodMs;
  final int delayMs;

  const BreathingAnimal({
    super.key,
    required this.child,
    this.amount = 0.035,
    this.periodMs = 1900,
    this.delayMs = 0,
  });

  @override
  State<BreathingAnimal> createState() => _BreathingAnimalState();
}

class _BreathingAnimalState extends State<BreathingAnimal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.periodMs),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double s = 1 + widget.amount * math.sin(_c.value * math.pi);
        return Transform.scale(scale: s, child: child);
      },
    );
  }
}

/// Slow drifting clouds overlay. Put in a Stack; ignores touches.
class DriftingClouds extends StatefulWidget {
  const DriftingClouds({super.key});

  @override
  State<DriftingClouds> createState() => _DriftingCloudsState();
}

class _DriftingCloudsState extends State<DriftingClouds>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = c.maxWidth;
        return AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            Widget cloud(double y, double size, double off) {
              final double x = (((_c.value + off) % 1.3) - 0.15) * w;
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: 0.85,
                  child: Icon(Icons.cloud_rounded,
                      size: size, color: Colors.white),
                ),
              );
            }

            return IgnorePointer(
              child: Stack(
                children: <Widget>[
                  cloud(26, 64, 0.0),
                  cloud(96, 44, 0.45),
                  cloud(58, 84, 0.8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Full-screen habitat scene with a readability gradient on top.
class SceneBackground extends StatelessWidget {
  final String asset;

  const SceneBackground({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(asset, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Clay.bg.withValues(alpha: 0.75),
                Clay.bg.withValues(alpha: 0.10),
              ],
              stops: const <double>[0.0, 0.45],
            ),
          ),
        ),
      ],
    );
  }
}

/// Smooth winding road through [points] (world map + journey path).
class JourneyPathPainter extends CustomPainter {
  final List<Offset> points;

  const JourneyPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final Offset a = points[i - 1];
      final Offset b = points[i];
      path.quadraticBezierTo(
          a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    }
    path.lineTo(points.last.dx, points.last.dy);
    final Paint road = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, road);
    final Paint line = Paint()
      ..color = Clay.teal.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(JourneyPathPainter oldDelegate) => false;
}

/// Shake the child horizontally; increment [tick] to trigger.
class ShakeWidget extends StatefulWidget {
  final int tick;
  final Widget child;

  const ShakeWidget({super.key, required this.tick, required this.child});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tick != oldWidget.tick) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double dx =
            math.sin(_c.value * math.pi * 4) * 8 * (1 - _c.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// Full-screen falling confetti. Put it in a Stack, it ignores touches.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final List<_Piece> _pieces = _makePieces();

  static List<_Piece> _makePieces() {
    final math.Random rng = math.Random();
    return <_Piece>[
      for (int i = 0; i < 60; i++)
        _Piece(
          x: rng.nextDouble(),
          delay: rng.nextDouble() * 0.35,
          speed: 0.7 + rng.nextDouble() * 0.6,
          size: 6 + rng.nextDouble() * 8,
          color: Clay.rainbow[rng.nextInt(Clay.rainbow.length)],
          rot: rng.nextDouble() * math.pi * 2,
          circle: rng.nextBool(),
        ),
    ];
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _ConfettiPainter(_c.value, _pieces),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Piece {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final double rot;
  final bool circle;

  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.rot,
    required this.circle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Piece> pieces;

  _ConfettiPainter(this.t, this.pieces);

  @override
  void paint(Canvas canvas, Size size) {
    for (final _Piece p in pieces) {
      final double local = (t - p.delay) / (1 - p.delay);
      if (local <= 0) continue;
      final double y = -20 + local * p.speed * (size.height + 60);
      if (y > size.height + 40) continue;
      final double x = p.x * size.width + math.sin(local * 6 + p.rot) * 24;
      final double alpha = math.max(0.0, math.min(1.0, 1.0 - local));
      final Paint paint = Paint()..color = p.color.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + local * 4);
      if (p.circle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

/// Multiply-two-numbers gate before parent areas.
Future<bool> showParentalGate(BuildContext context) async {
  final math.Random rng = math.Random();
  final int a = 6 + rng.nextInt(6);
  final int b = 6 + rng.nextInt(6);
  final int answer = a * b;
  final Set<int> opts = <int>{answer};
  while (opts.length < 4) {
    opts.add(answer + rng.nextInt(11) - 5);
  }
  final List<int> options = opts.toList()..shuffle(rng);
  final bool? ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: Clay.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Parents only', style: Clay.title(size: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Solve this to continue',
              style:
                  Clay.title(size: 15, color: Clay.ink.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 12),
            Text('$a × $b = ?', style: Clay.title(size: 34)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final int o in options)
                  SizedBox(
                    width: 96,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Clay.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(o == answer),
                      child: Text(
                        '$o',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

/// Cream gradient page background used by all screens.
class ClayPage extends StatelessWidget {
  final Widget child;

  const ClayPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Clay.bgTop, Clay.bg],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
