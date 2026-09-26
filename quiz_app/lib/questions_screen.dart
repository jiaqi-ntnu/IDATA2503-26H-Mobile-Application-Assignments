import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/data/questions.dart';

import 'answer_button.dart';

void onPressed() {}

const double spacingBetweenButtons = 10;

class QuestionsScreen extends StatefulWidget {
  final void Function(String answer) onSelectAnswer;

  const QuestionsScreen({super.key, required this.onSelectAnswer});

  @override
  State<StatefulWidget> createState() {
    return _QuestionsScreenState();
  }
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  int qi = 0;

  void onTap(String selectedAnswer) {
    widget.onSelectAnswer(selectedAnswer);
    setState(() {
      qi < questions.length - 1 ? qi++ : qi = 0;
    });
  }

  @override
  Widget build(context) {
    qi >= questions.length ? qi = 0 : () {};

    final currentQuestion = questions[qi];

    List<Widget> childrenData = [
      Text(
        currentQuestion.text,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          color: const Color.fromARGB(255, 201, 153, 251),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 30),
      ...currentQuestion.shuffledAnswers.map(
        (answer) => SizedBox(
          width: double.infinity,
          child: AnswerButton(answer: answer, onTap: () => onTap(answer)),
        ),
      ),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: childrenData,
    );
  }
}
