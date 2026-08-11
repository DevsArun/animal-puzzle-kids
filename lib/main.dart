import 'package:flutter/material.dart';

import 'app.dart';
import 'core/lang.dart';
import 'core/save.dart';
import 'core/sfx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Save.init();
  L.current = Save.langCode ?? 'en';
  await Sfx.init();
  Sfx.muted = Save.muted;
  if (!Sfx.muted) {
    await Sfx.startMusic();
  }
  runApp(const AnimalPuzzleApp());
}
