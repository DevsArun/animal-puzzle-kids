import 'dart:math';

import 'animals.dart';

/// 8 modes x 64 levels = 512 levels.
/// Tiers: 0-15 easy (age 3-5), 16-31 medium (6-8), 32-47 hard (8-10),
/// 48-63 expert (9-12). Every level is deterministic from its seed.
const int kLevelsPerMode = 64;
const int kModeCount = 8;

enum GameMode { jigsaw, shadow, memory, feed, oddOne, sizeUp, pattern, count }

const List<String> kModeNames = <String>[
  'Jigsaw',
  'Shadow Match',
  'Memory Pairs',
  'Feed Me',
  'Odd One Out',
  'Size Line-Up',
  'Pattern Train',
  'Count & Tap',
];

const List<String> kModeEmojis = <String>[
  '🧩',
  '🌑',
  '🃏',
  '🍎',
  '🔍',
  '📏',
  '🚂',
  '🔢',
];

/// Habitat scene shown behind each game mode (clay diorama backgrounds).
const List<String> kModeScenes = <String>[
  'assets/scenes/savanna.jpg', // Jigsaw
  'assets/scenes/jungle.jpg', // Shadow Match
  'assets/scenes/farm.jpg', // Memory Pairs
  'assets/scenes/savanna.jpg', // Feed Me
  'assets/scenes/jungle.jpg', // Odd One Out
  'assets/scenes/ocean.jpg', // Size Line-Up
  'assets/scenes/farm.jpg', // Pattern Train
  'assets/scenes/ocean.jpg', // Count & Tap
];

int _seed(GameMode mode, int level) => 1000 * mode.index + 31 * level + 7;

int _tier(int level) => level ~/ 16;

List<int> _sampleOthers(Random rng, int exclude, int count, {List<int>? pool}) {
  final List<int> src =
      pool ?? List<int>.generate(kAnimals.length, (int i) => i);
  final List<int> options = src.where((int i) => i != exclude).toList()
    ..shuffle(rng);
  return options.take(count).toList();
}

// ---------------------------------------------------------------- Jigsaw

class JigsawSpec {
  final int gridSize; // gridSize x gridSize pieces
  final int animal;
  const JigsawSpec({required this.gridSize, required this.animal});
}

JigsawSpec jigsawSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.jigsaw, level));
  const List<int> sizes = <int>[2, 3, 4, 5];
  return JigsawSpec(
    gridSize: sizes[_tier(level)],
    animal: rng.nextInt(kAnimals.length),
  );
}

// ---------------------------------------------------------------- Shadow

class ShadowSpec {
  final int target;
  final List<int> options; // includes target exactly once, shuffled
  const ShadowSpec({required this.target, required this.options});
}

ShadowSpec shadowSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.shadow, level));
  final int tier = _tier(level);
  const List<int> counts = <int>[3, 4, 5, 6];
  final int target = rng.nextInt(kAnimals.length);
  final int count = counts[tier];
  List<int>? pool;
  if (tier >= 2) {
    // Harder: distractors have a similar body size.
    final Animal a = kAnimals[target];
    pool = <int>[
      for (int i = 0; i < kAnimals.length; i++)
        if ((kAnimals[i].sizeRank - a.sizeRank).abs() <= 4) i,
    ];
    if (pool.length < count) pool = null;
  }
  final List<int> others = _sampleOthers(rng, target, count - 1, pool: pool);
  final List<int> options = <int>[target, ...others]..shuffle(rng);
  return ShadowSpec(target: target, options: options);
}

// ---------------------------------------------------------------- Memory

class MemorySpec {
  final int pairs;
  final int cols;
  final List<int> deck; // length pairs*2, each animal exactly twice
  const MemorySpec({required this.pairs, required this.cols, required this.deck});
}

MemorySpec memorySpecFor(int level) {
  final Random rng = Random(_seed(GameMode.memory, level));
  final int tier = _tier(level);
  const List<int> pairCounts = <int>[3, 6, 8, 12];
  const List<int> colCounts = <int>[3, 4, 4, 6];
  final int pairs = pairCounts[tier];
  final List<int> chosen = _sampleOthers(rng, -1, pairs);
  final List<int> deck = <int>[...chosen, ...chosen]..shuffle(rng);
  return MemorySpec(pairs: pairs, cols: colCounts[tier], deck: deck);
}

// ---------------------------------------------------------------- Feed Me

class FeedSpec {
  final List<int> animals;
  final List<String> tray; // correct foods + decoys, shuffled
  const FeedSpec({required this.animals, required this.tray});
}

FeedSpec feedSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.feed, level));
  final int tier = _tier(level);
  const List<int> counts = <int>[2, 3, 4, 4];
  const List<int> decoyCounts = <int>[0, 1, 1, 2];
  final int n = counts[tier];
  // Never two animals with the same food in one level (stays unambiguous).
  final List<int> order = List<int>.generate(kAnimals.length, (int i) => i)
    ..shuffle(rng);
  final List<int> animals = <int>[];
  final Set<String> usedFoods = <String>{};
  for (final int i in order) {
    if (animals.length >= n) break;
    final String f = kAnimals[i].food;
    if (usedFoods.contains(f)) continue;
    usedFoods.add(f);
    animals.add(i);
  }
  final List<String> tray = <String>[for (final int a in animals) kAnimals[a].food];
  final List<String> decoys = <String>[...kDecoyFoods]..shuffle(rng);
  for (int d = 0; d < decoyCounts[tier]; d++) {
    tray.add(decoys[d]);
  }
  tray.shuffle(rng);
  return FeedSpec(animals: animals, tray: tray);
}

// ------------------------------------------------------------- Odd One Out

