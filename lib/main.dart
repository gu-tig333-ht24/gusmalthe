import 'package:flutter/material.dart';
import 'task_widget.dart';

class Task {
  String title;
  String body;
  bool isCompleted = false;

  Task({
    required this.title,
    required this.body,
  });
}

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // List to store tasks
  final List<Task> _tasks = [];

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _removeTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void _editTask(Task task, int index) {
    setState(() {
      _tasks[index] = task;
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,


              // ADD TASKS TO LIST
              itemBuilder: (context, index) {
                return TaskWidget(
                  title: _tasks[index].title,
                  isCompleted: _tasks[index].isCompleted,
                  onToggle: () => _toggleTask(index),
                  onLongPress: () => _removeTask(_tasks[index]),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskScreen(task: _tasks[index])),
                    );
                    _editTask(result, index);
                  }
                );
              },


            ),
          ),
        ],
      ),

      // ADD TASK BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskScreen(task: Task(title: "", body: ""))),
          );
          if (result != null) {
            _addTask(result);
          }
        },
        child: const Icon(Icons.add),
      ),


    );
  }
}


class TaskScreen extends StatelessWidget {
  final Task task;
  
  // CONSTRUCTOR
  const TaskScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    // Controller to capture the text input
    final TextEditingController taskTitleController = TextEditingController(text: task.title);
    final TextEditingController taskBodyController = TextEditingController(text: task.body);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TEXT
            const Text(
              "Create new task",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // TASK TITLE
            TextField(
              controller: taskTitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),

            // TASK BODY
            TextField(
              controller: taskBodyController,
              decoration: const InputDecoration(
                labelText: 'Task',
              ),
            ),

            const SizedBox(height: 20),

            // COMFIRM BUTTON
            ElevatedButton(
              onPressed: () {
                // When the confirm button is pressed, pop and return the task
                task.title = taskTitleController.text;
                task.body = taskBodyController.text;
                if (taskTitleController.text.isNotEmpty) {
                  Navigator.pop(context, task);
                }
              },
              child: const Text('Confirm'),
            ),

          ],
        ),
      ),
    );
  }
}
