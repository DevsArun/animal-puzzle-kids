/// Pure game/progress logic. Unit tested, no Flutter imports.

/// 3 stars for a perfect run, 2 for up to 2 mistakes, else 1.
int starsForMistakes(int mistakes) {
  if (mistakes <= 0) return 3;
  if (mistakes <= 2) return 2;
  return 1;
}

/// Level 0 is always open; any other level needs stars on the previous one.
bool isLevelUnlocked(int level, int Function(int level) starsOf) {
  if (level <= 0) return true;
  return starsOf(level - 1) > 0;
}

/// Daily streak: same day keeps it, consecutive day grows it, gap resets to 1.
int nextStreakCount(String? lastPlayIso, int currentStreak, DateTime now) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  if (lastPlayIso == null || lastPlayIso.isEmpty) return 1;
  final DateTime last = DateTime.parse(lastPlayIso);
  final DateTime lastDay = DateTime(last.year, last.month, last.day);
  final int diff = today.difference(lastDay).inDays;
  if (diff <= 0) return currentStreak < 1 ? 1 : currentStreak;
  if (diff == 1) return currentStreak + 1;
  return 1;
}

String isoDay(DateTime d) {
  final String m = d.month.toString().padLeft(2, '0');
  final String day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// 60 cosmetic stickers, unlocked with total stars. Free, no money involved.
const int kStickerCount = 60;

int stickerThreshold(int index) => (index + 1) * 6;

bool stickerUnlocked(int index, int totalStars) {
  return totalStars >= stickerThreshold(index);
}

/// First sticker that is neither star-unlocked nor chest-owned.
/// Returns null when all 60 are unlocked.
int? nextLockedSticker(int totalStars, Set<int> owned) {
  for (int i = 0; i < kStickerCount; i++) {
    if (owned.contains(i)) continue;
    if (stickerUnlocked(i, totalStars)) continue;
    return i;
  }
  return null;
}
