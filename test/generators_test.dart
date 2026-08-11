import 'package:animal_puzzle_kids/data/animals.dart';
import 'package:animal_puzzle_kids/data/levels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('512 levels exist and are valid', () {
    test('every mode generates 64 valid specs', () {
      for (int level = 0; level < kLevelsPerMode; level++) {
        final int tier = level ~/ 16;

        // Jigsaw
        final JigsawSpec j = jigsawSpecFor(level);
        expect(j.gridSize, <int>[2, 3, 4, 5][tier]);
        expect(j.animal, inInclusiveRange(0, kAnimals.length - 1));

        // Shadow
        final ShadowSpec s = shadowSpecFor(level);
        final int expectedCount = <int>[3, 4, 5, 6][tier];
        expect(s.options.length, expectedCount);
        expect(s.options.toSet().length, expectedCount);
        expect(s.options.where((int a) => a == s.target).length, 1);

        // Memory
        final MemorySpec m = memorySpecFor(level);
        final int expectedPairs = <int>[3, 6, 8, 12][tier];
        expect(m.pairs, expectedPairs);
        expect(m.deck.length, expectedPairs * 2);
        final Map<int, int> counts = <int, int>{};
        for (final int a in m.deck) {
          counts[a] = (counts[a] ?? 0) + 1;
        }
        for (final int c in counts.values) {
          expect(c, 2);
        }

        // Feed Me
        final FeedSpec f = feedSpecFor(level);
        final int expectedAnimals = <int>[2, 3, 4, 4][tier];
        expect(f.animals.length, expectedAnimals);
        final Set<String> foods = <String>{};
        for (final int a in f.animals) {
          expect(foods.contains(kAnimals[a].food), false,
              reason: 'duplicate food in feed level $level');
          foods.add(kAnimals[a].food);
          expect(f.tray.contains(kAnimals[a].food), true);
        }
        expect(f.tray.length, f.animals.length + <int>[0, 1, 1, 2][tier]);

        // Odd One Out
        final OddOneSpec o = oddOneSpecFor(level);
        expect(o.gridCount, <int>[4, 6, 9, 12][tier]);
        expect(o.odd, isNot(o.base));
        expect(o.oddPosition, inInclusiveRange(0, o.gridCount - 1));

        // Size Line-Up
        final SizeUpSpec su = sizeUpSpecFor(level);
        final int expectedN = <int>[3, 4, 5, 6][tier];
        expect(su.answer.length, expectedN);
        expect(su.tray.length, expectedN);
        for (int i = 1; i < su.answer.length; i++) {
          expect(
            kAnimals[su.answer[i]].sizeRank >
                kAnimals[su.answer[i - 1]].sizeRank,
            true,
          );
        }
        expect(su.tray.toSet().containsAll(su.answer), true);

        // Pattern Train
        final PatternSpec p = patternSpecFor(level);
        expect(p.sequence.length + p.answers.length, tier == 0 ? 6 : 8);
        expect(p.answers.length, tier == 0 ? 1 : 2);
        for (final int a in p.answers) {
          expect(p.options.contains(a), true);
        }
        expect(p.options.toSet().length, p.options.length);

        // Count & Tap
        final CountSpec c = countSpecFor(level);
        final List<int> range = <List<int>>[
          <int>[1, 4],
          <int>[5, 7],
          <int>[8, 10],
          <int>[9, 12],
        ][tier];
        expect(c.count, inInclusiveRange(range[0], range[1]));
        expect(c.options.contains(c.count), true);
        expect(c.options.length, 3);
        expect(c.options.toSet().length, 3);
      }
    });
  });

  group('deterministic', () {
    test('same level always gives same spec', () {
      expect(jigsawSpecFor(5).animal, jigsawSpecFor(5).animal);
      expect(shadowSpecFor(20).options, shadowSpecFor(20).options);
      expect(memorySpecFor(40).deck, memorySpecFor(40).deck);
      expect(countSpecFor(63).options, countSpecFor(63).options);
    });
  });

  group('animal data', () {
    test('12 animals with unique size ranks 1..12', () {
      expect(kAnimals.length, 12);
      final List<int> ranks =
          kAnimals.map((Animal a) => a.sizeRank).toList()..sort();
      expect(ranks, List<int>.generate(12, (int i) => i + 1));
    });
    test('asset paths follow the convention', () {
      for (final Animal a in kAnimals) {
        expect(a.asset.startsWith('assets/animals/'), true);
        expect(a.asset.endsWith('.png'), true);
      }
    });
  });
}
