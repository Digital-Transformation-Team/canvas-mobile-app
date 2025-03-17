import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

import 'package:http/http.dart' as http;

import '../../students/domain/students_class.dart';

Future<Student?> sendImage(image, task_id, course_id) async {
  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse('http://10.2.6.155:8010/api/students/v1/search'),
    );
    request.headers.addAll(<String, String>{
      'Content-Type': 'multipart/form-data',
      'accept': 'application/json',
    });
    Uint8List bytes = await image.readAsBytes();
    request.files.add(
      await http.MultipartFile.fromBytes(
        'file',
        filename: "image.jpeg",
        bytes,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    final response = await request.send().then((res) => res);

    final data = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Student.fromJson(json.decode(data));
    } else {
      throw Exception("Ошибка загрузки ${response.statusCode}, $data");
    }
  } catch (e) {
    print("Ошибка: $e");
    return null;
  }
}
