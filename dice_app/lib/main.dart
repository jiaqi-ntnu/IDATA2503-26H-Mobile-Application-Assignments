import 'package:flutter/material.dart';

import 'gradient_container.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GradientContainer(
          colors: [
            const Color.fromARGB(255, 44, 3, 114),
            const Color.fromARGB(255, 93, 38, 189),
          ],
        ),
      ),
    ),
  );
}
