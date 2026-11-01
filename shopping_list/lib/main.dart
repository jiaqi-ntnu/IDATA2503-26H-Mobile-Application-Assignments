import 'package:flutter/material.dart';

import 'package:shopping_list/widgets/grocery_list.dart';

/// The entry point of the Flutter application.
/// It initializes and runs the root widget [MyApp].
void main() {
  runApp(const MyApp());
}

/// [MyApp] is the root widget of the entire application.
/// It configures the overall theme, application title, and initial home screen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The title of the application used by the OS task switcher.
      title: 'Flutter Groceries',
      // Configure dark theme styling with custom seed colors and background.
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
      ),
      // Sets the initial home page to display the grocery list screen.
      home: const GroceryList(),
    );
  }
}
