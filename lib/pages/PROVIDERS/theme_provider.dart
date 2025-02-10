import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode
      .light; //ตั้งค่าโหมด สีขาวเป็น .light  ถ้าเริ่มต้นเป็นสีดำ .system

  ThemeMode get themeMode => _themeMode;

  void updateThemeMode(ThemeMode newMode) {
    _themeMode = newMode;
    notifyListeners(); // แจ้งให้ Widget อัปเดตธีม
  }
}

