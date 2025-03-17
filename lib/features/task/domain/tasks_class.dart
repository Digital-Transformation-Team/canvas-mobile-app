class Task {
  late int id;
  late String name;

  Task({required this.id, required this.name});

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: json['assignment_id'],
    name: json['name'],
  );
}