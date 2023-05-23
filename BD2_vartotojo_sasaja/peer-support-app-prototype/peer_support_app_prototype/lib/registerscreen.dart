import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'Models/globals.dart';
import 'Views/Dashboard/Dashboard.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  String? userExists = null;
  String? emailExists = null;
  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController dateInput = TextEditingController();
    TextEditingController emailController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Registracija'),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      errorText: userExists,
                      border: OutlineInputBorder(),
                      labelText: 'Vartotojo vardas',
                    ),
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
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: dateInput,
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: "Gimimo data"),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            locale: const Locale("lt", "LT"),
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          final DateTime now = pickedDate;
                          final DateFormat formatter = DateFormat('yyyy-MM-dd');
                          final String formattedDate = formatter.format(now);
                          print(formattedDate);
                          dateInput.text = formattedDate;
                        } else {}
                      },
                    )),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      errorText: emailExists,
                      border: OutlineInputBorder(),
                      labelText: 'el.paštas',
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Registruotis'),
                  onPressed: () {
                    setState(() {
                      register(usernameController.text, passwordController.text,
                          dateInput.text, emailController.text);
                    });
                  },
                ),
              ]),
        ));
  }

  void register(username, password, dateOfBirth, email) async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/register',
      data: {
        'username': username,
        'password': password,
        'dateOfBirth': dateOfBirth,
        'email': email
      },
      options: Options(method: 'POST'),
    );
    if (response.data == 'USER EXISTS') {
      setState(() {
        userExists = 'Vartotojas egzistuoja';
      });
    } else if (response.data == 'EMAIL TAKEN') {
      setState(() {
        userExists = null;
        emailExists = 'el.paštas egzistuoja';
      });
    } else if (response.data['username'] == username) {
      Globals.loggedUserid = response.data['_id'];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
    ;
  }
}
