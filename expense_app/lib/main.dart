import 'package:expense_app/widgets/expenses.dart';
import 'package:flutter/material.dart';

var kColorSchemeDark = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Color.fromARGB(255, 255, 81, 0),
);

var kColorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromARGB(255, 77, 0, 149),
);
void main() {
  runApp(
    MaterialApp(
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: kColorSchemeDark.onPrimaryContainer,
          foregroundColor: kColorSchemeDark.primaryContainer,
        ),
        cardTheme: CardThemeData().copyWith(
          color: kColorSchemeDark.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorSchemeDark.primaryContainer,
            foregroundColor: kColorSchemeDark.onPrimaryContainer,
          ),
        ),
        colorScheme: kColorSchemeDark,
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.primaryContainer,
        ),
        cardTheme: CardThemeData().copyWith(
          color: kColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          ),
        ),
      ),
      home: Expenses(),
    ),
  );
}
