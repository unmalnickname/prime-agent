import 'package:flutter/material.dart';

/// A full UI palette. Every screen reads its colors through the active
/// [ThemeController], so a palette swap re-skins the entire app live —
/// including themes generated from an arbitrary topic.
class Palette {
  final String name;
  final Color railBg;
  final Color drawerBg;
  final Color contentBg;
  final Color surface;
  final Color surfaceAlt;
  final Color accent;
  final Color text;
  final Color textDim;
  final Color green;
  final Color red;
  final Color blue;
  final Color purple;

  const Palette({
    required this.name,
    required this.railBg,
    required this.drawerBg,
    required this.contentBg,
    required this.surface,
    required this.surfaceAlt,
    required this.accent,
    required this.text,
    required this.textDim,
    required this.green,
    required this.red,
    required this.blue,
    required this.purple,
  });

  /// Generates a cohesive dark palette from any topic string: the topic hash
  /// picks a base hue, and the whole UI is derived from it — dark surfaces
  /// stepping lighter toward the content, a vivid accent, tinted semantics.
  factory Palette.fromTopic(String topic) {
    final trimmed = topic.trim().isEmpty ? 'Prime Agent' : topic.trim();
    var hash = 0;
    for (final unit in trimmed.toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    final h = (hash % 360).toDouble();
    return Palette(
      name: trimmed,
      railBg: HSLColor.fromAHSL(1, h, 0.32, 0.07).toColor(),
      drawerBg: HSLColor.fromAHSL(1, h, 0.26, 0.11).toColor(),
      contentBg: HSLColor.fromAHSL(1, h, 0.20, 0.15).toColor(),
      surface: HSLColor.fromAHSL(1, h, 0.16, 0.19).toColor(),
      surfaceAlt: HSLColor.fromAHSL(1, h, 0.13, 0.24).toColor(),
      accent: HSLColor.fromAHSL(1, h, 0.88, 0.62).toColor(),
      text: HSLColor.fromAHSL(1, h, 0.24, 0.93).toColor(),
      textDim: HSLColor.fromAHSL(1, h, 0.18, 0.68).toColor(),
      green: HSLColor.fromAHSL(1, 150, 0.55, 0.58).toColor(),
      red: HSLColor.fromAHSL(1, 358, 0.78, 0.60).toColor(),
      blue: HSLColor.fromAHSL(1, (h + 20) % 360, 0.72, 0.64).toColor(),
      purple: HSLColor.fromAHSL(1, (h + 70) % 360, 0.70, 0.70).toColor(),
    );
  }
}

// ── Curated themes ─────────────────────────────────────────────────────

/// The original Discord-inspired warm-amber skin.
const kMausPalette = Palette(
  name: 'Maus Dark',
  railBg: Color(0xFF141518),
  drawerBg: Color(0xFF1D1F24),
  contentBg: Color(0xFF26282D),
  surface: Color(0xFF2F3238),
  surfaceAlt: Color(0xFF383B42),
  accent: Color(0xFFFFB02E),
  text: Color(0xFFE9EBEE),
  textDim: Color(0xFFA0A6B0),
  green: Color(0xFF43B581),
  red: Color(0xFFF04747),
  blue: Color(0xFF7289DA),
  purple: Color(0xFF9B7BFF),
);

/// Weyland-Yutani Corporation — "Building Better Worlds". Corporate steel
/// blues over deep-space navy, with the WY logo blue as the accent.
const kWeylandYutaniPalette = Palette(
  name: 'Weyland-Yutani',
  railBg: Color(0xFF0A0E13),
  drawerBg: Color(0xFF101720),
  contentBg: Color(0xFF16202B),
  surface: Color(0xFF1D2A38),
  surfaceAlt: Color(0xFF253446),
  accent: Color(0xFF4FC3F7),
  text: Color(0xFFE6EDF5),
  textDim: Color(0xFF8FA3B8),
  green: Color(0xFF3DDC97),
  red: Color(0xFFFF5B5B),
  blue: Color(0xFF4FA3FF),
  purple: Color(0xFFB388FF),
);

const kCuratedThemes = <Palette>[
  kMausPalette,
  kWeylandYutaniPalette,
];

// ── Controller ─────────────────────────────────────────────────────────

/// Holds the active palette. Screens read colors via the legacy `k*` getters
/// (app_theme.dart), which delegate here; notifying rebuilds the shell.
class ThemeController extends ChangeNotifier {
  Palette palette = kMausPalette;
  String? topic;

  void setCurated(Palette p) {
    palette = p;
    topic = null;
    notifyListeners();
  }

  /// "Give me a theme based on X" — any topic generates a fresh palette.
  void setTopic(String topicName) {
    palette = Palette.fromTopic(topicName);
    topic = topicName.trim();
    notifyListeners();
  }
}

final themeController = ThemeController();
