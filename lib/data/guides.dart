import 'levels.dart';

/// One line of a kid-friendly how-to-play guide: big emoji + tiny sentence.
class GuideStep {
  final String emoji;
  final String text;
  const GuideStep(this.emoji, this.text);
}

/// Guide for every mode: icons first, almost no reading needed.
const Map<GameMode, List<GuideStep>> kGuides = <GameMode, List<GuideStep>>{
  GameMode.jigsaw: <GuideStep>[
    GuideStep('🧩', 'Neeche se ek puzzle piece chuno'),
    GuideStep('🖼️', 'Board pe uski sahi jagah tap karo'),
    GuideStep('🎉', 'Saare pieces lagao — jeet gaye!'),
  ],
  GameMode.shadow: <GuideStep>[
    GuideStep('🦁', 'Upar ke animal ko dhyan se dekho'),
    GuideStep('🌑', 'Neeche se uski same shadow chuno'),
    GuideStep('⭐', 'Sahi shadow chuni = jeet!'),
  ],
  GameMode.memory: <GuideStep>[
    GuideStep('🃏', 'Card pe tap karke use palto'),
    GuideStep('🦁', 'Do same animals ki jodi banao'),
    GuideStep('🧠', 'Yaad rakho — kaun kahan tha!'),
  ],
  GameMode.feed: <GuideStep>[
    GuideStep('🍌', 'Pehle neeche se khana chuno'),
    GuideStep('🐰', 'Ab us animal pe tap karo jo use khata hai'),
    GuideStep('🍽️', 'Sab animals ko khila do!'),
  ],
  GameMode.oddOne: <GuideStep>[
    GuideStep('👀', 'Sab animals same hain — par ek ALAG hai'),
    GuideStep('🔍', 'Alag wale animal pe tap karo'),
    GuideStep('⚡', 'Jaldi dhundo, galti mat karo!'),
  ],
  GameMode.sizeUp: <GuideStep>[
    GuideStep('🐜', 'Pehle sabse CHHOTE animal pe tap karo'),
    GuideStep('📏', 'Phir agle chhote pe... aise badhte jao'),
    GuideStep('🐘', 'Last mein sabse BADA animal!'),
  ],
  GameMode.pattern: <GuideStep>[
    GuideStep('🚂', 'Train ka pattern dhyan se dekho'),
    GuideStep('❓', 'Khali dabbe ke liye sahi animal chuno'),
    GuideStep('🎨', 'Pattern poora karo — jeet gaye!'),
  ],
  GameMode.count: <GuideStep>[
    GuideStep('👀', 'Gin lo: kitne animals hain?'),
    GuideStep('☝️', 'Ek-ek karke ginna easy hai'),
    GuideStep('🔢', 'Sahi number pe tap karo!'),
  ],
};
