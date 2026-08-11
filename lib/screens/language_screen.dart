import 'package:flutter/material.dart';

import '../core/lang.dart';
import '../core/palette.dart';
import '../core/save.dart';
import '../core/widgets.dart';
import 'home_screen.dart';

/// First-launch language picker: big flags, native names, zero reading needed.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _pick(BuildContext context, String code) async {
    L.current = code;
    await Save.setLang(code);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClayPage(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('🌍', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                'Choose your language',
                textAlign: TextAlign.center,
                style: Clay.title(size: 26),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final String code in L.langs)
                    Pressable(
                      onTap: () => _pick(context, code),
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: Clay.cardDeco(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              L.flags[code]!,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              L.nativeNames[code]!,
                              style: Clay.title(size: 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same picker as a dialog (used from the Parents screen).
Future<void> showLanguagePicker(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(L.t('chooseLanguage'), style: Clay.title(size: 20)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final String code in L.langs)
                    Pressable(
                      onTap: () async {
                        L.current = code;
                        await Save.setLang(code);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: Clay.cardDeco(radius: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              L.flags[code]!,
                              style: const TextStyle(fontSize: 30),
                            ),
                            Text(
                              L.nativeNames[code]!,
                              style: Clay.title(size: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
