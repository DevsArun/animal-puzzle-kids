import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Tap the animals in order from smallest to biggest.
/// Displayed image size is proportional to the animal's real size.
class SizeUpGame extends StatefulWidget {
  final SizeUpSpec spec;
  final void Function(int mistakes) onWin;

  const SizeUpGame({super.key, required this.spec, required this.onWin});

  @override
  State<SizeUpGame> createState() => _SizeUpGameState();
}

class _SizeUpGameState extends State<SizeUpGame> {
  final List<int> _placed = <int>[];
  final Set<int> _used = <int>{};
  int _mistakes = 0;
  int _shakeTick = 0;
  int _wrongAnimal = -1;
  bool _done = false;

  double _sizeOf(int animal) => 40 + kAnimals[animal].sizeRank * 6;

  void _tapAnimal(int a) {
    if (_done || _used.contains(a)) return;
    final int expected = widget.spec.answer[_placed.length];
    if (a == expected) {
      setState(() => _placed.add(a));
      _used.add(a);
      Sfx.play('pop');
      HapticFeedback.lightImpact();
      if (_placed.length == widget.spec.answer.length) {
        _done = true;
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onWin(_mistakes);
        });
      }
    } else {
      setState(() {
        _mistakes++;
        _shakeTick++;
        _wrongAnimal = a;
      });
      Sfx.play('wrong');
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<int> answer = widget.spec.answer;
    return Column(
      children: <Widget>[
        // Podium with numbered slots, small -> big.
        Expanded(
          flex: 5,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (int i = 0; i < answer.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 120,
                            child: i < _placed.length
                                ? Image.asset(
                                    kAnimals[_placed[i]].asset,
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: i < _placed.length ? Clay.leaf : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: Clay.softShadow(alpha: 0.10),
                              border: Border.all(
                                color: Clay.ink.withValues(alpha: 0.15),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: Clay.title(
                                  size: 20,
                                  color:
                                      i < _placed.length ? Colors.white : Clay.ink,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Tray with animals at their relative display sizes.
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final int a in widget.spec.tray)
                    Opacity(
                      opacity: _used.contains(a) ? 0.25 : 1,
                      child: ShakeWidget(
                        tick: a == _wrongAnimal ? _shakeTick : 0,
                        child: Pressable(
                          onTap: () => _tapAnimal(a),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: Clay.cardDeco(),
                            child: Image.asset(
                              kAnimals[a].asset,
                              width: _sizeOf(a),
                              height: _sizeOf(a),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
