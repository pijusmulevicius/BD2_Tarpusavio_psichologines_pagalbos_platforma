
import 'QnACategory.dart';
import 'ScoreObject.dart';
import 'User.dart';

class Answer {
  String id;
  User user;
  QnACategory category;
  String text;
//  Comment comment;
  List<ScoreObject> score;

  Answer(this.id, this.user, this.category, this.text, this.score);

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = id;
  //   data['userId'] = userId;
  //   data['username'] = username;
  //   data['categoryId'] = categoryId;
  //   data['text'] = text;
  //   return data;
  // }
}
