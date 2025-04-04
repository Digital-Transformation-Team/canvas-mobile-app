import 'package:dio/dio.dart';

import '../../../core/consts.dart';
import '../../../core/shared_prefs.dart';
import '../../auth/data/login_request.dart';
import '../domain/courses_class.dart';

Future<String> getTokens() async {
  return '$CSRF_TOKEN=${await sharedPrefs.get(CSRF_TOKEN)}; '
      '$SESSIONID=${await sharedPrefs.get(SESSIONID)}; '
      '$LEGACY_SESSION=${await sharedPrefs.get(LEGACY_SESSION)}; '
      '$NORMANDY_SESSION=${await sharedPrefs.get(NORMANDY_SESSION)}';
}

Future<Options> getTokenOptions() async {
  return Options(
    headers: {
      'Cookie': await getTokens(),
      'accept': 'application/json',
      'Content-Type': 'application/json'
    },
  );
}

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

// Future<List<Course>> get_more_classes() async {
//   try {
//     final response = await http.get(
//       Uri.parse('https://example.com/api/classes'),
//     );
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data
//           .map((e) => Course.fromJson(e))
//           .toList(); // Преобразуем в List<String>
//     } else {
//       throw Exception("Ошибка загрузки");
//     }
//   } catch (e) {
//     print("Ошибка: $e");
//     return []; // Если ошибка — возвращаем пустой список
//   }
// }

Future<List<Course>> get_courses() async {
  try {
    var options = await getTokenOptions();
    var user = await get_user();
    final response = await dio.get(
      '/api/canvas-courses/v1/',
      queryParameters: {
        'canvas_user_id': user.id,
        'page': 1,
        'per_page': 10,
        'order_by': 'id',
        'asc': true,
      },
      options: options,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      print(data);
      List<Course> items = [];
      for (var item in data['items']) {
        items.add(Course.fromJson(item));
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
