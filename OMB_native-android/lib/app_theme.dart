import 'package:flutter/material.dart';

/// Discord-inspired dark palette with a warm "Maus" amber accent.
const kRailBg = Color(0xFF141518);
const kDrawerBg = Color(0xFF1D1F24);
const kContentBg = Color(0xFF26282D);
const kSurface = Color(0xFF2F3238);
const kSurfaceAlt = Color(0xFF383B42);
const kAccent = Color(0xFFFFB02E);
const kText = Color(0xFFE9EBEE);
const kTextDim = Color(0xFFA0A6B0);
const kGreen = Color(0xFF43B581);
const kRed = Color(0xFFF04747);
const kBlue = Color(0xFF7289DA);
const kPurple = Color(0xFF9B7BFF);

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kContentBg,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      secondary: kBlue,
      surface: kSurface,
      error: kRed,
      onPrimary: Colors.black,
      onSurface: kText,
      outline: Color(0xFF4A4E57),
    ),
    dividerColor: const Color(0xFF3A3D44),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: kSurfaceAlt,
      selectedColor: kAccent,
      labelStyle: const TextStyle(color: kText, fontSize: 12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    cardTheme: CardThemeData(
      color: kSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kDrawerBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kDrawerBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kContentBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceAlt,
      hintStyle: const TextStyle(color: kTextDim, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? kAccent : kSurfaceAlt),
        foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.black : kText),
        side: WidgetStateProperty.all(BorderSide.none),
        textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kSurfaceAlt,
      contentTextStyle: const TextStyle(color: kText),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
