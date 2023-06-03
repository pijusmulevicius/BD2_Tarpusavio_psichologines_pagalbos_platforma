import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Models/Answer.dart';
import 'package:peer_support_app_prototype/Models/QnACategory.dart';
import 'package:peer_support_app_prototype/Models/ScoreObject.dart';

import 'package:peer_support_app_prototype/registerscreen.dart';

import '../../../Models/Question.dart';
import '../../../Models/User.dart';
import '../../../Models/globals.dart';
import '../../QnA/QnAView.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  Future<List<Question>> getData() async {
    List<Question> questions = [];
    final dio = Dio();

    var response = await dio.request(
      'http://localhost:3000/dashboard/question/' + Globals.selectedCategoryId,
      options: Options(method: 'GET'),
    );
    var some = response.data[0]['userId'];
    List<ScoreObject> scoreObjects = [
      ScoreObject('callingUserId', 'categoryId', 1)
    ];

    for (int i = 0; i < response.data.length; i++) {
      questions.add(new Question(
          response.data[i]['_id'],
          new User(response.data[i]['user'][0]['_id'],
              response.data[i]['user'][0]['username']),
          new QnACategory(response.data[i]['category'][0]['_id'],
              response.data[i]['category'][0]['name']),
          response.data[i]['text'],
          toAnswerList(response.data[i]['answers'])));
    }

    return questions;
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
            List<Question>? questions = snapshot.data;
            print(questions);
            final List<HeadingItem> items = List<HeadingItem>.generate(
                questions!.length,
                (i) => HeadingItem(
                    questions[i].id,
                    questions[i].text,
                    questions[i].user.username,
                    questions[i].category.name,
                    questions[i].answers.length.toString()));

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: item.build(context),
                );
              },
            );
          }
        });
  }

  List<Answer> toAnswerList(List<dynamic> answerJsonQueue) {
    List<ScoreObject> scoreObjects = [
      ScoreObject('callingUserId', 'categoryId', 1)
    ];
    List<Answer> answers = [
      Answer('id', new User('userId', 'username'),
          new QnACategory('id', 'name'), 'text', scoreObjects)
    ];
    return answers;
  }
}

class HeadingItem {
  final String questionId;
  final String question;
  final String answerCount;
  final String username;
  final String category;

  HeadingItem(this.questionId, this.question, this.username, this.category,
      this.answerCount);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Wrap(direction: Axis.vertical, children: <Widget>[
        InkWell(
            onTap: () {
              Globals.selectedQuestion = questionId;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QnAView(
                          title: 'Diskusijos langas',
                        )),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.orangeAccent),
              child: Wrap(direction: Axis.vertical, children: <Widget>[
                Container(
                    height: 120,
                    width: 450,
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(255, 255, 226, 119)),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color.fromARGB(255, 255, 226, 119)),
                    child: Text(question)),
                Container(
                    height: 30,
                    width: 450,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.orangeAccent),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('   '),
                        Text(category),
                        Spacer(),
                        InkWell(child: Icon(Icons.comment)),
                        Text(answerCount),
                        Text('   '),
                      ],
                    ))
              ]),
            )),
        Container(
          height: 50,
          width: 450,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                child: Text(username[0] + username[username.length - 1]),
              ), //cia reiks paimti ta circle avatara
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                //  Text('posted: this should be a place for what time ago'),
                Text(username)
              ]), //jo cia tas bendrinis info
              Spacer(),
              Icon(Icons.more_horiz)
            ],
          ),
        )
      ]),
    );
  }
}
