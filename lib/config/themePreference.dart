import 'package:kan_q/config/config.dart';

class ThemePreference {
  setDarkTheme(bool value) async {
    KanQ.sharedPreferences.setBool(KanQ.themeStatus, value);
  }

  Future<bool> getTheme() async {
    return KanQ.sharedPreferences.getBool(KanQ.themeStatus) ?? false;
  }
}