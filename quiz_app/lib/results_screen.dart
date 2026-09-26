import 'package:flutter/material.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/models/quiz_question.dart';

import 'questions_summary.dart';

class ResultsScreen extends StatelessWidget {
  final List<String> chosenAnswers;
  final void Function() changeToStartScreen;

  const new({
    required this.chosenAnswers,
    required this.changeToStartScreen,
    super.key,
  });

  List<Map<String, Object>> get summaryData {
    final List<Map<String, Object>> summary = [];

    for (int i = 0; i < chosenAnswers.length; i++) {
      String chosenAnswer = chosenAnswers[i];
      QuizQuestion question = questions[i];
      String questionText = question.text;
      String correctAnswer = question.answers[0];

      summary.add({
        "question_index": i,
        "question": questionText,
        "correct_answer": correctAnswer,
        "chosen_answer": chosenAnswer,
      });
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final int totalQuestions = questions.length;
    int totalCorrectQuestions = summaryData
        .where((data) => data["correct_answer"] == data["chosen_answer"])
        .length;

    // for (List<QuizQuestion> question in questions) {}
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "You answered $totalCorrectQuestions out of $totalQuestions questions correctly",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            
          ),
        ),
        SizedBox(height: 30),
        QuestionsSummary(summaryData),
        SizedBox(height: 30),
        TextButton.icon(
          onPressed: changeToStartScreen,
          label: Text("Restart Quiz"),
          icon: Icon(Icons.refresh),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
      ],
    );
  }
}
