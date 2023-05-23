class QnACategory {
  late String id;
  late String name;

  QnACategory(this.id, this.name);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
