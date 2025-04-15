
import 'package:narxoz_face_id/core/consts.dart';

import '../../../core/shared_prefs.dart';
import '../../courses/data/get_courses_request.dart';
import '../domain/students_class.dart';

Future<List<Student>> get_students(String id, int page) async {
  try {
    var options = await getTokenOptions();
    String url = '/api/attendances/v1/?assignment_id=$id&order_by=created_date&asc=false&page=$page';
    print(url);
    final response = await dio.get(
      url,
      options: options,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      print(data);
      List<Student> items = [];
      for (var item in data['items']) {
        items.add(Student.fromJson(item));
      }
      sharedPrefs.set('assignment_id', data['items'][0]['assignment_id'].toString());
      return items;
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    return [];
  }
}
