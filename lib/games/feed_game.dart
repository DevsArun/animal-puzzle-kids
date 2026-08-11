import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Pick a food, then tap the animal that eats it.
class FeedGame extends StatefulWidget {
  final FeedSpec spec;
  final void Function(int mistakes) onWin;

  const FeedGame({super.key, required this.spec, required this.onWin});

  @override
  State<FeedGame> createState() => _FeedGameState();
}

class _FeedGameState extends State<FeedGame> {
  final Set<int> _fed = <int>{};
  String? _selectedFood;
  int _mistakes = 0;
  int _shakeTick = 0;
  int _wrongAnimal = -1;
  bool _done = false;

  void _tapAnimal(int a) {
    if (_done || _fed.contains(a)) return;
    final String? food = _selectedFood;
    if (food == null) return;
    if (kAnimals[a].food == food) {
      setState(() {
        _fed.add(a);
        _selectedFood = null;
      });
      Sfx.play('pop');
      HapticFeedback.lightImpact();
      if (_fed.length == widget.spec.animals.length) {
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
    final List<int> animals = widget.spec.animals;
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final int a in animals)
                  ShakeWidget(
                    tick: a == _wrongAnimal ? _shakeTick : 0,
                    child: Pressable(
                      onTap: () => _tapAnimal(a),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: Clay.cardDeco(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 110,
                              child: Image.asset(
                                kAnimals[a].asset,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 64,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _fed.contains(a)
                                    ? Clay.leaf.withValues(alpha: 0.25)
                                    : Clay.bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Clay.ink.withValues(alpha: 0.15),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _fed.contains(a) ? kAnimals[a].food : '🍽️',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final String food in widget.spec.tray)
                  Pressable(
                    onTap: () => setState(() => _selectedFood =
                        _selectedFood == food ? null : food),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: Clay.softShadow(alpha: 0.10),
                        border: Border.all(
                          color: _selectedFood == food
                              ? Clay.teal
                              : Colors.white,
                          width: _selectedFood == food ? 4 : 2,
                        ),
                      ),
                      child: Center(
                        child:
                            Text(food, style: const TextStyle(fontSize: 42)),
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
