import 'package:flutter/material.dart';
import 'package:instgram_clone/util/constants/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightmode;
  ThemeData get themeData => _themeData;
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggltheme() {
    if (_themeData == lightmode) {
      themeData = darkmode;
    } else {
      themeData = lightmode;
    }
  }
}
