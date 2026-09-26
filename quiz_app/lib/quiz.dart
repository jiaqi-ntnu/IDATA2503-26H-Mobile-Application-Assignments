// import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/questions_screen.dart';
import 'package:quiz_app/start_screen.dart';

import 'results_screen.dart';

class Quiz extends StatefulWidget {
  const new({super.key});

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  String activeScreenStr = "StartScreen";
  final List<String> chosenAnswers = [];

  void changeToQuestionsScreen() {
    setState(() {
      chosenAnswers.clear();
      activeScreenStr = "QuestionsScreen";
    });
  }

  void changeToStartScreen() {
    setState(() {
      activeScreenStr = "StartScreen";
    });
  }

  void onSelectAnswer(String answer) {
    chosenAnswers.add(answer);
    if (chosenAnswers.length == questions.length) {
      setState(() => activeScreenStr = "ResultsScreen");
      
    }
  }

  @override
  Widget build(context) {
    Widget? activeScreen;
    if (activeScreenStr == "StartScreen") {
      activeScreen = StartScreen(changeToQuestionsScreen);
    } else if (activeScreenStr == "QuestionsScreen") {
      activeScreen = QuestionsScreen(onSelectAnswer: onSelectAnswer);
    } else if (activeScreenStr == "ResultsScreen") {
      activeScreen = ResultsScreen(
        chosenAnswers: chosenAnswers,
        changeToStartScreen: changeToStartScreen,
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: AlignmentGeometry.bottomRight,
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Container(margin: EdgeInsets.all(40), child: activeScreen),
          ),
        ),
      ),
    );
  }
}
