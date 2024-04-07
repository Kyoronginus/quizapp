import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizapp/DatabaseHelper.dart';
import 'package:quizapp/QuestionModel.dart';
import 'package:quizapp/menu.dart';

class QuizResult extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;

  QuizResult({required this.correctAnswers, required this.totalQuestions});

  @override
  _QuizResultState createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  @override
  Widget build(BuildContext context) {
    double percentage = (widget.correctAnswers / widget.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Correct Answers: ${widget.correctAnswers}",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "Total Questions: ${widget.totalQuestions}",
              style: TextStyle(fontSize: 20),
            ),
            Center(
              child: Text(
                "Your Score\n${percentage.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 50),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuScreen(),
            ),
          );
        },
        child: Text("Back to The menu"),
      ),
    );
  }
}
