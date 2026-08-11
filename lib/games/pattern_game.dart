import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Complete the animal pattern (ABAB, ABC, AABB, ABBC by tier).
class PatternGame extends StatefulWidget {
  final PatternSpec spec;
  final void Function(int mistakes) onWin;

  const PatternGame({super.key, required this.spec, required this.onWin});

  @override
  State<PatternGame> createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  final List<int> _chosen = <int>[];
  int _mistakes = 0;
  int _shakeTick = 0;
  bool _done = false;

  void _tapOption(int a) {
    if (_done) return;
    if (a == widget.spec.answers[_chosen.length]) {
      setState(() => _chosen.add(a));
      Sfx.play('pop');
      HapticFeedback.lightImpact();
      if (_chosen.length == widget.spec.answers.length) {
        _done = true;
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (mounted) widget.onWin(_mistakes);
        });
      }
    } else {
      setState(() {
        _mistakes++;
        _shakeTick++;
      });
      Sfx.play('wrong');
      HapticFeedback.mediumImpact();
    }
  }

  Widget _tile({int? animal, bool isBlank = false}) {
    return Container(
      width: 76,
      height: 76,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isBlank ? Clay.sun.withValues(alpha: 0.35) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Clay.softShadow(alpha: 0.10),
        border: Border.all(
          color: isBlank ? Clay.sun : Colors.white,
          width: 3,
        ),
      ),
      child: animal != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(kAnimals[animal].asset, fit: BoxFit.contain),
            )
          : Center(
              child: Text(
                '?',
                style: Clay.title(size: 30, color: Clay.ink.withValues(alpha: 0.45)),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int blanks = widget.spec.answers.length;
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final int a in widget.spec.sequence) _tile(animal: a),
                  for (int i = 0; i < blanks; i++)
                    _tile(
                      animal: i < _chosen.length ? _chosen[i] : null,
                      isBlank: i >= _chosen.length,
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: ShakeWidget(
              tick: _shakeTick,
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final int a in widget.spec.options)
                    Pressable(
                      onTap: () => _tapOption(a),
                      child: Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Clay.teal.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: Clay.softShadow(alpha: 0.10),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Image.asset(kAnimals[a].asset, fit: BoxFit.contain),
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
