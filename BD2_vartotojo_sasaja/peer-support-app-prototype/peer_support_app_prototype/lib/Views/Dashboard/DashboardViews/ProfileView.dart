import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../Models/globals.dart';
import 'Chat/ChatViews/ChatView.dart';

class ProfileView extends StatefulWidget {
  //cia dabar istikro yra listas IDk kaip pervadinti, butu gerai tureti bendra chatView generator (nu kuris kaip messengeryje atvaizduotu o situos pakeisti tiesiog i sarasus)
  const ProfileView(String selectedUserId, this.isShown, {super.key});

  final bool? isShown;

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<dynamic> getData() async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/user?_id=' + Globals.selectedUserId,
      // queryParameters: {
      //   '_id': Globals.selectedUserId
      // },
      options: Options(method: 'GET'),
    );
    // if (response.data != "User not found") {
    //   if (response.data['username'] == username) {
    //     Globals.loggedUserid = response.data['_id'];
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => const Dashboard()),
    //     );
    //   }
    // }
    var displayInformation = [
      {"username": response.data['username']},
      {"scores": response.data['scoreTable']},
    ];
    //   final listObject = response.data['username'];
    return displayInformation;
  }

  // late bool isShown;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else
            return Scaffold(
                appBar: (widget.isShown == true)
                    ? AppBar(
                        title: Text('') //Text('snapshot.data[0]["username"]'),
                        )
                    : null,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Wrap(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        CircleAvatar(
                          child: Text(snapshot.data[0]["username"][0] +
                              snapshot.data[0]["username"]
                                  [snapshot.data[0]["username"].length - 1]),
                          minRadius: 15,
                          maxRadius: 25,
                        ),
                        Column(
                          children: [
                            Text(''),
                            Text(
                              "Surinkti taškai:" + snapshot.data[0]["username"],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              getChatData('abc123');
                            },
                            child: Text('Pradėti pokalbį'))
                      ],
                    ),
                    Wrap(children: ContainerView(snapshot.data[1])),
                  ],
                ));
        });
  }

  ContainerView(scores) {
    final List<Widget> ScoreView = [];
    for (int i = 0; i < scores['scores'].length; i++) {
      String ScoreString = scores['scores'][i]['name'] +
          ': ' +
          scores['scores'][i]['score'].toString();
      ScoreView.add(Container(
        padding: EdgeInsets.all(16.0),
        height: 50,
        color: Color.fromARGB(255, 255, 208, 0),
        child: Center(child: Text(ScoreString)),
      ));
      ScoreView.add(Text(' '));
    }
    return ScoreView;
  }

  void getChatData(roomId) async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/chats',
      queryParameters: {'roomId': 'abc123'},
      options: Options(method: 'GET'),
    );
    var chatCollection = response.data;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatView(
                chatCollection: chatCollection,
              )),
    );
  }
}
