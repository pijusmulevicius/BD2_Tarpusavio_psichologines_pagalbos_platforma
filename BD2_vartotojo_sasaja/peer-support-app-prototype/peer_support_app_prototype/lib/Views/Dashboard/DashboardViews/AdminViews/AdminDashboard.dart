import 'dart:convert';
import 'dart:math';

// import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

import 'package:grouped_list/grouped_list.dart';
import 'package:peer_support_app_prototype/Models/ReportedRecord.dart';
import 'package:peer_support_app_prototype/Models/User.dart';
import 'package:peer_support_app_prototype/Models/globals.dart';
import 'package:peer_support_app_prototype/Views/Dashboard/DashboardViews/AdminViews/CreateCategoryDashboard.dart';
import 'package:peer_support_app_prototype/Views/Dashboard/DashboardViews/AdminViews/ReportedRecordDashboard.dart';
import 'package:peer_support_app_prototype/registerscreen.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

List _elements = [
  {'name': 'Kategorijų kūrimo langas', 'group': ''},
  {'name': 'Reportuotų įrašų langas', 'group': ''},
];

class AdminDashboard extends StatefulWidget {
  //cia dabar istikro yra listas IDk kaip pervadinti, butu gerai tureti bendra chatView generator (nu kuris kaip messengeryje atvaizduotu o situos pakeisti tiesiog i sarasus)
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
                    title: Text(element['name']),
                    onTap: () {
                      if (element['name'] == 'Kategorijų kūrimo langas') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CreateCategoryDashboard()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ReportedRecordDashboard()),
                        );
                      }
                    },
                  ),
                ),
              );
            }));
  }
}
