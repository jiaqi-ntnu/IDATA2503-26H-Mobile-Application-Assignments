import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meals/screens/tabs.dart';

// Global application theme configured with Material 3, a dark seed color scheme,
// and the Lato typography from Google Fonts.
final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 194, 25, 67),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() {
  runApp(
    // ProviderScope is required by Riverpod to store and manage the state of all providers.
    const ProviderScope(
      child: App(),
    ),
  );
}

// Root widget of the application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme, // Applies the dark theme across the entire application
      home:
          const TabsScreen(), // Sets TabsScreen as the initial screen with bottom tabs
    );
  }
}
