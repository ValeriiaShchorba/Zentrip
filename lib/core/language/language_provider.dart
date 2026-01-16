import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'TR';

  String get currentLanguage => _currentLanguage;

  void changeLanguage(String lang) {
    if (_currentLanguage == lang) return;
    _currentLanguage = lang;
    notifyListeners();
  }
}
