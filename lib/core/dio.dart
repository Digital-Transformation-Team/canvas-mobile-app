import 'dart:io';
import 'package:dio/dio.dart';
import 'package:narxoz_face_id/core/consts.dart';

class DioClient {
  static Dio createDio() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: SERVER_URL,
        headers: {
          'Content-Type': 'application/json',
        },
      )
    );

    // Allow HTTP requests and ignore SSL certificate errors (for development only)
    (dio.httpClientAdapter as dynamic).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }
}
