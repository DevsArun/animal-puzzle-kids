import 'package:flutter/material.dart';

/// Color palette + shared styles for the clay look.
class Clay {
  Clay._();

  static const Color bg = Color(0xFFFFF6E9);
  static const Color bgTop = Color(0xFFFFE8C2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color coral = Color(0xFFFF6B5B);
  static const Color teal = Color(0xFF2EC4B6);
  static const Color sun = Color(0xFFFFC93C);
  static const Color leaf = Color(0xFF6BCB77);
  static const Color grape = Color(0xFF9B5DE5);
  static const Color sky = Color(0xFF6FB7F5);
  static const Color ink = Color(0xFF4A3B2A);

  static const List<Color> rainbow = <Color>[coral, teal, sun, leaf, grape, sky];

  static List<BoxShadow> softShadow({double alpha = 0.16}) {
    return <BoxShadow>[
      BoxShadow(
        color: ink.withValues(alpha: alpha),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ];
  }

  static TextStyle title({double size = 28, Color color = ink}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: 0.4,
    );
  }

  static BoxDecoration cardDeco({Color color = card, double radius = 24}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: softShadow(),
    );
  }
}
