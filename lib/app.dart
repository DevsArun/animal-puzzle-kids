import 'package:flutter/material.dart';

import 'core/palette.dart';
import 'screens/home_screen.dart';

class AnimalPuzzleApp extends StatelessWidget {
  const AnimalPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Puzzle Kids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Clay.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: Clay.coral),
      ),
      home: const HomeScreen(),
    );
  }
}
