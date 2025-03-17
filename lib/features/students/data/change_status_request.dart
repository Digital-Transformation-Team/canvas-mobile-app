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

Future<void> change_status(Student student) async {
  Future.delayed(Duration(seconds: 2));
}
