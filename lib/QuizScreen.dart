import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizapp/DatabaseHelper.dart';
import 'package:quizapp/QuestionModel.dart';
import 'package:quizapp/QuizResult.dart';
import 'package:quizapp/menu.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctcnt = 0;
  int _questioncnt = 0;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _databaseInitialized = false; // Add this variable

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // Call the method to initialize the database
  }

  Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initDatabase(); // Initialize the database
    setState(() {
      _questionsFuture =
          _getQuestions(); // Once the database is initialized, fetch questions
      _databaseInitialized =
          true; // Set the flag to indicate that the database is initialized
    });
  }

  Future<List<Question>> _getQuestions() async {
    List<Map<String, dynamic>> questionsData =
        await DatabaseHelper().getQuestions();
    List<Question> questions = questionsData.map((questionMap) {
      return Question(
        id: questionMap['id'],
        question: questionMap['question'],
        option1: questionMap['option1'],
        option2: questionMap['option2'],
        option3: questionMap['option3'],
        correctAnswer: questionMap['correctAnswer'],
      );
    }).toList();

    print('Total questions fetched: ${questions.length}');
    questions.shuffle();
    return questions;
  }

  void _checkAnswer(int selectedAnswer, int correctAnswer) {
    setState(() {
      _questioncnt++;
      _showResult = true;
      _isCorrect = selectedAnswer == correctAnswer;
      if (_isCorrect) {
        _correctcnt++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
      _showResult = false;
    });
  }

  void _printAllQuestions() async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> questions = await dbHelper.getQuestions();
    questions.forEach((question) {
      print('Question: ${question['question']}');
      print('Option 1: ${question['option1']}');
      print('Option 2: ${question['option2']}');
      print('Option 3: ${question['option3']}');
      print('Correct Answer: ${question['correctAnswer']}');
      print('------------------------');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Row(
            children: [
              Text("Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "  Score: $_correctcnt / $_questioncnt",
                style: TextStyle(fontSize: 15),
              )
            ],
          )),
      body:
          _databaseInitialized // Check if the database is initialized before building the UI
              ? FutureBuilder<List<Question>>(
                  future: _questionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      _questions = snapshot.data!;
                      Question currentQuestion =
                          _questions[_currentQuestionIndex];
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              currentQuestion.question,
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (!_showResult) {
                                  _checkAnswer(
                                      1, currentQuestion.correctAnswer);
                                }
                              },
                              child: Text(currentQuestion.option1),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (!_showResult) {
                                  _checkAnswer(
                                      2, currentQuestion.correctAnswer);
                                }
                              },
                              child: Text(currentQuestion.option2),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (!_showResult) {
                                  _checkAnswer(
                                      3, currentQuestion.correctAnswer);
                                }
                              },
                              child: Text(currentQuestion.option3),
                            ),
                            SizedBox(height: 20),
                            _showResult
                                ? Text(
                                    _isCorrect ? 'Correct!' : 'Incorrect!',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: _isCorrect
                                            ? Colors.green
                                            : Colors.red),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: Text('No questions available.'));
                    }
                  },
                )
              : const Center(child: CircularProgressIndicator()),
      floatingActionButton: _questioncnt % 10 == 0 &&
              _questioncnt !=
                  0
          ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuizResult(
                            correctAnswers: _correctcnt,
                            totalQuestions: _questioncnt,
                          )),
                );
              },
              child: Text("Result"),
            )
          : FloatingActionButton(
              onPressed: _nextQuestion,
              child: Icon(Icons.arrow_forward),
            ),
      // persistentFooterButtons: [
      //   ElevatedButton(
      //     onPressed: _printAllQuestions,
      //     child: Text('Debug: Print All Questions'),
      //   ),
      // ],
    );
  }
}
