import 'dart:html';

import 'package:flutter/foundation.dart';

import 'package:peer_support_app_prototype/Models/QnACategory.dart';

import 'Answer.dart';
import 'ScoreObject.dart';
import 'User.dart';

class Question {
  String id;
  User user;
  QnACategory category;
  String text;
  List<Answer> answers;

  Question(this.id, this.user, this.category, this.text, this.answers);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    // data['userId'] = userId;
    // data['username'] = username;
    data['categoryId'] = category;

    data['text'] = text;
    return data;
  }
}
