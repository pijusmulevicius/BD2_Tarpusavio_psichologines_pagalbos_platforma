class User {
  String userId;
  String username;

  User(this.userId, this.username);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['username'] = username;
    return data;
  }
}
