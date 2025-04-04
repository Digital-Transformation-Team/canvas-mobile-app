import 'package:flutter/material.dart';
import 'package:narxoz_face_id/core/shared_prefs.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'ru'].contains(locale.languageCode)) return;
    _locale = locale;
    sharedPrefs.set('locale', locale.languageCode);
    notifyListeners(); // Уведомляем, что язык изменился
  }
}
