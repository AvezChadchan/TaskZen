import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do-App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      tasks = List<Map<String, dynamic>>.from(jsonDecode('tasks'));
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String taskJson = jsonEncode('tasks');
    await prefs.setString('tasks', taskJson);
  }

  void addTask(String task) {
    String formattedTime = TimeOfDay.now().format(context);
    setState(() {
      tasks.add({'task': task, 'completed': false, 'time': formattedTime});
    });
    saveTasks();
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
    saveTasks();
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  void showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "New Task",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCCD6F6)),
            ),
            content: TextField(
              controller: taskController,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF112240),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )),
              TextButton(
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      addTask(taskController.text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "To-Do List",
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFFCCD6F6)),
        ),
        centerTitle: true,
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.only(top: 18,left: 14,right: 14,bottom: 18),
            child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Color(0xFF020C1B),
                    child: ListTile(
                        title: Text(
                          tasks[index]['task'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                            color: Color(0xFFCCD6F6),
                            decoration: tasks[index]["completed"]
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text("Added at: ${tasks[index]['time']}",
                            style: TextStyle(color: Colors.white)),
                        leading: Checkbox(
                          value: tasks[index]["completed"],
                          onChanged: (value) {
                            toggleTask(index);
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            removeTask(index);
                          },
                        )),
                  );
                }),
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF020C1B),
        onPressed: () {
          showAddTaskDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 33,
        ),
      ),
    );
  }
}
