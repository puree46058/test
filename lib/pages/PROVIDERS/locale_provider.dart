import 'package:flutter/material.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en'); //ตั้งค่าภาษาเริ้มต้นของAPP ถ้าจะเริ่มเป็นภาษาไทยก็เปลี่ยนเป็น th

  Locale get locale => _locale;

  void updateLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners(); // แจ้งให้ Widget อัปเดตภาษา
  }
}
