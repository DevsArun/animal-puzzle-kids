import 'dart:async';

import 'package:flutter/material.dart';

import '../core/palette.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// Classic flip-the-cards memory pairs.
class MemoryGame extends StatefulWidget {
  final MemorySpec spec;
  final void Function(int mistakes) onWin;

  const MemoryGame({super.key, required this.spec, required this.onWin});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final Set<int> _flipped = <int>{};
  final Set<int> _matched = <int>{};
  int? _first;
  bool _lock = false;
  bool _done = false;
  int _mistakes = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap(int i) {
    if (_done || _lock || _flipped.contains(i) || _matched.contains(i)) {
      return;
    }
    Sfx.play('flip');
    final List<int> deck = widget.spec.deck;
    final int? first = _first;
    if (first == null) {
      setState(() {
        _first = i;
        _flipped.add(i);
      });
      return;
    }
    setState(() {
      _flipped.add(i);
      _first = null;
      _lock = true;
    });
    if (deck[first] == deck[i]) {
      _timer = Timer(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() {
          _matched.addAll(<int>[first, i]);
          _flipped.removeAll(<int>[first, i]);
          _lock = false;
        });
        Sfx.play('pop');
        if (_matched.length == deck.length) {
          _done = true;
          Future<void>.delayed(const Duration(milliseconds: 450), () {
            if (mounted) widget.onWin(_mistakes);
          });
        }
      });
    } else {
      _timer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _flipped.removeAll(<int>[first, i]);
          _lock = false;
          _mistakes++;
        });
        Sfx.play('wrong');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<int> deck = widget.spec.deck;
    final int cols = widget.spec.cols;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int rows = (deck.length / cols).ceil();
        final double aspect = (c.maxWidth / cols) / (c.maxHeight / rows);
        return GridView.count(
          crossAxisCount: cols,
          childAspectRatio: aspect,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            for (int i = 0; i < deck.length; i++)
              Padding(
                padding: const EdgeInsets.all(6),
                child: Pressable(
                  sfx: 'flip',
                  onTap: () => _tap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _flipped.contains(i) || _matched.contains(i)
                          ? Colors.white
                          : Clay.coral,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: Clay.softShadow(alpha: 0.10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 3,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: _flipped.contains(i) || _matched.contains(i)
                        ? Image.asset(
                            kAnimals[deck[i]].asset,
                            fit: BoxFit.contain,
                          )
                        : const Center(
                            child: Text('🐾', style: TextStyle(fontSize: 34)),
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
