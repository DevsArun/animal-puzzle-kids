import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Count the animals, tap the right number.
class CountGame extends StatefulWidget {
  final CountSpec spec;
  final void Function(int mistakes) onWin;

  const CountGame({super.key, required this.spec, required this.onWin});

  @override
  State<CountGame> createState() => _CountGameState();
}

class _CountGameState extends State<CountGame> {
  int _mistakes = 0;
  int _shakeTick = 0;
  int _wrongOption = -1;
  bool _done = false;

  void _tapOption(int n) {
    if (_done) return;
    if (n == widget.spec.count) {
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
        _wrongOption = n;
      });
      Sfx.play('wrong');
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final math.Random tiltRng =
        math.Random(widget.spec.count * 13 + widget.spec.animal);
    return Column(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Center(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < widget.spec.count; i++)
                    Transform.rotate(
                      angle: (tiltRng.nextDouble() - 0.5) * 0.24,
                      child: SizedBox(
                        width: 78,
                        height: 78,
                        child: Image.asset(
                          kAnimals[widget.spec.animal].asset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (final int n in widget.spec.options)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ShakeWidget(
                      tick: n == _wrongOption ? _shakeTick : 0,
                      child: Pressable(
                        onTap: () => _tapOption(n),
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: Clay.grape,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: Clay.softShadow(),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: Clay.title(size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
