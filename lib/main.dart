// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hivetutorial/data/database.dart';

void main() async {
  //init hive
  await Hive.initFlutter();

  //open a box
  var box = await Hive.openBox('mybox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'МОИ ЗАМЕТКИ',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MyHomePage(),
    );
  }
}

//MYHOMEPAGE
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //reference hive box

  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    //  если открывается первый раз, то создаем data по умолчанию

    if (_myBox.get('TODOLIST') == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  final _controller = TextEditingController();

  // change chekbox
  void chekBoxChanged(bool? value, int index) {
    setState(() {
      db.notesList[index][1] = !db.notesList[index][1];
    });
    db.upDateDataBase();
  }

  //save new note
  void saveNewNote() {
    setState(() {
      db.notesList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.upDateDataBase();
  }

  //create new note
  void createNewNote() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSaved: saveNewNote,
            onCansel: () => Navigator.of(context).pop(),
          );
        });
  }

  //delete note
  void deleteNote(int index) {
    setState(() {
      db.notesList.removeAt(index);
    });
    db.upDateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('СПИСОК ДЕЛ'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewNote,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.notesList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            noteName: db.notesList[index][0],
            noteCompleted: db.notesList[index][1],
            onChanged: (value) => chekBoxChanged(value, index),
            deleteFunction: (context) => deleteNote(index),
          );
        },
      ),
    );
  }
}

//TODOTILE
class ToDoTile extends StatelessWidget {
  final String noteName;
  final bool noteCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;

  ToDoTile(
      {super.key,
      required this.noteName,
      required this.noteCompleted,
      required this.onChanged,
      required this.deleteFunction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.deepOrange[100]),
          child: Row(
            children: [
              Checkbox(
                value: noteCompleted,
                onChanged: onChanged,
                activeColor: Colors.black12,
              ),
              Text(
                noteName,
                style: TextStyle(
                  fontSize: 16,
                  decoration: noteCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//DIALOG BOX
class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSaved;
  VoidCallback onCansel;
  DialogBox(
      {super.key,
      required this.controller,
      required this.onSaved,
      required this.onCansel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 120,
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Добавить задачу',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  onPressed: onSaved,
                  text: 'Добавить',
                ),
                MyButton(
                  onPressed: onCansel,
                  text: 'Отмена',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//MY BUTTON
class MyButton extends StatelessWidget {
  final String text;
  VoidCallback onPressed;

  MyButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Theme.of(context).primaryColor,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
