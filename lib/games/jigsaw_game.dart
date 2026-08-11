import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Tap a piece in the tray, then tap its slot on the board.
class JigsawGame extends StatefulWidget {
  final JigsawSpec spec;
  final void Function(int mistakes) onWin;

  const JigsawGame({super.key, required this.spec, required this.onWin});

  @override
  State<JigsawGame> createState() => _JigsawGameState();
}

class _JigsawGameState extends State<JigsawGame> {
  late final int _g = widget.spec.gridSize;
  late final List<int?> _slots = List<int?>.filled(_g * _g, null);
  late final List<int> _tray = List<int>.generate(_g * _g, (int i) => i)
    ..shuffle(math.Random());

  int? _selected;
  int _mistakes = 0;
  int _shakeTick = 0;
  int _wrongSlot = -1;
  bool _done = false;

  void _tapSlot(int slot) {
    if (_done || _slots[slot] != null) return;
    final int? sel = _selected;
    if (sel == null) return;
    if (sel == slot) {
      setState(() {
        _slots[slot] = sel;
        _tray.remove(sel);
        _selected = null;
      });
      Sfx.play('pop');
      if (_tray.isEmpty) {
        _done = true;
        Future<void>.delayed(const Duration(milliseconds: 450), () {
          if (mounted) widget.onWin(_mistakes);
        });
      }
    } else {
      setState(() {
        _mistakes++;
        _shakeTick++;
        _wrongSlot = slot;
        _selected = null;
      });
      Sfx.play('wrong');
      HapticFeedback.mediumImpact();
    }
  }

  Widget _piece(int piece, double full) {
    final int r = piece ~/ _g;
    final int c = piece % _g;
    return ClipRect(
      child: Align(
        alignment: Alignment(
          _g > 1 ? (c / (_g - 1)) * 2 - 1 : 0,
          _g > 1 ? (r / (_g - 1)) * 2 - 1 : 0,
        ),
        widthFactor: 1 / _g,
        heightFactor: 1 / _g,
        child: Image.asset(
          kAnimals[widget.spec.animal].asset,
          width: full,
          height: full,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildBoard(double side) {
    final double cell = side / _g;
    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        children: <Widget>[
          // faint guide image
          Positioned.fill(
            child: Opacity(
              opacity: 0.13,
              child: Image.asset(
                kAnimals[widget.spec.animal].asset,
                fit: BoxFit.contain,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: _g,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: <Widget>[
              for (int slot = 0; slot < _g * _g; slot++)
                GestureDetector(
                  onTap: () => _tapSlot(slot),
                  child: ShakeWidget(
                    tick: slot == _wrongSlot ? _shakeTick : 0,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Clay.ink.withValues(alpha: 0.18),
                          width: 2,
                        ),
                      ),
                      child: _slots[slot] != null
                          ? SizedBox(
                              width: cell,
                              height: cell,
                              child: _piece(_slots[slot]!, side),
                            )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTray() {
    const double tile = 84;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final int piece in _tray)
          Pressable(
            onTap: () => setState(
                () => _selected = _selected == piece ? null : piece),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: tile,
              height: tile,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: Clay.softShadow(alpha: 0.10),
                border: Border.all(
                  color: _selected == piece ? Clay.coral : Colors.white,
                  width: _selected == piece ? 4 : 2,
                ),
              ),
              child: _piece(piece, tile * _g),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool wide = c.maxWidth > c.maxHeight;
        final double side = wide
            ? c.maxHeight - 24
            : math.min(c.maxWidth, c.maxHeight * 0.55);
        final Widget board = _buildBoard(side);
        final Widget tray = _buildTray();
        if (wide) {
          return Row(
            children: <Widget>[
              Expanded(child: Center(child: board)),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(child: tray),
                ),
              ),
            ],
          );
        }
        return Column(
          children: <Widget>[
            Expanded(child: Center(child: board)),
            const SizedBox(height: 8),
            SizedBox(
              height: c.maxHeight * 0.4,
              child: SingleChildScrollView(child: tray),
            ),
          ],
        );
      },
    );
  }
}
