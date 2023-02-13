import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List notesList = [];
  //reference our box

  final _myBox = Hive.box('mybox');

  //запускаем этот метод, когда приложение запускается первый раз
  void createInitialData() {
    notesList = [
      ['Купить хлеб', false],
      ['Купить молоко', false],
    ];
  }

  // загрузить data from database
  void loadData() {
    notesList = _myBox.get('TODOLIST');
  }

  //update database
  void upDateDataBase() {
    _myBox.put('TODOLIST', notesList);
  }
}
