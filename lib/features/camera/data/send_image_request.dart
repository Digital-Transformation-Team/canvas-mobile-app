import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:narxoz_face_id/core/shared_prefs.dart';

import '../../../core/consts.dart';
import '../../courses/data/get_courses_request.dart';

Future<bool> isOK() async {
  String? courseId = await sharedPrefs.get('course_id');
  String? assignmentId = await sharedPrefs.get('assignment_id');
  return courseId != null && assignmentId != null;
}

Future<String?> sendImage(image) async {
  String? courseId = await sharedPrefs.get('course_id');
  String? assignmentId = await sharedPrefs.get('assignment_id');
  print("courseId: $courseId");
  print("assignmentId: $assignmentId");
  try {
    Uint8List bytes = await image.readAsBytes();
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes as List<int>,
        filename: "image.jpeg",
        contentType: MediaType('image', 'jpeg'),
      ),
      'course_id': int.parse(courseId!),
      'assignment_id': int.parse(assignmentId!),
    });

    var tokens = await getTokens();
    var response = await dio.put(
      '/api/attendances/v1/mark/search',
      options: Options(
        headers: {'Cookie': tokens, 'Content-Type': 'multipart/form-data'},
      ),
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      return data["student"]["name"];
    } else {
      throw Exception("Ошибка загрузки ${response.statusCode}");
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print("Has response");
      print(e.response.toString());
      print(e.response!.data);
      print(e.response!.headers);
      print(e.response!.requestOptions);
      print(e.response!.statusCode);
      var data = e.response!.data;
      if (data['message'] == '_error_msg_student_not_found') {
        return null;
      }
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print(e.requestOptions);
      print(e.message);
    }
  } catch (e) {
    print("Ошибка: $e");
    return null;
  }
  return null;
}
