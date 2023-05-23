import 'dart:html';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Models/Answer.dart';
import 'package:peer_support_app_prototype/Models/QnACategory.dart';
import 'package:peer_support_app_prototype/Models/ScoreObject.dart';

import 'package:peer_support_app_prototype/registerscreen.dart';

import '../../../../Models/ReportedRecord.dart';
import '../../../../Models/User.dart';

class ReportedRecordDashboard extends StatefulWidget {
  const ReportedRecordDashboard({super.key});

  @override
  _ReportedRecordDashboardState createState() =>
      _ReportedRecordDashboardState();
}

class _ReportedRecordDashboardState extends State<ReportedRecordDashboard> {
  Future<List<ReportedRecord>> getData() async {
    List<ReportedRecord> reportedRecords = [];
    final dio = Dio();

    var response = await dio.request(
      'http://localhost:3000/reportedAnswer/',
      options: Options(method: 'GET'),
    );

    for (int i = 0; i < response.data.length; i++) {
      reportedRecords.add(new ReportedRecord(
          response.data[i]['answer'][0]['_id'],
          response.data[i]['_id'],
          new User(response.data[i]['reportedUser'][0]['_id'],
              response.data[i]['reportedUser'][0]['username']),
          response.data[i]['answer'][0]['text']));
    }

    return reportedRecords;
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
            List<ReportedRecord>? reportedRecords = snapshot.data;
            print(reportedRecords);
            final List<HeadingItem> items = List<HeadingItem>.generate(
                reportedRecords!.length,
                (i) => HeadingItem(
                    reportedRecords[i].answerId,
                    reportedRecords[i].id,
                    reportedRecords[i].user.userId,
                    reportedRecords[i].user.username,
                    reportedRecords[i].text));

            return Scaffold(
                appBar: AppBar(
                  title: const Text('Reportuotų įrašų langas'),
                ),
                body: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: item.build(context),
                    );
                  },
                ));
          }
        });
  }

  // List<Answer> toAnswerList(List<dynamic> answerJsonQueue) {
  //   List<ScoreObject> scoreObjects = [
  //     ScoreObject('callingUserId', 'categoryId', 1)
  //   ];
  //   List<Answer> answers = [
  //     Answer('id', new User('userId', 'username'),
  //         new QnACategory('id', 'name'), 'text', scoreObjects)
  //   ];
  //   return answers;
  // }
}

class HeadingItem {
  final String answerId;
  final String reportedRecordId;
  final String userId;
  final String username;
  final String text;

  HeadingItem(this.answerId, this.reportedRecordId, this.userId, this.username,
      this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Wrap(direction: Axis.vertical, children: <Widget>[
        InkWell(
            onTap: () {
              // Globals.selectedQuestion = questionId;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => QnAView(
              //             title: 'Diskusijos langas',
              //           )),
              // );
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
                    child: Row(children: [
                      Text(text),
                      InkWell(
                          onTap: () {
                            deleteReportedAnswer(reportedRecordId);
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReportedRecordDashboard()),
                            );
                          }, // Handle your callback
                          child: Icon(Icons.close)),
                      InkWell(
                          onTap: () {
                            blockUser(userId, answerId, reportedRecordId);

                            print('restarting');
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReportedRecordDashboard()),
                            );
                          }, // Handle your callback
                          child: Icon(Icons.check)),
                    ])),
                // Container(
                //     height: 30,
                //     width: 450,
                //     decoration: BoxDecoration(
                //         border: Border.all(color: Colors.orangeAccent),
                //         borderRadius: BorderRadius.all(Radius.circular(20))),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text('   '),
                //         Text(category),
                //         Spacer(),
                //         InkWell(child: Icon(Icons.comment)),
                //         Text(answerCount),
                //         Text('   '),
                //       ],
                //     ))
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

deleteReportedAnswer(String reportedRecordId) async {
  final dio = Dio();
  var response = await dio.request(
    'http://localhost:3000/deleteReportedAnswer',
    queryParameters: {"reportedRecordId": reportedRecordId},
    options: Options(method: 'POST'),
  );
}

blockUser(
    String userId, String reportedAnswerId, String reportedRecordId) async {
  final dio = Dio();
  var response = await dio.request(
    'http://localhost:3000/blockUser',
    queryParameters: {
      "reportedUser": userId,
      "reportedAnswer": reportedAnswerId,
      "reportedRecordId": reportedRecordId
    },
    options: Options(method: 'POST'),
  );
  print(response);
}
