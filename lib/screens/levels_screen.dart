import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/logic.dart';
import '../core/palette.dart';
import '../core/save.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/levels.dart';
import 'game_screen.dart';

/// Journey path: 64 levels on a winding road (snake pattern), auto-scrolls
/// to the first unfinished level. Feels like a trip, not a spreadsheet.
class LevelsScreen extends StatefulWidget {
  final GameMode mode;

  const LevelsScreen({super.key, required this.mode});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  static const double _rowH = 132;
  final ScrollController _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    final int firstOpen = _firstIncomplete();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sc.hasClients) {
        final double target = math.max(
          0.0,
          math.min(
            (firstOpen ~/ 3) * _rowH - 160.0,
            _sc.position.maxScrollExtent,
          ),
        );
        _sc.jumpTo(target);
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  int _firstIncomplete() {
    final int m = widget.mode.index;
    for (int l = 0; l < kLevelsPerMode; l++) {
      if (Save.stars(m, l) == 0) return l;
    }
    return kLevelsPerMode - 1;
  }

  List<Offset> _centers(double width) {
    const List<double> xf = <double>[0.20, 0.50, 0.80];
    final List<Offset> out = <Offset>[];
    for (int l = 0; l < kLevelsPerMode; l++) {
      final int r = l ~/ 3;
      final int c = l % 3;
      final int cc = r.isEven ? c : 2 - c;
      out.add(Offset(width * xf[cc], 90 + r * _rowH));
    }
    return out;
  }

  Future<void> _openLevel(int level) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GameScreen(mode: widget.mode, level: level),
    ));
    if (mounted) setState(() {});
  }

  Widget _node(int m, int l, int firstOpen) {
    final int s = Save.stars(m, l);
    final bool open = isLevelUnlocked(l, (int x) => Save.stars(m, x));
    final bool current = l == firstOpen && open;
    final Widget circle = Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: open ? Colors.white : Clay.ink.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: current ? Clay.sun : (open ? Clay.leaf : Colors.transparent),
          width: current ? 5 : 3,
        ),
        boxShadow: open ? Clay.softShadow(alpha: 0.12) : null,
      ),
      child: Center(
        child: open
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('${l + 1}', style: Clay.title(size: 22)),
                  StarRow(stars: s, size: 11),
                ],
              )
            : Icon(
                Icons.lock_rounded,
                color: Clay.ink.withValues(alpha: 0.3),
                size: 24,
              ),
      ),
    );
    return Pressable(
      onTap: () {
        if (open) {
          _openLevel(l);
        } else {
          Sfx.play('wrong');
        }
      },
      child: current
          ? BreathingAnimal(amount: 0.07, periodMs: 1100, child: circle)
          : circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int m = widget.mode.index;
    final int firstOpen = _firstIncomplete();
    final int rows = (kLevelsPerMode / 3).ceil();
    final double mapHeight = 90 + (rows - 1) * _rowH + 110;
    return ClayPage(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                IconClayButton(
                  icon: Icons.arrow_back_rounded,
                  color: Clay.coral,
                  onTap: () => Navigator.of(context).pop(),
                  size: 52,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${kModeEmojis[m]} ${kModeNames[m]}',
                    style: Clay.title(size: 24),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: Clay.cardDeco(radius: 18),
                  child: Text(
                    '${Save.modeStars(m, kLevelsPerMode)}⭐',
                    style: Clay.title(size: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final List<Offset> centers = _centers(c.maxWidth);
                return SingleChildScrollView(
                  controller: _sc,
                  child: SizedBox(
                    height: mapHeight,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: JourneyPathPainter(centers),
                          ),
                        ),
                        for (int l = 0; l < kLevelsPerMode; l++)
                          Positioned(
                            left: centers[l].dx - 34,
                            top: centers[l].dy - 34,
                            child: _node(m, l, firstOpen),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
