import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/logic.dart';
import '../core/palette.dart';
import '../core/save.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';
import '../games/count_game.dart';
import '../games/feed_game.dart';
import '../games/jigsaw_game.dart';
import '../games/memory_game.dart';
import '../games/odd_one_game.dart';
import '../games/pattern_game.dart';
import '../games/shadow_game.dart';
import '../games/size_game.dart';
import 'guide.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final int level;

  const GameScreen({super.key, required this.mode, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _won = false;
  int _mistakes = 0;
  int _runId = 0;
  late Stopwatch _watch = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Save.guideSeen(widget.mode.index)) {
        _showGuide();
      }
    });
  }

  /// Kid-friendly "Kaise khele?" overlay. Auto-shows on first play of a
  /// mode, and anytime via the ? button in the top bar.
  Future<void> _showGuide() async {
    await showGameGuide(context, widget.mode);
    await Save.markGuideSeen(widget.mode.index);
  }

  void _onWin(int mistakes) {
    if (_won) return;
    setState(() {
      _won = true;
      _mistakes = mistakes;
    });
    _watch.stop();
    Sfx.play('win');
    HapticFeedback.mediumImpact();
    final int seconds = _watch.elapsed.inSeconds;
    Save.recordLevelWin(widget.mode.index, widget.level, mistakes, seconds)
        .then((_) {
      if (mounted && Save.streak > 1) Sfx.play('streak');
    });
  }

  void _replay() {
    setState(() {
      _won = false;
      _mistakes = 0;
      _runId++;
      _watch = Stopwatch()..start();
    });
  }

  void _next() {
    if (widget.level + 1 >= kLevelsPerMode) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => GameScreen(mode: widget.mode, level: widget.level + 1),
    ));
  }

  Widget _buildGame() {
    switch (widget.mode) {
      case GameMode.jigsaw:
        return JigsawGame(
          key: ValueKey<int>(_runId),
          spec: jigsawSpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.shadow:
        return ShadowGame(
          key: ValueKey<int>(_runId),
          spec: shadowSpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.memory:
        return MemoryGame(
          key: ValueKey<int>(_runId),
          spec: memorySpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.feed:
        return FeedGame(
          key: ValueKey<int>(_runId),
          spec: feedSpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.oddOne:
        return OddOneGame(
          key: ValueKey<int>(_runId),
          spec: oddOneSpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.sizeUp:
        return SizeUpGame(
          key: ValueKey<int>(_runId),
          spec: sizeUpSpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.pattern:
        return PatternGame(
          key: ValueKey<int>(_runId),
          spec: patternSpecFor(widget.level),
          onWin: _onWin,
        );
      case GameMode.count:
        return CountGame(
          key: ValueKey<int>(_runId),
          spec: countSpecFor(widget.level),
          onWin: _onWin,
        );
    }
  }

  Widget _winCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: Clay.cardDeco(radius: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BreathingAnimal(
            amount: 0.06,
            periodMs: 1200,
            child: Image.asset(
              kAnimals[widget.level % kAnimals.length].asset,
              height: 110,
            ),
          ),
          const SizedBox(height: 6),
          Text('Great job! 🎉', style: Clay.title(size: 30)),
          const SizedBox(height: 10),
          AnimatedStars(stars: starsForMistakes(_mistakes), size: 52),
          const SizedBox(height: 6),
          Text(
            'Level ${widget.level + 1} complete',
            style: Clay.title(size: 16, color: Clay.ink.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: <Widget>[
              ClayButton(
                label: 'Replay',
                emoji: '🔁',
                color: Clay.sun,
                textColor: Clay.ink,
                fontSize: 18,
                onTap: _replay,
              ),
              if (widget.level + 1 < kLevelsPerMode)
                ClayButton(
                  label: 'Next',
                  emoji: '➡️',
                  color: Clay.leaf,
                  fontSize: 18,
                  onTap: _next,
                ),
              ClayButton(
                label: 'Menu',
                emoji: '🏠',
                color: Clay.teal,
                fontSize: 18,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int m = widget.mode.index;
    return ClayPage(
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: SceneBackground(asset: kModeScenes[m])),
          Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: Text(
                        '${kModeEmojis[m]} ${kModeNames[m]}',
                        style: Clay.title(size: 22),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconClayButton(
                      icon: Icons.help_outline_rounded,
                      color: Clay.teal,
                      onTap: _showGuide,
                      size: 44,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: Clay.cardDeco(radius: 18),
                      child: Text(
                        '${widget.level + 1}/$kLevelsPerMode',
                        style: Clay.title(size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildGame(),
                ),
              ),
            ],
          ),
          if (_won) ...<Widget>[
            const ConfettiOverlay(),
            Center(child: _winCard()),
          ],
        ],
      ),
    );
  }
}
