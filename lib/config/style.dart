import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primaryColor: isDarkTheme ? Colors.deepPurple : Colors.green,
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
          .copyWith(background: isDarkTheme ? Colors.black : const Color(0xffF1F5FB),
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,),
      appBarTheme: AppBarTheme(
        color: isDarkTheme ? Colors.deepPurple : Colors.green,
      ),
    );
  }
}
