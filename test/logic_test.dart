import 'package:animal_puzzle_kids/core/logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('starsForMistakes', () {
    test('0 mistakes = 3 stars', () => expect(starsForMistakes(0), 3));
    test('1-2 mistakes = 2 stars', () {
      expect(starsForMistakes(1), 2);
      expect(starsForMistakes(2), 2);
    });
    test('3+ mistakes = 1 star', () {
      expect(starsForMistakes(3), 1);
      expect(starsForMistakes(10), 1);
    });
  });

  group('isLevelUnlocked', () {
    test('level 0 always open', () {
      expect(isLevelUnlocked(0, (_) => 0), true);
    });
    test('level 1 needs stars on level 0', () {
      expect(isLevelUnlocked(1, (int l) => l == 0 ? 0 : 0), false);
      expect(isLevelUnlocked(1, (int l) => l == 0 ? 2 : 0), true);
    });
    test('negative level treated as open', () {
      expect(isLevelUnlocked(-1, (_) => 0), true);
    });
  });

  group('nextStreakCount', () {
    test('first play = 1', () {
      expect(nextStreakCount(null, 0, DateTime(2026, 8, 11)), 1);
    });
    test('same day keeps streak', () {
      expect(nextStreakCount('2026-08-11', 3, DateTime(2026, 8, 11)), 3);
    });
    test('consecutive day increments', () {
      expect(nextStreakCount('2026-08-10', 3, DateTime(2026, 8, 11)), 4);
    });
    test('gap resets to 1', () {
      expect(nextStreakCount('2026-08-01', 9, DateTime(2026, 8, 11)), 1);
    });
    test('same day with zero streak becomes 1', () {
      expect(nextStreakCount('2026-08-11', 0, DateTime(2026, 8, 11)), 1);
    });
  });

  group('stickers', () {
    test('thresholds grow by 6', () {
      expect(stickerThreshold(0), 6);
      expect(stickerThreshold(59), 360);
    });
    test('unlock check', () {
      expect(stickerUnlocked(0, 6), true);
      expect(stickerUnlocked(0, 5), false);
      expect(stickerUnlocked(59, 359), false);
      expect(stickerUnlocked(59, 360), true);
    });
  });

  group('isoDay', () {
    test('pads month and day', () {
      expect(isoDay(DateTime(2026, 8, 5)), '2026-08-05');
    });
  });

  group('nextLockedSticker', () {
    test('first locked when nothing owned', () {
      expect(nextLockedSticker(0, <int>{}), 0);
    });
    test('skips star-unlocked and owned', () {
      expect(nextLockedSticker(6, <int>{}), 1);
      expect(nextLockedSticker(6, <int>{1}), 2);
    });
    test('null when all unlocked', () {
      expect(nextLockedSticker(10000, <int>{}), null);
    });
  });
}
