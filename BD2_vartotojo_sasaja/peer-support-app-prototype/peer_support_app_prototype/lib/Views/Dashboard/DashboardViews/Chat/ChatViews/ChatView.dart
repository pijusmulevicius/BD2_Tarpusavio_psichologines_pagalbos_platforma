import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Models/User.dart';
import 'package:peer_support_app_prototype/Models/globals.dart';
import 'package:peer_support_app_prototype/registerscreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatView extends StatefulWidget {
  ChatView({Key? key, required this.chatCollection}) : super(key: key);

  final String chatCollection;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  // var forwardedMessages =

  bool messagesAreImported = false;
  bool socketIsConnected = false;
  late IO.Socket socket;
  void initSocketConnection() {
    socket = IO.io("http://localhost:3000");
    socket.onConnect((_) {
      socket.emit('room', 'abc123');
      socketIsConnected = true;
    });
    socket
        .onDisconnect((_) => {print('disconnect'), socketIsConnected = false});
    socket.on(
        'msg',
        (data) => {
              _addMessage(buildTextMessageWidget(types.PartialText(text: data)))
            });
  }

  final List<types.Message> _messages = [];
  final _user = types.User(
      firstName: Globals.loggedUserid,
      lastName: 'DestroyerOfWorlds',
      id: Globals.loggedUserid); //cia add reikia stuff for ids

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

  types.TextMessage desiarilzeImportedMessage(message) {
    return types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        showStatus: true,
        text: message["text"],
        roomId: 'abc123');
  }

  types.TextMessage buildTextMessageWidget(types.PartialText message) {
    return types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: randomString(),
        showStatus: true,
        text: message.text,
        roomId: 'abc123');
  }

  void _buildExistingMessages() {
    var importedMessages = json.decode(widget.chatCollection);

    print(importedMessages);
    for (int i = 0; i < importedMessages.length; i++) {
      final textMessage = desiarilzeImportedMessage(importedMessages[i]);
      _addMessage(textMessage);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = buildTextMessageWidget(message);
    socket.emit('msg', {
      "author": _user,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "user": _user.id,
      "showStatus": true,
      "text": message.text,
      "roomId": 'abc123'
    });
    _addMessage(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    if (!socketIsConnected) {
      initSocketConnection();
    }
    if (!messagesAreImported) {
      _buildExistingMessages();
      messagesAreImported = true;
    }

    return Scaffold(
      appBar: AppBar(),
      body: Chat(
        l10n: const ChatL10nEn(
            attachmentButtonAccessibilityLabel: 'Išsiųsti media',
            emptyChatPlaceholder: 'Naujų pranešimų nėra',
            fileButtonAccessibilityLabel: 'Failas',
            inputPlaceholder: 'Pranešimas',
            sendButtonAccessibilityLabel: 'Išsiųsti',
            unreadMessagesLabel: 'Neperskaityti pranešimai'),
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        showUserNames: true,
        showUserAvatars: true,
      ),
    );
  }
}
