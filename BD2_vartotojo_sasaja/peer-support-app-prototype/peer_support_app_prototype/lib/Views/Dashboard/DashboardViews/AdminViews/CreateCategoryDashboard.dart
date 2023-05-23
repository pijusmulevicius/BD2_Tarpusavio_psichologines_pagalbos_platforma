//+++ initial refactoring done
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:objectid/objectid.dart';
import 'package:peer_support_app_prototype/registerscreen.dart';
import 'package:custom_radio_group_list/custom_radio_group_list.dart';
import 'package:flutter/material.dart';

import '../../Dashboard.dart';

class CreateCategoryDashboard extends StatefulWidget {
  const CreateCategoryDashboard({super.key});

  @override
  _CreateCategoryDashboard createState() => _CreateCategoryDashboard();
}

class _CreateCategoryDashboard extends State<CreateCategoryDashboard> {
  bool isSubmitButtonEnabled = true;
  late String selectedCategory;
  TextEditingController postController = TextEditingController();
  String? categoryExist = null;
  @override
  Widget build(BuildContext context) {
    final categoryNameController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorijos sukurimas'),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: categoryNameController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  errorText: categoryExist,
                  labelText: 'Kategorijos pavadinimas',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('Sukurti kategoriją'),
                onPressed: () async {
                  createCategory(categoryNameController.text);
                },
              ),
            ),
          ])),
    );
  }

  void createCategory(String categoryName) async {
    final dio = Dio();
    final response = await dio.request('http://localhost:3000/category',
        options: Options(method: 'POST'),
        queryParameters: {"name": categoryName});
    if (response.data != "CATEGORY EXISTS") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } else {
      setState(() {
        categoryExist = "Kategorija egzistuoja";
      });
    }
  }
}
