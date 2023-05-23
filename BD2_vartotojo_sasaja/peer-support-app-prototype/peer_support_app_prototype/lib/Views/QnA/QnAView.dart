import 'dart:html';
import 'dart:js';
import 'dart:math';

import 'package:comment_tree/comment_tree.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Models/Answer.dart';
import 'package:peer_support_app_prototype/Models/ForumStructure.dart';
import 'package:peer_support_app_prototype/Models/QnACategory.dart';
import 'package:peer_support_app_prototype/Models/ScoreObject.dart';

import '../../Models/Question.dart';
import '../../Models/User.dart';
import '../../Models/globals.dart';
import '../Dashboard/DashboardViews/ProfileView.dart';

class QnAView extends StatefulWidget {
  QnAView({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<QnAView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: MyStatefulWidget());
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late Question question;

  Future<Question> getData() async {
    final dio = Dio();
    var response;
    response = await dio.request(
      'http://localhost:3000/qnaview/question/' + Globals.selectedQuestion,
      options: Options(method: 'GET'),
    );
    print(response);
    Globals.selectedCategoryId = response.data['category'][0]['_id'];
    question = new Question(
      response.data['_id'],
      new User(response.data['user'][0]['_id'],
          response.data['user'][0]['username']),
      new QnACategory(response.data['category'][0]['_id'],
          response.data['category'][0]['name']),
      response.data['text'],
      toAnswerList(response.data['answers']),
    );

    return question;
  }

  bool _customTileExpanded = false;

  TextEditingController answerController = TextEditingController();

  late List<QnAContainer> _answerList = [];

  late Future myFuture = getData();

  void createPost() async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/answer/' + Globals.selectedQuestion,
      data: {
        'user': Globals.loggedUserid,
        'category': Globals.selectedCategoryId,
        'text': answerController.text.toString(),
        'score': 0
      },
      options: Options(method: 'POST'),
    );

    question.answers.add(new Answer(
        response.data['_id'],
        new User(
            response.data['user']['_id'], response.data['user']['username']),
        new QnACategory(
            response.data['category'], "response.data['category'][0]['name']"),
        response.data['text'],
        []));
  }

  List<ScoreObject> toScoreList(objectScoreData) {
    List<ScoreObject> scoreObjects = [];
    for (int i = 0; i < objectScoreData.length; i++) {
      scoreObjects.add(new ScoreObject(
          objectScoreData[i]['callerId'],
          objectScoreData[i]['user'],
          int.parse(objectScoreData[i]['scoreModifier'])));
    }

    return scoreObjects;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            var theData = snapshot.data;
            if (_answerList.isEmpty) {
              _answerList.add(QnAContainer(selectedQuestion: theData));
            }
            return SingleChildScrollView(
                child: Wrap(children: [
              Column(
                children: _answerList,
              ),
              TextField(
                controller: answerController,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      createPost();
                      myFuture = getData();

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QnAView(
                                  title: 'Diskusijos langas',
                                )),
                      );
                    });
                  },
                  child: Text('Atsakyti'))
            ]));
          }
        });
  }

  List<Answer> toAnswerList(answersJson) {
    List<Answer> answers = [];
    for (int i = 0; i < answersJson.length; i++) {
      answers.add(new Answer(
          answersJson[i]['_id'],
          new User(answersJson[i]['user'][0]['_id'],
              answersJson[i]['user'][0]['username']),
          new QnACategory(answersJson[i]['category'][0], 'name'),
          answersJson[i]['text'],
          toScoreList(answersJson[i]['score'])));
    }
    return answers;
  }
}

class QnAContainer extends StatefulWidget {
  const QnAContainer({super.key, required this.selectedQuestion});

  final Question? selectedQuestion;
  @override
  State<QnAContainer> createState() => _QnAContainerWidgetState();
}

class _QnAContainerWidgetState extends State<QnAContainer> {
  bool replyVisible = false;

  alterVisibility() {
    replyVisible = !replyVisible;
  }

  bool _customTileExpanded = false;

  late List<Widget> _cardList = [];

  TextEditingController replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.selectedQuestion!.answers.length; i++) {
      _cardList
          .add(QnACommentTile(answer: widget.selectedQuestion!.answers[i]));
    }

    return Wrap(children: [
      Container(
        child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          initiallyExpanded: true,
          title: Row(children: <Widget>[]),
          subtitle: Wrap(children: <Widget>[
            Row(children: <Widget>[
              InkWell(
                onTap: () {
                  Globals.selectedUserId = widget.selectedQuestion!.user.userId;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileView(
                            widget.selectedQuestion!.user.userId, true)),
                  );
                },
                child: CircleAvatar(
                  child: Text(widget.selectedQuestion!.user.username[0] +
                      widget.selectedQuestion!.user.username[
                          widget.selectedQuestion!.user.username.length - 1]),
                ),
              ),
              Text(
                widget.selectedQuestion!.user.username,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              )
            ]),
            Row(children: <Widget>[
              Text(
                widget.selectedQuestion!.text,
                style: TextStyle(color: Colors.black),
              )
            ]),
          ]),
          children: _cardList,
        ),
      ),
      Visibility(
          visible: replyVisible,
          child: Wrap(
            children: <Widget>[
              TextField(
                controller: replyController,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      replyVisible = !replyVisible;
                    });
                  },
                  child: Text('')),
            ],
          ))
    ]);
  }
}

