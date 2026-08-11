/// The 12 clay animals used across all 8 game modes.
class Animal {
  final String name;
  final String asset;

  /// 1 = smallest, 12 = biggest. All 12 ranks are unique.
  final int sizeRank;

  /// 0 savanna, 1 jungle, 2 farm, 3 water/ice.
  final int habitat;

  /// Emoji of the correct food for the Feed Me mode.
  final String food;

  const Animal({
    required this.name,
    required this.asset,
    required this.sizeRank,
    required this.habitat,
    required this.food,
  });
}

const int habitatSavanna = 0;
const int habitatJungle = 1;
const int habitatFarm = 2;
const int habitatWater = 3;

const List<Animal> kAnimals = <Animal>[
  Animal(name: 'Lion', asset: 'assets/animals/lion.png', sizeRank: 8, habitat: habitatSavanna, food: '🥩'),
  Animal(name: 'Elephant', asset: 'assets/animals/elephant.png', sizeRank: 12, habitat: habitatSavanna, food: '🍉'),
  Animal(name: 'Panda', asset: 'assets/animals/panda.png', sizeRank: 5, habitat: habitatJungle, food: '🎋'),
  Animal(name: 'Giraffe', asset: 'assets/animals/giraffe.png', sizeRank: 10, habitat: habitatSavanna, food: '🌿'),
  Animal(name: 'Zebra', asset: 'assets/animals/zebra.png', sizeRank: 7, habitat: habitatSavanna, food: '🌾'),
  Animal(name: 'Tiger', asset: 'assets/animals/tiger.png', sizeRank: 9, habitat: habitatJungle, food: '🥩'),
  Animal(name: 'Hippo', asset: 'assets/animals/hippo.png', sizeRank: 11, habitat: habitatWater, food: '🥬'),
  Animal(name: 'Monkey', asset: 'assets/animals/monkey.png', sizeRank: 4, habitat: habitatJungle, food: '🍌'),
  Animal(name: 'Penguin', asset: 'assets/animals/penguin.png', sizeRank: 2, habitat: habitatWater, food: '🐟'),
  Animal(name: 'Dolphin', asset: 'assets/animals/dolphin.png', sizeRank: 6, habitat: habitatWater, food: '🐟'),
  Animal(name: 'Fox', asset: 'assets/animals/fox.png', sizeRank: 3, habitat: habitatJungle, food: '🍗'),
  Animal(name: 'Rabbit', asset: 'assets/animals/rabbit.png', sizeRank: 1, habitat: habitatFarm, food: '🥕'),
];

/// Foods that no animal eats - used as decoys in Feed Me.
const List<String> kDecoyFoods = <String>['🍕', '🧁', '🍦', '🍩'];
