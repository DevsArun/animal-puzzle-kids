import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/logic.dart';
import '../core/palette.dart';
import '../core/save.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';

/// 60 free cosmetic stickers, unlocked with stars or the daily chest.
class StickersScreen extends StatefulWidget {
  const StickersScreen({super.key});

  @override
  State<StickersScreen> createState() => _StickersScreenState();
}

class _StickersScreenState extends State<StickersScreen> {
  void _openPreview(int animal, Color frame) {
    Sfx.play('sticker');
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: frame.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    kAnimals[animal].asset,
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 12),
                Text(kAnimals[animal].name, style: Clay.title(size: 26)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sticker(int i, int total) {
    final bool unlocked = stickerUnlocked(i, total) || Save.stickerOwned(i);
    final int animal = i % kAnimals.length;
    final Color frame = Clay.rainbow[(i ~/ kAnimals.length) % Clay.rainbow.length];
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Pressable(
        onTap: () {
          if (unlocked) {
            _openPreview(animal, frame);
          } else {
            Sfx.play('wrong');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: unlocked
                ? frame.withValues(alpha: 0.25)
                : Clay.ink.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unlocked ? frame : Colors.transparent,
              width: 3,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: unlocked
              ? Image.asset(kAnimals[animal].asset, fit: BoxFit.contain)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.lock_rounded,
                      color: Clay.ink.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stickerThreshold(i)}⭐',
                      style: Clay.title(
                        size: 13,
                        color: Clay.ink.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int total = Save.totalStars(kModeCount, kLevelsPerMode);
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
                  child: Text('Sticker Book', style: Clay.title(size: 26)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: Clay.cardDeco(radius: 18),
                  child: Text('$total⭐', style: Clay.title(size: 18)),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                final int cols =
                    math.max(4, math.min(8, (c.maxWidth / 120).floor()));
                return GridView.count(
                  crossAxisCount: cols,
                  padding: const EdgeInsets.all(12),
                  children: <Widget>[
                    for (int i = 0; i < kStickerCount; i++) _sticker(i, total),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
