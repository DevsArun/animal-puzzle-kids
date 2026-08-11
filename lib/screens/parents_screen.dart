import 'package:flutter/material.dart';

import '../core/lang.dart';
import '../core/palette.dart';
import '../core/save.dart';
import '../core/widgets.dart';
import '../data/levels.dart';
import 'language_screen.dart';

/// Stats + privacy + language for parents. Always behind the parental gate.
class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  Future<void> _reset() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(L.t('resetTitle'), style: Clay.title(size: 20)),
          content: Text(L.t('resetBody')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(L.t('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(L.t('reset'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      await Save.resetAll();
      if (mounted) setState(() {});
    }
  }

  Future<void> _changeLanguage() async {
    await showLanguagePicker(context);
    if (mounted) setState(() {});
  }

  String _fmtTime(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${seconds % 60}s';
  }

  Widget _stat(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: Clay.cardDeco(),
        child: Column(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(value, style: Clay.title(size: 24)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Clay.title(size: 13, color: Clay.ink.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeRow(int m) {
    final int done = Save.modeCompleted(m, kLevelsPerMode);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: <Widget>[
          Text(kModeEmojis[m], style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(L.modeName(m), style: Clay.title(size: 16)),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: done / kLevelsPerMode,
                minHeight: 14,
                backgroundColor: Clay.ink.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(Clay.leaf),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$done/$kLevelsPerMode', style: Clay.title(size: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int total = Save.totalStars(kModeCount, kLevelsPerMode);
    return ClayPage(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                IconClayButton(
                  icon: Icons.arrow_back_rounded,
                  color: Clay.coral,
                  onTap: () => Navigator.of(context).pop(),
                  size: 52,
                ),
                const SizedBox(width: 12),
                Text(L.t('parents'), style: Clay.title(size: 26)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _stat('⭐', '$total', L.t('totalStars')),
                      _stat('🔥', '${Save.streak}', L.t('dayStreak')),
                      _stat('⏱️', _fmtTime(Save.playSeconds), L.t('playTime')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: Clay.cardDeco(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(L.t('progressByGame'), style: Clay.title(size: 20)),
                        const SizedBox(height: 8),
                        for (int m = 0; m < kModeCount; m++) _modeRow(m),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: Clay.cardDeco(),
                    child: Row(
                      children: <Widget>[
                        const Text('🌍', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(L.t('language'), style: Clay.title(size: 18)),
                        ),
                        TextButton(
                          onPressed: _changeLanguage,
                          child: Text(
                            '${L.flags[L.current]} ${L.nativeNames[L.current]}',
                            style: Clay.title(size: 15, color: Clay.teal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: Clay.cardDeco(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Privacy', style: Clay.title(size: 20)),
                        const SizedBox(height: 8),
                        Text(
                          L.t('privacyText'),
                          style: Clay.title(
                            size: 15,
                            color: Clay.ink.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${L.t('version')} 1.3.0 (6)',
                    style: Clay.title(
                      size: 14,
                      color: Clay.ink.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClayButton(
                    label: L.t('resetProgress'),
                    emoji: '🗑️',
                    color: Clay.coral,
                    fontSize: 18,
                    onTap: _reset,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
