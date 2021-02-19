import 'package:flutter/material.dart';

class ActivePage with ChangeNotifier {
  int index = 0;

  void changeIndex(index) {
    this.index = index;
    notifyListeners();
  }
}