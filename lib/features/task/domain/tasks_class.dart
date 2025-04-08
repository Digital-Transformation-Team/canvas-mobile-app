class Task {
  late int id;
  late String name;
  late String web_id;

  Task({required this.id, required this.name, required this.web_id});

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    name: json['name'],
    web_id: json['web_id'],
  );
}