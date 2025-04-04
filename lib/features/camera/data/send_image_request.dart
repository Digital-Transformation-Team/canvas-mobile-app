import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'package:http/http.dart' as http;
import 'package:narxoz_face_id/core/consts.dart';
import 'package:narxoz_face_id/features/courses/data/get_courses_request.dart';

import '../../students/domain/students_class.dart';

Future<Student?> sendImage(image, task_id, course_id) async {
  // try {
  //   var response = dio.post(
  //     '/api/students/v1/search',
  //     options: Options(
  //       headers: {
  //         'Cookie': await getTokens(),
  //         'accept': 'application/json',
  //       },
  //     )
  //   );
  //   request.headers.addAll(<String, String>{
  //     'Content-Type': 'multipart/form-data',
  //     'accept': 'application/json',
  //   });
  //   Uint8List bytes = await image.readAsBytes();
  //   request.files.add(
  //     await http.MultipartFile.fromBytes(
  //       'file',
  //       filename: "image.jpeg",
  //       bytes,
  //       contentType: MediaType('image', 'jpeg'),
  //     ),
  //   );
  //   final response = await request.send().then((res) => res);
  //
  //   final data = await response.stream.bytesToString();
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return Student.fromJson(json.decode(data));
  //   } else {
  //     throw Exception("Ошибка загрузки ${response.statusCode}, $data");
  //   }
  // } catch (e) {
  //   print("Ошибка: $e");
  //   return null;
  // }
  return null;
}
