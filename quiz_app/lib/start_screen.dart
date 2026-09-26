import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
  const new(this.changeScreen, {super.key});

  final void Function() changeScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/quiz-logo.png",
          width: 300,
          color: const Color.fromARGB(151, 255, 255, 255),
        ),
        const SizedBox(height: 80),
        Text(
          "Learn Flutter the Fun Way!",
          style: GoogleFonts.lato(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: changeScreen,
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
          icon: const Icon(Icons.arrow_right_alt),
          label: Text("Start Quiz"),
        ),
      ],
    );
  }
}
