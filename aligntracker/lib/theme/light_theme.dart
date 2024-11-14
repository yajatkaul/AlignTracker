import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.white,
      primary: Colors.white,
      secondary: Colors.grey[300]!,
      tertiary: Colors.grey[200]!),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: Colors.grey[300]!)),
  listTileTheme: const ListTileThemeData(selectedColor: Colors.black),
  inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black,
    ),
  ),
);
