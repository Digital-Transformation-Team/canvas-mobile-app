import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/shared_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSharedPrefs();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Подключаем маршруты
      debugShowCheckedModeBanner: false,
    );
  }
}
