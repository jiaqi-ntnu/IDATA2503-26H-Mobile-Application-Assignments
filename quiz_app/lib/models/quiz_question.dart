class QuizQuestion {
  const new(this.text, this.answers);
  
  final String text;
  final List<String> answers;

  List<String> get shuffledAnswers => List.of(answers)..shuffle();

}  