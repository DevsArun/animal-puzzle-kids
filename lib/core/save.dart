import 'package:shared_preferences/shared_preferences.dart';

import 'logic.dart';

/// On-device only progress store (shared_preferences, nothing else).
class Save {
  Save._();

  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static int stars(int mode, int level) => _p.getInt('s_${mode}_$level') ?? 0;

  /// Saves best stars, adds play time, updates the daily streak.
  static Future<void> recordLevelWin(
      int mode, int level, int mistakes, int seconds) async {
    final int s = starsForMistakes(mistakes);
    if (s > stars(mode, level)) {
      await _p.setInt('s_${mode}_$level', s);
    }
    await _p.setInt('play_seconds', playSeconds + seconds);
    final DateTime now = DateTime.now();
    final int ns = nextStreakCount(_p.getString('streak_last'), streak, now);
    await _p.setInt('streak_count', ns);
    await _p.setString('streak_last', isoDay(now));
  }

  static int modeStars(int mode, int levels) {
    int t = 0;
    for (int l = 0; l < levels; l++) {
      t += stars(mode, l);
    }
    return t;
  }

  static int totalStars(int modes, int levels) {
    int t = 0;
    for (int m = 0; m < modes; m++) {
      t += modeStars(m, levels);
    }
    return t;
  }

  static int modeCompleted(int mode, int levels) {
    int t = 0;
    for (int l = 0; l < levels; l++) {
      if (stars(mode, l) > 0) t++;
    }
    return t;
  }

  static int get playSeconds => _p.getInt('play_seconds') ?? 0;

  static int get streak => _p.getInt('streak_count') ?? 0;

  static bool get muted => _p.getBool('muted') ?? false;

  static Future<void> setMuted(bool v) async {
    await _p.setBool('muted', v);
  }

  // ---- Daily reward chest (free stickers, no money involved) ----

  static Set<int> ownedStickers() {
    final List<String> raw = _p.getStringList('owned_stickers') ?? <String>[];
    return raw.map(int.parse).toSet();
  }

  static bool stickerOwned(int index) => ownedStickers().contains(index);

  static bool get chestAvailableToday {
    return _p.getString('chest_last') != isoDay(DateTime.now());
  }

  /// Claims today's chest. Returns the unlocked sticker index, or null when
  /// every sticker is already unlocked.
  static Future<int?> claimChest(int totalStars) async {
    final int? idx = nextLockedSticker(totalStars, ownedStickers());
    await _p.setString('chest_last', isoDay(DateTime.now()));
    if (idx != null) {
      final List<String> raw =
          _p.getStringList('owned_stickers') ?? <String>[];
      raw.add('$idx');
      await _p.setStringList('owned_stickers', raw);
    }
    return idx;
  }

  static Future<void> resetAll() async {
    await _p.clear();
  }
}
