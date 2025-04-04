import 'dart:convert';

import 'package:narxoz_face_id/core/consts.dart';

import '../../courses/data/get_courses_request.dart';
import '../domain/students_class.dart';

Future<List<Student>> get_students(String course_id, String task_id) async {
  try {
    var options = await getTokenOptions();
    final response = await dio.get(
      '/api/canvas-courses/v1/$course_id/assignments/$task_id',
      options: options,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      print(data);
      List<Student> items = [];
      for (var item in data) {
        items.add(Student.fromJson(item));
      }
      return items;
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    return [];
  }
}
