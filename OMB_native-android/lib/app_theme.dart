import 'package:flutter/material.dart';

import 'theme_palette.dart';

/// Legacy palette names, now dynamic: they delegate to the active [Palette]
/// on [themeController]. Every screen reads these, so swapping the theme
/// (including topic-generated themes) re-skins the entire app live.
Color get kRailBg => themeController.palette.railBg;
Color get kDrawerBg => themeController.palette.drawerBg;
Color get kContentBg => themeController.palette.contentBg;
Color get kSurface => themeController.palette.surface;
Color get kSurfaceAlt => themeController.palette.surfaceAlt;
Color get kAccent => themeController.palette.accent;
Color get kText => themeController.palette.text;
Color get kTextDim => themeController.palette.textDim;
Color get kGreen => themeController.palette.green;
Color get kRed => themeController.palette.red;
Color get kBlue => themeController.palette.blue;
Color get kPurple => themeController.palette.purple;

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kContentBg,
    colorScheme: ColorScheme.dark(
      primary: kAccent,
      secondary: kBlue,
      surface: kSurface,
      error: kRed,
      onPrimary: Colors.black,
      onSurface: kText,
      outline: const Color(0xFF4A4E57),
    ),
    dividerColor: const Color(0xFF3A3D44),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: kSurfaceAlt,
      selectedColor: kAccent,
      labelStyle: TextStyle(color: kText, fontSize: 12),
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
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: kDrawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kContentBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceAlt,
      hintStyle: TextStyle(color: kTextDim, fontSize: 14),
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
      contentTextStyle: TextStyle(color: kText),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
