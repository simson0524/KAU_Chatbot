import 'package:flutter/material.dart';

class CharacterProvider with ChangeNotifier {
  String _character = '';

  String get character => _character;

  void setCharacter(String character) {
    _character = character;
    notifyListeners();
  }
}
