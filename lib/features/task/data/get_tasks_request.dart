import 'package:narxoz_face_id/core/shared_prefs.dart';

import '../../../core/consts.dart';
import '../../courses/data/get_courses_request.dart';
import '../domain/tasks_class.dart';

Future<(String, List<Task>)> get_tasks(var course_id) async {
  try {
    var options = await getTokenOptions();
    String url =
        '/api/canvas-courses/v1/$course_id/attendance-assignment-group';
    final response = await dio.get(url, options: options);
    if (response.statusCode == 200) {
      final data = response.data;
      List<Task> items = [];
      for (var item in data['assignments']) {
        items.add(Task.fromJson(item));
      }
      String name = data['name'];
      sharedPrefs.set('groupId', data['assignment_group_id'].toString());
      return (name, items);
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    List<Task> tasks = [];
    return ('', tasks);
  }
}
