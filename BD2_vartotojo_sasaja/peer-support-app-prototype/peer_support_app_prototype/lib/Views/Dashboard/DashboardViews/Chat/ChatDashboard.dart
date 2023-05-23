import 'dart:math';

import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Views/Dashboard/DashboardViews/Chat/ChatViews/GroupChatListView.dart';
import 'package:peer_support_app_prototype/registerscreen.dart';

import 'ChatViews/ListenerChatListView.dart';
import 'ChatViews/PrivateChatListView.dart';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({super.key});

  @override
  _ChatDashboardState createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[PrivateChatListView()],
      ),
    );
  }
}
