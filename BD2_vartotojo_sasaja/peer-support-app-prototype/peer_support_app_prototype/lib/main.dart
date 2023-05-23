import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Views/Dashboard/Dashboard.dart';
import 'package:peer_support_app_prototype/loginscreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Views/Dashboard/DashboardViews/Chat/ChatViews/ChatView.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.amber,
        primarySwatch: Colors.amber,
      ),
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('lt')],
      home: LoginScreen(),
    ),
  );
}
