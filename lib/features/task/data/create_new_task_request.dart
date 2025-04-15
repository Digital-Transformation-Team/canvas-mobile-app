import 'package:narxoz_face_id/core/shared_prefs.dart';

import '../../../core/consts.dart';
import '../../courses/data/get_courses_request.dart';
import '../domain/tasks_class.dart';

Future<Task> create_task(var courseId) async {
  try {
    var options = await getTokenOptions();
    String? assignmentGroupWebId = await sharedPrefs.get("assignment_group_web_id");
    String url = '/api/canvas-courses/v1/$courseId/assignment-groups/$assignmentGroupWebId/assignments';
    print(url);
    final response = await dio.post(
      url,
      options: options,
    ).catchError((e) {
      if (e.response != null) {
        print("Has response");
        print(e.response.data);
        print(e.response.headers);
        print(e.response.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
      throw e;
    });
    if (response.statusCode == 201) {
      final data = response.data;
      Task task = Task.fromJson(data);
      return task;
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    Task task = Task(id: 0, name: '', web_id: '');
    return task;
  }
}
