import 'dart:convert';
import 'dart:math';

// import 'package:chatview/chatview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:grouped_list/grouped_list.dart';
import 'package:peer_support_app_prototype/Models/User.dart';
import 'package:peer_support_app_prototype/Models/globals.dart';
import 'package:peer_support_app_prototype/registerscreen.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'ChatView.dart';

List _elements = [
  {'name': 'Vartotojas2', 'group': ''},
];

class PrivateChatListView extends StatefulWidget {
  //cia dabar istikro yra listas IDk kaip pervadinti, butu gerai tureti bendra chatView generator (nu kuris kaip messengeryje atvaizduotu o situos pakeisti tiesiog i sarasus)
  const PrivateChatListView({super.key});

  @override
  _PrivateChatListViewState createState() => _PrivateChatListViewState();
}

class _PrivateChatListViewState extends State<PrivateChatListView> {
  bool socketIsConnected = false;
  late IO.Socket socket;
  final List<types.Message> _messages = [];
  final _user = types.User(
      firstName: Globals.loggedUserid,
      // lastName: 'DestroyerOfWorlds',
      id: Globals.loggedUserid);

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  types.TextMessage buildTextMessageWidget(types.PartialText message) {
    return types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        showStatus: true,
        text: ('${_user.firstName}: ${message.text}'),
        roomId: 'fasdf');
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = buildTextMessageWidget(message);
    _addMessage(textMessage);
  }

  void test() {
    print('object');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GroupedListView<dynamic, String>(
            elements: _elements,
            groupBy: (element) => element['group'],
            groupComparator: (value1, value2) => value2.compareTo(value1),
            itemComparator: (item1, item2) =>
                item1['name'].compareTo(item2['name']),
            order: GroupedListOrder.DESC,
            useStickyGroupSeparators: true,
            groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
            itemBuilder: (c, element) {
              return Card(
                elevation: 8.0,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: SizedBox(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    leading: CircleAvatar(
                      child: Text(element['name'][0] +
                          element['name'][element['name'].length - 1]),
                    ),
                    title: Text(element['name']),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      getChatData('abc123');
                    },
                  ),
                ),
              );
            }));
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

  //  void gotoChat(chatCollection){
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const ChatView(chatCollection)),
  //   );
  //  }
}
