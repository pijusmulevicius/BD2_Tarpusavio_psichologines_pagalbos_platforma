import 'Question.dart';

class ForumStrucutre {
  Question question;
  List<Question> answers;

  ForumStrucutre(this.question, this.answers);

  Question getQuestion(Question question) {
    return question;
  }
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = id;
  //   data['userId'] = userId;
  //   data['username'] = username;
  //   data['categoryId'] = categoryId;
  //   data['BlockType'] = BlockType;
  //   data['text'] = text;
  //   return data;
  // }
}
