import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  Box? box;
  String? _newTaskContent;

  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.08,
        title: const Text(
          "Taskly!",
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

//This will initialize the hive database and will check if the connection is successful
  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          //here  i get the data from the hive database and pass it to a box type variable
          box = _snapshot.data;
          //Then I excecute the _taskList widget
          return _tasksList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _tasksList() {
    //The first thing to do here is to get a list of tasks obgects from box
    List tasks = box!.values.toList();
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext _context, int _index) {
          var task = Task.fromMap(tasks[_index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(task.timestamp.toString()),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,
              color: Colors.red,
            ),
            //On tap here the accion when a item on the list is taped
            onTap: () {
              task.done = !task.done;
              box!.putAt(_index, task.toMap());
              setState(() {});
            },
            //on long press i will be deleting the item at the position
            onLongPress: () {
              box!.deleteAt(_index);
              setState(() {});
            },
          );
        });
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add new Task!"),
          content: TextField(
            onSubmitted: (_value) {
              if (_newTaskContent != null) {
                var task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                box?.add(task.toMap());
              } else {
                _value = "You should add something";
              }
              setState(() {
                _newTaskContent = null;
                _taskView();
                Navigator.pop(context);
              });
            },
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
              });
            },
          ),
        );
      },
    );
  }
}
