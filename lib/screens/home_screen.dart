import 'package:flutter/material.dart';

import '../core/lang.dart';
import '../core/palette.dart';
import '../core/save.dart';
import '../core/sfx.dart';
import '../core/widgets.dart';
import '../data/animals.dart';
import '../data/levels.dart';
import 'levels_screen.dart';
import 'parents_screen.dart';
import 'stickers_screen.dart';

/// World map home: a winding path with 8 mode islands, breathing animals,
/// drifting clouds and a daily reward chest. Premium calm first impression.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _muted = Save.muted;

  Future<void> _toggleMute() async {
    final bool v = !_muted;
    await Save.setMuted(v);
    Sfx.muted = v;
    if (v) {
      await Sfx.stopMusic();
    } else {
      await Sfx.startMusic();
    }
    if (mounted) setState(() => _muted = v);
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) setState(() {});
  }

  Future<void> _openParents() async {
    final bool ok = await showParentalGate(context);
    if (!mounted) return;
    if (ok) await _open(const ParentsScreen());
  }

  Future<void> _openChest() async {
    if (!Save.chestAvailableToday) {
      Sfx.play('wrong');
      return;
    }
    Sfx.play('sticker');
    final int? idx =
        await Save.claimChest(Save.totalStars(kModeCount, kLevelsPerMode));
    if (!mounted) return;
    setState(() {});
    await showDialog<void>(
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
                const Text('🎁', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 8),
                Text(L.t('dailyChest'), style: Clay.title(size: 26)),
                const SizedBox(height: 12),
                if (idx == null)
                  Text(
                    L.t('allStickers'),
                    textAlign: TextAlign.center,
                    style: Clay.title(size: 16),
                  )
                else ...<Widget>[
                  Image.asset(
                    kAnimals[idx % kAnimals.length].asset,
                    width: 140,
                    height: 140,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    L.t('newSticker').replaceAll(
                        '@', kAnimals[idx % kAnimals.length].name),
                    style: Clay.title(size: 18),
                  ),
                ],
                const SizedBox(height: 16),
                ClayButton(
                  label: L.t('yay'),
                  color: Clay.leaf,
                  fontSize: 18,
                  onTap: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

  Widget _titlePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: Clay.cardDeco(radius: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Animal Puzzle Kids', style: Clay.title(size: 24)),
          Text(
            L.t('tagline'),
            style: Clay.title(size: 13, color: Clay.ink.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _modeNode(int m) {
    final int stars = Save.modeStars(m, kLevelsPerMode);
    return Pressable(
      onTap: () => _open(LevelsScreen(mode: GameMode.values[m])),
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Clay.rainbow[m % Clay.rainbow.length],
                  width: 5,
                ),
                boxShadow: Clay.softShadow(),
              ),
              child: Center(
                child:
                    Text(kModeEmojis[m], style: const TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: Clay.cardDeco(radius: 14),
              child: Text(
                L.modeName(m),
                textAlign: TextAlign.center,
                style: Clay.title(size: 12),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$stars⭐',
              style:
                  Clay.title(size: 12, color: Clay.ink.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(double width) {
    final List<Offset> centers = <Offset>[
      for (int m = 0; m < kModeCount; m++)
        Offset(width * (m.isEven ? 0.30 : 0.70), 170 + m * 185.0),
    ];
    final double mapHeight = 170 + (kModeCount - 1) * 185.0 + 150;
    return SizedBox(
      height: mapHeight,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(painter: JourneyPathPainter(centers)),
          ),
          Positioned(top: 6, left: 0, right: 0, child: Center(child: _titlePill())),
          Positioned(
            left: width * 0.62,
            top: 120,
            child: BreathingAnimal(
              delayMs: 300,
              child: Image.asset(kAnimals[2].asset, width: 86),
            ),
          ),
          Positioned(
            left: width * 0.06,
            top: 400,
            child: BreathingAnimal(
              delayMs: 800,
              child: Image.asset(kAnimals[7].asset, width: 80),
            ),
          ),
          Positioned(
            left: width * 0.64,
            top: 850,
            child: BreathingAnimal(
              delayMs: 500,
              child: Image.asset(kAnimals[8].asset, width: 82),
            ),
          ),
          Positioned(
            left: width * 0.06,
            top: 1050,
            child: BreathingAnimal(
              delayMs: 1100,
              child: Image.asset(kAnimals[11].asset, width: 76),
            ),
          ),
          Positioned(
            left: width * 0.60,
            top: 1240,
            child: BreathingAnimal(
              delayMs: 700,
              child: Image.asset(kAnimals[1].asset, width: 96),
            ),
          ),
          for (int m = 0; m < kModeCount; m++)
            Positioned(
              left: centers[m].dx - 55,
              top: centers[m].dy - 44,
              child: _modeNode(m),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool chestReady = Save.chestAvailableToday;
    return ClayPage(
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: DriftingClouds()),
          Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: Clay.cardDeco(radius: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text('🔥', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 6),
                          Text('${Save.streak}', style: Clay.title(size: 20)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconClayButton(
                      icon: _muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Clay.grape,
                      onTap: _toggleMute,
                      size: 52,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    return SingleChildScrollView(
                      child: _buildMap(c.maxWidth),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: _openParents,
                      icon: const Text('👪', style: TextStyle(fontSize: 18)),
                      label: Text(
                        L.t('parents'),
                        style: Clay.title(
                          size: 15,
                          color: Clay.ink.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClayButton(
                      label: L.t('stickers'),
                      emoji: '🎒',
                      color: Clay.teal,
                      fontSize: 16,
                      onTap: () => _open(const StickersScreen()),
                    ),
                    const Spacer(),
                    BreathingAnimal(
                      amount: chestReady ? 0.08 : 0.0,
                      periodMs: 1200,
                      child: Pressable(
                        onTap: _openChest,
                        child: Opacity(
                          opacity: chestReady ? 1 : 0.45,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Clay.sun,
                              shape: BoxShape.circle,
                              boxShadow: Clay.softShadow(),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 3,
                              ),
                            ),
                            child: const Center(
                              child: Text('🎁', style: TextStyle(fontSize: 30)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
