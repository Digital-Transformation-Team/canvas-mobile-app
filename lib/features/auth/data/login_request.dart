import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:narxoz_face_id/core/consts.dart';
import 'package:narxoz_face_id/core/shared_prefs.dart';

import '../domain/user_class.dart';


/*
* 123@test.kz
* Ss123456
* */

Future<User?> login(BuildContext context, username, password) async {
  try {
    final response = await dio.post(
      '/api/auth/v1/signin',
      data: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final cookies = response.headers['set-cookie']!;
      for (String input in cookies) {
        List<String> parts = input.split(";");
        List<String> keyValue = parts[0].split("=");

        String name = keyValue[0].trim();
        String token = keyValue[1].trim();

        sharedPrefs.set(name, token);
      }
      var user = User(
        id: data['canvas_user']['id'],
        username: username,
        password: password,
        canvas_web_id: data['canvas_user']['web_id'],
        user_web_id: data['web_id'],
      );
      sharedPrefs.set(CURRENT_USER, user.toJson().toString());
      return user;
    } else {
      throw Exception("Ошибка загрузки");
    }
  } catch (e) {
    print("Ошибка: $e");
    return null;
  }
}

Future<User> get_user() async {
  var currentUserStr = await sharedPrefs.get(CURRENT_USER);
  var userJson = json.decode(currentUserStr!);
  User user = User.fromJson(userJson);
  return user;
}

Future<bool> is_authenticated() async {
  if (await sharedPrefs.contains(CURRENT_USER)) {
    return true;
  } else {
    return false;
  }
}

Future<void> logout() async {
  await sharedPrefs.clear();
}
