import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:peer_support_app_prototype/Models/globals.dart';

import 'package:peer_support_app_prototype/registerscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Views/Dashboard/Dashboard.dart';

import 'dart:async';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final GlobalKey<FormFieldState> formFieldKey = GlobalKey();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? userDoesNotExist = null;
  String? wrongPassword = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prisijungimas'),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: usernameController,
                obscureText: false,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Vartotojo vardas',
                    errorText: userDoesNotExist),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Slaptažodis',
                    errorText: wrongPassword),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('Prisijungti'),
                onPressed: () {
                  setState(() {
                    signIn(usernameController.text, passwordController.text);
                  });
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => setState(() {}));
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Registruotis'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
            ),
          ])),
    );
  }

  void signIn(username, password) async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/login',
      data: {'username': username, 'password': password},
      options: Options(method: 'POST'),
    );
    if (response.data == 'USER NOT FOUND') {
      setState(() {
        userDoesNotExist = 'Vartotojas neegzistuoja';
      });
    } else if (response.data == 'WRONG PASSWORD') {
      setState(() {
        userDoesNotExist = null;
        wrongPassword = 'Neteisingas slaptažodis';
      });
    } else if (response.data['username'] == username) {
      try {
        Globals.isAdmin = response.data['isAdmin'];
      } catch (e) {
        Globals.isAdmin = false;
      }
      Globals.loggedUserid = response.data['_id'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }
}
