//+++ initial refactoring done
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:objectid/objectid.dart';
import 'package:peer_support_app_prototype/registerscreen.dart';
import 'package:custom_radio_group_list/custom_radio_group_list.dart';
import 'package:flutter/material.dart';

import '../../../Models/QnACategory.dart';
import '../../../Models/globals.dart';
import '../Dashboard.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  _CreatePostViewState createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  bool isSubmitButtonEnabled = true;
  late String selectedCategory; //cia gal net ir object id reiktu padaryti
  TextEditingController postController = TextEditingController();

  Future<Widget> getCategoryList() async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/category',
      options: Options(method: 'GET'),
    );
    List<Map<dynamic, dynamic>> categoryList = [];
    for (dynamic category in response.data) {
      categoryList.add({'id': category['_id'], 'name': category['name']});
    }
    selectedCategory = categoryList[0]['id'];
    return RadioGroup(
        radioListObject: categoryList,
        textParameterName: 'name',
        selectedItem: 0,
        onChanged: (value) {
          print('Value : ${value}');
          selectedCategory = value['id'];
        });
  }

  void createPost() async {
    final dio = Dio();
    final response = await dio.request(
      'http://localhost:3000/question',
      data: {
        'user': Globals.loggedUserid,
        'category': selectedCategory,
        'text': postController.text.toString(),
        'score': 0
      },
      options: Options(method: 'POST'),
    );
    if (response.data['user'][0] == Globals.loggedUserid)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCategoryList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else
            return Column(children: <Widget>[
              TextField(
                controller: postController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Užduoti klausimą',
                ),
              ),
              Container(child: snapshot.data),
              TextButton(
                  onPressed: () {
                    createPost();
                  },
                  child: Text('Užduoti'))
            ]);
        });
  }
}
