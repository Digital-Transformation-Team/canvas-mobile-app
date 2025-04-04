import 'package:narxoz_face_id/features/students/data/get_students_request.dart';

import '../../../core/consts.dart';
import '../../courses/data/get_courses_request.dart';
import '../domain/students_class.dart';

// Future<List<String>> getClasses() async {
//   try {
//     final response =
//     await http.get(Uri.parse('https://example.com/api/classes'));
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((e) => e.toString()).toList(); // Преобразуем в List<String>
//     } else {
//       throw Exception("Ошибка загрузки");
//     }
//   } catch (e) {
//     print("Ошибка: $e");
//     return []; // Если ошибка — возвращаем пустой список
//   }
// }

Future<List<Student>> change_status(
  String course_id,
  String task_id,
  String student_id,
  int students_index,
  String value,
) async {
  try {
    var options = await getTokenOptions();
    final response = await dio.put(
      '/api/canvas-courses/v1/$course_id/assignments/$task_id',
      options: options,
      data: {'student_id': student_id, 'value': value},
    );
    if (response.statusCode == 200) {
      return await get_students(course_id, task_id);
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    return [];
  }
}
