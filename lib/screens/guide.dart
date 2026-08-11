import 'package:flutter/material.dart';

import '../core/palette.dart';
import '../core/widgets.dart';
import '../data/guides.dart';
import '../data/levels.dart';

/// Kid-friendly "how to play" overlay: big emoji circles, 2-3 tiny steps,
/// one big button. No reading skill needed - parents can read aloud too.
Future<void> showGameGuide(BuildContext context, GameMode mode) async {
  final List<GuideStep> steps = kGuides[mode] ?? <GuideStep>[];
  final int m = mode.index;
  await showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${kModeEmojis[m]} ${kModeNames[m]}',
                style: Clay.title(size: 24),
              ),
              Text(
                'Kaise khele?',
                style:
                    Clay.title(size: 15, color: Clay.ink.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Clay.rainbow[i % Clay.rainbow.length]
                              .withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            steps[i].emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child:
                            Text(steps[i].text, style: Clay.title(size: 16)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              ClayButton(
                label: 'Samajh gaya!',
                emoji: '🎮',
                color: Clay.leaf,
                fontSize: 20,
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
