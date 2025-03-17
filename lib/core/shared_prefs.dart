import 'package:shared_preferences/shared_preferences.dart';

enum TokenType { CSRF, SESSION, LEGACY_SESSION }

class SharedPrefs {
  late var prefs;

  SharedPrefs({required this.prefs});

  Future<void> set(String type, String token) async {
    await prefs.setString(type, token);
  }

  Future<String?> get(String type) async {
    return await prefs.getString(type);
  }

  Future<void> remove(String type) async {
    await prefs.remove(type);
  }

  Future<void> clear() async {
    await prefs.clear();
  }

  Future<bool> contains(String type) async {
    return await prefs.containsKey(type);
  }
}

late SharedPrefs sharedPrefs;

Future<void> loadSharedPrefs() async =>
    sharedPrefs = SharedPrefs(prefs: await SharedPreferences.getInstance());
