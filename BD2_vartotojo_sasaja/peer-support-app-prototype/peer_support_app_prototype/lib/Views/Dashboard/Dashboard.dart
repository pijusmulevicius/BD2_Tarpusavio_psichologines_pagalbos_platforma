import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:objectid/objectid.dart';

import 'package:peer_support_app_prototype/Models/QnACategory.dart';
import 'package:peer_support_app_prototype/Views/Dashboard/DashboardViews/AdminViews/AdminDashboard.dart';
import 'package:peer_support_app_prototype/Views/Dashboard/DashboardViews/Chat/ChatDashboard.dart';

import 'package:peer_support_app_prototype/registerscreen.dart';

import '../../../Models/globals.dart';

import 'DashboardViews/CreatePostView.dart';
import 'DashboardViews/FeedView.dart';
import 'DashboardViews/ProfileView.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<Widget> getData() async {
    List<QnACategory> categories = [];
    final dio = Dio();
    if (Globals.selectedCategoryId == '') {}
    final response = await dio.request(
      'http://localhost:3000/category',
      options: Options(method: 'GET'),
    );
    print(response);
    for (int i = 0; i < response.data.length; i++) {
      categories.add(
          new QnACategory(response.data[i]['_id'], response.data[i]['name']));
    }
    categories.add(new QnACategory('', 'Visos'));

    List<Widget> tiles = [];

    for (QnACategory category in categories) {
      tiles.add(ListTile(
        title: Text(category.name),
        onTap: () {
          Globals.selectedCategoryId = category.id;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        },
      ));
    }

    var builtList = Drawer(
      child: ListView(padding: EdgeInsets.zero, children: tiles),
    );

    return builtList;
  }

  List pages = [
    FeedView(),
    ChatDashboard(),
    CreatePostView(),
    ProfileView(Globals.loggedUserid, false),
    AdminDashboard()
  ];
  int currentIndex = 0;
  void onTap(int index) {
    setState(() {
      Globals.selectedUserId = Globals.loggedUserid;
      currentIndex = index;
    });
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
          } else
            return Scaffold(
              appBar: AppBar(
                title: const Text(''),
              ),
              body: pages[currentIndex],
              drawer: snapshot.data,
              bottomNavigationBar: BottomNavigationBar(
                onTap: onTap,
                currentIndex: currentIndex,
                selectedItemColor: Colors.black,
                selectedLabelStyle: TextStyle(color: Colors.black),
                unselectedItemColor: Colors.grey,
                unselectedLabelStyle: TextStyle(color: Colors.grey),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Paieška',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Susirašinėjimai',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.create),
                    label: 'Nauja diskusija',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profilis',
                  ),
                  if (Globals.isAdmin)
                    BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings),
                      label: 'Moderavimo skydelis',
                    ),
                ],
              ),
            );
        });
  }
}
