import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Match the colored animal to its black shadow.
class ShadowGame extends StatefulWidget {
  final ShadowSpec spec;
  final void Function(int mistakes) onWin;

  const ShadowGame({super.key, required this.spec, required this.onWin});

  @override
  State<ShadowGame> createState() => _ShadowGameState();
}

class _ShadowGameState extends State<ShadowGame> {
  int _mistakes = 0;
  int _shakeTick = 0;
  int _wrongIndex = -1;
  bool _done = false;

  void _pick(int i) {
    if (_done) return;
    if (widget.spec.options[i] == widget.spec.target) {
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
    final List<int> options = widget.spec.options;
    final int cols = options.length <= 3 ? options.length : 3;
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                kAnimals[widget.spec.target].asset,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final int rows = (options.length / cols).ceil();
              final double aspect =
                  (c.maxWidth / cols) / (c.maxHeight / rows);
              return GridView.count(
                crossAxisCount: cols,
                childAspectRatio: aspect,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  for (int i = 0; i < options.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ShakeWidget(
                        tick: i == _wrongIndex ? _shakeTick : 0,
                        child: Pressable(
                          onTap: () => _pick(i),
                          child: Container(
                            decoration: Clay.cardDeco(),
                            padding: const EdgeInsets.all(10),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                              child: Image.asset(
                                kAnimals[options[i]].asset,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
