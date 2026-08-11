import 'package:audioplayers/audioplayers.dart';

/// Tiny offline sound player. Short sfx via SoundPool, plus one looping
/// ambient music track. All files bundled in assets/sfx.
class Sfx {
  Sfx._();

  static const List<String> _names = <String>[
    'tap',
    'flip',
    'pop',
    'correct',
    'wrong',
    'win',
    'sticker',
    'streak',
  ];

  static final Map<String, AudioPlayer> _players = <String, AudioPlayer>{};
  static AudioPlayer? _music;
  static bool _musicStarted = false;

  /// Global mute, driven from Save.muted at startup. Gates sfx AND music.
  static bool muted = false;

  static Future<void> init() async {
    for (final String n in _names) {
      final AudioPlayer p = AudioPlayer();
      await p.setPlayerMode(PlayerMode.lowLatency);
      await p.setReleaseMode(ReleaseMode.stop);
      _players[n] = p;
    }
    final AudioPlayer m = AudioPlayer();
    await m.setReleaseMode(ReleaseMode.loop);
    await m.setVolume(0.32);
    _music = m;
  }

  static Future<void> play(String name) async {
    if (muted) return;
    final AudioPlayer? p = _players[name];
    if (p == null) return;
    try {
      await p.stop();
      await p.play(AssetSource('sfx/$name.wav'));
    } catch (_) {
      // Audio must never crash a kids app.
    }
  }

  static Future<void> startMusic() async {
    if (muted) return;
    final AudioPlayer? m = _music;
    if (m == null) return;
    try {
      if (_musicStarted) {
        await m.resume();
      } else {
        await m.play(AssetSource('sfx/ambience.wav'));
        _musicStarted = true;
      }
    } catch (_) {}
  }

  static Future<void> stopMusic() async {
    try {
      await _music?.pause();
    } catch (_) {}
  }
}
