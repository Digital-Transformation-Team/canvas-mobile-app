import '../../../core/consts.dart';
import '../../courses/data/get_courses_request.dart';

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

Future<void> change_status(
  String webId,
  String asignmentWebId,
  String value,
) async {
  try {
    String url = '/api/attendances/v1/$asignmentWebId/mark';
    print(url);
    var options = await getTokenOptions();
    final response = await dio.put(
      url,
      options: options,
      data: {'value': value},
    );
    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    return;
  }
}
