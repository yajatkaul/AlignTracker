import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey[900]!,
      primary: Colors.grey[850]!,
      secondary: Colors.grey[800]!,
      tertiary: Colors.grey[700]!,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[850]!,
      ),
    ),
    listTileTheme: const ListTileThemeData(selectedColor: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.white));