class QnACommentTile extends StatefulWidget {
  const QnACommentTile({super.key, required this.answer});
  final Answer? answer;

  @override
  State<QnACommentTile> createState() => _QnACommentTileWidgetState();
}

class _QnACommentTileWidgetState extends State<QnACommentTile> {
  TextEditingController replyController = TextEditingController();
  late List<ScoreObject> answerScore = widget.answer!.score;

  late int answerScoreCount = countAnswerScore();
  int countAnswerScore() {
    int answerScoreCount = 0;
    for (int i = 0; i < answerScore.length; i++) {
      answerScoreCount += answerScore[i].score;
    }
    return answerScoreCount;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: Color.fromARGB(255, 221, 223, 145),
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 2, color: Colors.orangeAccent),
            borderRadius: BorderRadius.circular(45)),
        subtitle: Wrap(children: <Widget>[
          Wrap(direction: Axis.vertical, children: <Widget>[
            Row(children: <Widget>[
              (Globals.loggedUserid != widget.answer!.user.userId)
                  ? ElevatedButton(
                      onPressed: () async {
                        var response = await addScoreToAnswer(
                            widget.answer!.id,
                            widget.answer!.user,
                            Globals.loggedUserid,
                            1,
                            widget.answer!.category.id);
                        setState(() {
                          answerScoreCount = answerScoreCount + response;
                        });
                      },
                      child: Text(
                        "↑",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    )
                  : Text("                 "),
              InkWell(
                onTap: () {
                  Globals.selectedUserId = widget.answer!.user.userId;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileView(widget.answer!.user.userId, true)),
                  );
                }, // Handle your callback
                child: CircleAvatar(
                  child: Text(widget.answer!.user.username[0] +
                      widget.answer!.user
                          .username[widget.answer!.user.username.length - 1]),
                ),
              ), //cia galetu buti real
              Text(widget.answer!.user.username),
              InkWell(
                  onTap: () {
                    _popupDialog(
                        context, widget.answer!.id, widget.answer!.user.userId);
                  }, // Handle your callback
                  child: Icon(Icons.flag)),
            ]),
            Row(children: <Widget>[
              ElevatedButton(
                onPressed: () {},
                child: Text(answerScoreCount.toString()),
              ),
              Text(widget.answer!.text),
            ]),
            Row(children: <Widget>[
              (Globals.loggedUserid != widget.answer!.user.userId)
                  ? ElevatedButton(
                      onPressed: () async {
                        var response = await addScoreToAnswer(
                            widget.answer!.id,
                            widget.answer!.user,
                            Globals.loggedUserid,
                            -1,
                            widget.answer!.category.id);
                        setState(() {
                          answerScoreCount = answerScoreCount + response;
                        });
                      },
                      child: Text(
                        "↓",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    )
                  : Text("                 "),
            ]),
            Row(children: <Widget>[
              (Globals.loggedUserid != widget.answer!.user.userId)
                  ? Text("                 ")
                  : Text("                 "),
            ])
          ])
        ]));
  }

  Future<int> addScoreToAnswer(String asnwerId, User user, String loggedUserid,
      int scoreModifier, String category) async {
    final dio = Dio();
    var response = await dio.request(
      'http://localhost:3000/score',
      queryParameters: {
        "asnwerId": asnwerId,
        "callerId": loggedUserid,
        "user": user.userId,
        "scoreModifier": scoreModifier,
        "category": category
      },
      options: Options(method: 'POST'),
    );

    return int.parse(response.data['modifiedScore']);
  }

  void _popupDialog(BuildContext context, String answerId, String userId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //title: const Text('Basic dialog title'),
            content: const Text(
              'Reportuoti Atsakymą?',
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ne'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Taip'),
                onPressed: () {
                  reportAnswer(answerId, userId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  reportAnswer(String asnwerId, String userId) async {
    final dio = Dio();
    var response = await dio.request(
      'http://localhost:3000/reportAnswer',
      queryParameters: {
        "asnwerId": asnwerId,
        "callerId": Globals.loggedUserid,
        "user": userId,
      },
      options: Options(method: 'POST'),
    );
  }
}
