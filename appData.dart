import 'package:flutter/material.dart';

class AppDataProvider with ChangeNotifier {
  AppData appData = AppData();

  void updateGlobalText(String newText) {
    appData.idDelavca = newText;
    notifyListeners(); // Notify listeners to update widgets that depend on this data
  }
}



class AppData {
  bool prikazdelo=true;
  String idDelavca ="";
  String imePodjetja="";
}