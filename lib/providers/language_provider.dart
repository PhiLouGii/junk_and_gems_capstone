import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isSesotho = false;

  bool get isSesotho => _isSesotho;

  void toggleLanguage(bool value) {
    _isSesotho = value;
    notifyListeners();
  }
}
