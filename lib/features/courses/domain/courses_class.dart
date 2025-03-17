class Course {
  late int id;
  late String name;
  late String course_code;
  late String web_id;
  late String description;

  Course({required this.id, required this.name, required this.course_code, required this.web_id, required this.description});

  static Course fromJson(Map<String, dynamic> json) => Course(
    id: json['course_id'],
    name: json['short_name'],
    course_code: json['course_code'],
    web_id: json['web_id'],
    description: json['long_name'],
  );
}