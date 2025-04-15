String capitalize(String input) {
  if (input.isEmpty) return input;

  return input
      .split(' ')
      .map(
        (word) =>
            word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '',
      )
      .join(' ');
}

class Student {
  late String id;
  late String web_id;
  late String name;
  late String email;
  late String status;
  late String value;
  late String web_id_assignment;

  Student({
    required this.id,
    required this.web_id,
    required this.name,
    required this.email,
    required this.status,
    required this.value,
    required this.web_id_assignment,
  });

  /* Statuses:
  * INITIATED
  * IN_PROGRESS
  * COMPLETED
  *
  * Values:
  * complete
  * incomplete
  * excuse
  * */

  static Student fromJson(Map<String, dynamic> json) => Student(
    id: json['student']['id'].toString(),
    web_id: json['student']['web_id'].toString(),
    name: capitalize(json['student']['name'].toString()),
    email: json['student']['email'].toString(),
    status: json['status'].toString(),
    value: json['value'].toString(),
    web_id_assignment: json['web_id'].toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'web_id': web_id,
    'name': name,
    'email': email,
    'status': status,
    'value': value,
  };
}
