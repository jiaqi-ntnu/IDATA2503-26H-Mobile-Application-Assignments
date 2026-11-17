import 'package:flutter/material.dart';

import 'screens/hairstyle_try_on_page.dart';

// Export key components so existing imports from main.dart remain valid.
export 'models/input_image_item.dart';
export 'screens/hairstyle_try_on_page.dart';
export 'services/gemini_api_service.dart';
export 'services/image_storage_service.dart';
export 'widgets/image_preview_card.dart';

/// Application entry point.
///
/// Initializes and launches the Flutter application.
void main() {
  runApp(const HairstyleTryOnApp());
}

/// Root widget for the Hairstyle Try-On application.
///
/// Sets up the [MaterialApp] configuration, application title,
/// theme colors using Material 3, and sets the home view to [HairstyleTryOnPage].
class HairstyleTryOnApp extends StatelessWidget {
  const HairstyleTryOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hairstyle Try-On Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HairstyleTryOnPage(),
    );
  }
}
