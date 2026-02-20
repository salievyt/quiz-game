class Question {
  String question;
  List<String> answers;
  int correctIndex;

  Question({
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

  void shuffleAnswers() {
    final correctAnswer = answers[correctIndex];

    answers.shuffle();

    correctIndex = answers.indexOf(correctAnswer);
  }
}