import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// All tiles show the same animal except one - find the odd one.
class OddOneGame extends StatefulWidget {
  final OddOneSpec spec;
  final void Function(int mistakes) onWin;

  const OddOneGame({super.key, required this.spec, required this.onWin});

  @override
  State<OddOneGame> createState() => _OddOneGameState();
}

class _OddOneGameState extends State<OddOneGame> {
  int _mistakes = 0;
  int _shakeTick = 0;
  int _wrongIndex = -1;
  bool _done = false;

  void _tap(int i) {
    if (_done) return;
    if (i == widget.spec.oddPosition) {
      setState(() => _done = true);
      Sfx.play('correct');
      HapticFeedback.mediumImpact();
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onWin(_mistakes);
      });
    } else {
      setState(() {
        _mistakes++;
        _shakeTick++;
        _wrongIndex = i;
      });
      Sfx.play('wrong');
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.spec.gridCount;
    final int cols = count <= 4 ? 2 : (count <= 6 ? 3 : (count <= 9 ? 3 : 4));
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int rows = (count / cols).ceil();
        final double aspect = (c.maxWidth / cols) / (c.maxHeight / rows);
        return GridView.count(
          crossAxisCount: cols,
          childAspectRatio: aspect,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            for (int i = 0; i < count; i++)
              Padding(
                padding: const EdgeInsets.all(8),
                child: ShakeWidget(
                  tick: i == _wrongIndex ? _shakeTick : 0,
                  child: Pressable(
                    onTap: () => _tap(i),
                    child: Container(
                      decoration: Clay.cardDeco(),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        kAnimals[i == widget.spec.oddPosition
                                ? widget.spec.odd
                                : widget.spec.base]
                            .asset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
