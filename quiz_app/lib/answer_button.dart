import 'package:flutter/material.dart';

const double buttonWidth = 300;

class AnswerButton extends StatelessWidget {
  const new({super.key, required this.answer, required this.onTap});

  final String answer;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 33, 1, 95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            fixedSize: Size.fromWidth(buttonWidth),
          ),
          child: Text(answer),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