class OddOneSpec {
  final int gridCount;
  final int base;
  final int odd;
  final int oddPosition;
  const OddOneSpec({
    required this.gridCount,
    required this.base,
    required this.odd,
    required this.oddPosition,
  });
}

OddOneSpec oddOneSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.oddOne, level));
  final int tier = _tier(level);
  const List<int> counts = <int>[4, 6, 9, 12];
  final int base = rng.nextInt(kAnimals.length);
  int odd;
  if (tier >= 2) {
    // Harder: the odd animal comes from the same habitat.
    final int hab = kAnimals[base].habitat;
    final List<int> sameHab = <int>[
      for (int i = 0; i < kAnimals.length; i++)
        if (i != base && kAnimals[i].habitat == hab) i,
    ];
    if (sameHab.isNotEmpty) {
      odd = sameHab[rng.nextInt(sameHab.length)];
    } else {
      final List<int> similar = <int>[
        for (int i = 0; i < kAnimals.length; i++)
          if (i != base &&
              (kAnimals[i].sizeRank - kAnimals[base].sizeRank).abs() <= 3)
            i,
      ];
      odd = similar.isNotEmpty
          ? similar[rng.nextInt(similar.length)]
          : (base + 1) % kAnimals.length;
    }
  } else {
    odd = _sampleOthers(rng, base, 1).first;
  }
  return OddOneSpec(
    gridCount: counts[tier],
    base: base,
    odd: odd,
    oddPosition: rng.nextInt(counts[tier]),
  );
}

// ------------------------------------------------------------ Size Line-Up

class SizeUpSpec {
  final List<int> answer; // animal indexes, ascending sizeRank
  final List<int> tray; // same animals, shuffled
  const SizeUpSpec({required this.answer, required this.tray});
}

SizeUpSpec sizeUpSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.sizeUp, level));
  final int tier = _tier(level);
  const List<int> counts = <int>[3, 4, 5, 6];
  final int n = counts[tier];
  final List<int> byRank = List<int>.generate(kAnimals.length, (int i) => i)
    ..sort((int a, int b) =>
        kAnimals[a].sizeRank.compareTo(kAnimals[b].sizeRank));
  List<int> picked;
  if (tier < 2) {
    // Easy: clearly spread-out sizes.
    final double step = (byRank.length - 1) / (n - 1);
    final Set<int> idx = <int>{};
    for (int k = 0; k < n; k++) {
      idx.add((k * step).round());
    }
    picked = <int>[for (final int i in idx) byRank[i]];
  } else {
    // Hard: close sizes.
    final int start = rng.nextInt(byRank.length - n + 1);
    picked = byRank.sublist(start, start + n);
  }
  final List<int> answer = <int>[...picked]..sort(
      (int a, int b) => kAnimals[a].sizeRank.compareTo(kAnimals[b].sizeRank));
  final List<int> tray = <int>[...picked]..shuffle(rng);
  return SizeUpSpec(answer: answer, tray: tray);
}

// ----------------------------------------------------------- Pattern Train

class PatternSpec {
  final List<int> sequence; // visible animals
  final List<int> answers; // blanks to fill, in order
  final List<int> options; // selectable animals (contains all answers)
  const PatternSpec({
    required this.sequence,
    required this.answers,
    required this.options,
  });
}

PatternSpec patternSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.pattern, level));
  final int tier = _tier(level);
  final int symbols = tier == 0 ? 2 : (tier == 2 ? 2 : 3);
  final List<int> syms = _sampleOthers(rng, -1, symbols);
  List<int> unit;
  if (tier == 0) {
    unit = <int>[syms[0], syms[1]]; // ABAB
  } else if (tier == 1) {
    unit = <int>[syms[0], syms[1], syms[2]]; // ABCABC
  } else if (tier == 2) {
    unit = <int>[syms[0], syms[0], syms[1], syms[1]]; // AABB
  } else {
    unit = <int>[syms[0], syms[1], syms[1], syms[2]]; // ABBC
  }
  final int fullLen = tier == 0 ? 6 : 8;
  final int blanks = tier == 0 ? 1 : 2;
  final List<int> full = <int>[
    for (int i = 0; i < fullLen; i++) unit[i % unit.length],
  ];
  final List<int> sequence = full.sublist(0, fullLen - blanks);
  final List<int> answers = full.sublist(fullLen - blanks);
  final int optCount = tier == 3 ? 4 : 3;
  final Set<int> opts = <int>{...answers};
  while (opts.length < optCount) {
    opts.add(rng.nextInt(kAnimals.length));
  }
  final List<int> options = opts.toList()..shuffle(rng);
  return PatternSpec(sequence: sequence, answers: answers, options: options);
}

// ------------------------------------------------------------- Count & Tap

class CountSpec {
  final int count;
  final int animal;
  final List<int> options; // 3 distinct ascending options incl. count
  const CountSpec({
    required this.count,
    required this.animal,
    required this.options,
  });
}

CountSpec countSpecFor(int level) {
  final Random rng = Random(_seed(GameMode.count, level));
  final int tier = _tier(level);
  const List<List<int>> ranges = <List<int>>[
    <int>[1, 4],
    <int>[5, 7],
    <int>[8, 10],
    <int>[9, 12],
  ];
  final int lo = ranges[tier][0];
  final int hi = ranges[tier][1];
  final int count = lo + rng.nextInt(hi - lo + 1);
  final Set<int> opts = <int>{count};
  while (opts.length < 3) {
    final int c = lo - 2 + rng.nextInt(hi - lo + 5);
    if (c >= 1) opts.add(c);
  }
  final List<int> options = opts.toList()..sort();
  return CountSpec(
    count: count,
    animal: rng.nextInt(kAnimals.length),
    options: options,
  );
}
