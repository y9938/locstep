import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Confirm3dTourProvider extends ChangeNotifier {
  static const String _key = 'confirm_before_open_3d_tour';

  bool _askBeforeOpening = true;

  bool get askBeforeOpening => _askBeforeOpening;

  Confirm3dTourProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _askBeforeOpening = prefs.getBool(_key) ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> setAskBeforeOpening(bool value) async {
    if (_askBeforeOpening == value) return;
    _askBeforeOpening = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    notifyListeners();
  }
}
