import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/lang.dart';
import '../core/palette.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Kid-friendly VISUAL guide: a looping animation that SHOWS how to play
/// (a finger performs the real action), plus one tiny localized caption.
/// No reading needed - kids copy what the finger does.
Future<void> showGameGuide(BuildContext context, GameMode mode) async {
  final int m = mode.index;
  await showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${kModeEmojis[m]} ${L.modeName(m)}',
                style: Clay.title(size: 24),
              ),
              Text(
                L.t('howToPlay'),
                style:
                    Clay.title(size: 15, color: Clay.ink.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 10),
              GuideDemo(mode: mode),
              const SizedBox(height: 10),
              Text(
                L.t('guide_$m'),
                textAlign: TextAlign.center,
                style: Clay.title(size: 16),
              ),
              const SizedBox(height: 14),
              ClayButton(
                label: L.t('guideDone'),
                emoji: '🎮',
                color: Clay.leaf,
                fontSize: 20,
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DemoTile {
  final Offset at; // center position as fraction of the demo box
  final Widget child;
  final Widget? doneChild; // shown in the win phase of the loop

  const _DemoTile(this.at, this.child, {this.doneChild});
}

/// The looping "watch the finger" demo animation.
class GuideDemo extends StatefulWidget {
  final GameMode mode;

  const GuideDemo({super.key, required this.mode});

  @override
  State<GuideDemo> createState() => _GuideDemoState();
}

class _GuideDemoState extends State<GuideDemo>
    with SingleTickerProviderStateMixin {
  static const double _h = 190;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _img(int animal, {double size = 44}) {
    return Image.asset(kAnimals[animal].asset, width: size, height: size);
  }

  Widget _emoji(String e, {double size = 30}) {
    return Text(e, style: TextStyle(fontSize: size));
  }

  Widget _shadow(Widget child) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
      child: child,
    );
  }

  Widget _box(Widget child, {Color color = Colors.white}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Clay.ink.withValues(alpha: 0.15), width: 2),
        boxShadow: Clay.softShadow(alpha: 0.10),
      ),
      child: Center(child: child),
    );
  }

  /// Scene per mode: tiles, the finger path (tile indexes), the win tile.
  (List<_DemoTile>, List<int>, int) _scene() {
    switch (widget.mode) {
      case GameMode.jigsaw:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.24, 0.68), _box(_img(0, size: 40))),
            _DemoTile(
              const Offset(0.72, 0.32),
              _box(_emoji('🖼️', size: 26), color: Clay.bg),
              doneChild: _box(_img(0, size: 40)),
            ),
          ],
          <int>[0, 1],
          1,
        );
      case GameMode.shadow:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.5, 0.22), _box(_img(11))),
            _DemoTile(const Offset(0.26, 0.7), _box(_shadow(_img(2)))),
            _DemoTile(const Offset(0.74, 0.7), _box(_shadow(_img(11)))),
          ],
          <int>[2],
          2,
        );
      case GameMode.memory:
        return (
          <_DemoTile>[
            _DemoTile(
              const Offset(0.3, 0.55),
              _box(_emoji('🐾'), color: Clay.coral),
              doneChild: _box(_img(10)),
            ),
            _DemoTile(
              const Offset(0.7, 0.55),
              _box(_emoji('🐾'), color: Clay.coral),
              doneChild: _box(_img(10)),
            ),
          ],
          <int>[0, 1],
          1,
        );
      case GameMode.feed:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.24, 0.68), _box(_emoji('🍌', size: 34))),
            _DemoTile(const Offset(0.72, 0.32), _box(_img(7, size: 44))),
          ],
          <int>[0, 1],
          1,
        );
      case GameMode.oddOne:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.2, 0.55), _box(_img(0))),
            _DemoTile(const Offset(0.5, 0.55), _box(_img(0))),
            _DemoTile(const Offset(0.8, 0.55), _box(_img(2))),
          ],
          <int>[2],
          2,
        );
      case GameMode.sizeUp:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.2, 0.6), _box(_img(11, size: 26))),
            _DemoTile(const Offset(0.5, 0.6), _box(_img(7, size: 36))),
            _DemoTile(const Offset(0.8, 0.6), _box(_img(1, size: 50))),
          ],
          <int>[0, 1, 2],
          2,
        );
      case GameMode.pattern:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.14, 0.3), _box(_img(0, size: 36))),
            _DemoTile(const Offset(0.34, 0.3), _box(_img(7, size: 36))),
            _DemoTile(const Offset(0.54, 0.3), _box(_img(0, size: 36))),
            _DemoTile(
              const Offset(0.74, 0.3),
              _box(_emoji('❓', size: 26), color: Clay.bg),
              doneChild: _box(_img(7, size: 36)),
            ),
            _DemoTile(
              const Offset(0.5, 0.76),
              _box(_img(7, size: 36), color: Clay.teal.withValues(alpha: 0.25)),
            ),
          ],
          <int>[4, 3],
          3,
        );
      case GameMode.count:
        return (
          <_DemoTile>[
            _DemoTile(const Offset(0.24, 0.28), _box(_img(8, size: 36))),
            _DemoTile(const Offset(0.5, 0.28), _box(_img(8, size: 36))),
            _DemoTile(const Offset(0.76, 0.28), _box(_img(8, size: 36))),
            _DemoTile(
              const Offset(0.5, 0.74),
              _box(Text('3', style: Clay.title(size: 28)), color: Clay.grape.withValues(alpha: 0.2)),
              doneChild: _box(Text('3', style: Clay.title(size: 28, color: Colors.white)), color: Clay.leaf),
            ),
          ],
          <int>[0, 1, 2, 3],
          3,
        );
    }
  }

  Offset _fingerAt(double t, List<_DemoTile> tiles, List<int> path) {
    final int steps = path.length;
    final double slice = 0.72 / steps;
    if (t >= 0.72) return tiles[path.last].at;
    final int k = math.min(steps - 1, (t / slice).floor());
    final double local = (t - k * slice) / slice;
    final Offset to = tiles[path[k]].at;
    const double moveStart = 0.4; // hold at the stop, then move
    if (k == 0) {
      const Offset from = Offset(-0.05, 1.15); // fly in from bottom-left
      final double m = math.min(1.0, math.max(0.0, local / moveStart));
      return Offset.lerp(from, to, Curves.easeOut.transform(m))!;
    }
    final Offset from = tiles[path[k - 1]].at;
    if (local < moveStart) return from;
    final double m =
        math.min(1.0, (local - moveStart) / (1 - moveStart));
    return Offset.lerp(from, to, Curves.easeInOut.transform(m))!;
  }

  @override
  Widget build(BuildContext context) {
    final (List<_DemoTile> tiles, List<int> path, int win) = _scene();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = c.maxWidth;
        return AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            final double t = _c.value;
            final bool done = t >= 0.75;
            final Offset f = _fingerAt(t, tiles, path);
            final double checkScale = Curves.elasticOut.transform(
              math.min(1.0, math.max(0.0, (t - 0.75) / 0.13)),
            );
            return Container(
              height: _h,
              width: w,
              decoration: BoxDecoration(
                color: Clay.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: <Widget>[
                  for (int i = 0; i < tiles.length; i++)
                    Positioned(
                      left: tiles[i].at.dx * w - 30,
                      top: tiles[i].at.dy * _h - 30,
                      child: done && tiles[i].doneChild != null
                          ? tiles[i].doneChild!
                          : tiles[i].child,
                    ),
                  if (done)
                    Positioned(
                      left: tiles[win].at.dx * w - 24,
                      top: tiles[win].at.dy * _h - 24,
                      child: Transform.scale(
                        scale: checkScale,
                        child: const Text('✅', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                  if (t < 0.85)
                    Positioned(
                      left: f.dx * w - 20,
                      top: f.dy * _h - 20,
                      child: Transform.scale(
                        scale: 1 +
                            0.06 *
                                math.sin(t * math.pi * 2 * path.length),
                        child: const Text('👆', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
