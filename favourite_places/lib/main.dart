// App entry point. Builds the global dark theme (colour scheme and fonts) and
// starts the app inside a Riverpod ProviderScope.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:favorite_places/screens/places.dart';

// Dark palette derived from a single purple seed colour. The background is
// overridden with a lighter grey-purple so screens are not pure black.
final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 102, 6, 247),
  background: const Color.fromARGB(255, 56, 49, 66),
);

// App-wide theme: Material 3, the custom background above, and Ubuntu Condensed
// (bold) for the three title text styles used throughout the app.
final theme = ThemeData().copyWith(
  useMaterial3: true,
  scaffoldBackgroundColor: colorScheme.background,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
  ),
);

/// Boots the app. `ProviderScope` makes every Riverpod provider (such as
/// `userPlacesProvider`) available to the widgets below it.
void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

/// Root widget: applies [theme] to `MaterialApp` and shows the places overview
/// screen as the home route.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Great Places',
      theme: theme,
      home: const PlacesScreen(),
    );
  }
}
