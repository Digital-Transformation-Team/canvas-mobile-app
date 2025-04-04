import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/LocaleProvider.dart';
import 'core/routes/app_router.dart';
import 'core/shared_prefs.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSharedPrefs();
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: MyApp(),
    ),
  );
}

Future<void> setLocale(LocaleProvider localeProvider) async {
  localeProvider.setLocale(Locale(await sharedPrefs.get('locale') ?? "en"));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    setLocale(localeProvider);

    return MaterialApp.router(
      routerConfig: router,
      // Подключаем маршруты
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
