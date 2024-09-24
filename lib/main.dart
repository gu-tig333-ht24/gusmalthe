import 'package:flutter/material.dart';
import 'task_widget.dart';
import 'todo_api.dart';
import 'package:multi_dropdown/multi_dropdown.dart'; // I found a package for a dropdown menu at: https://pub.dev/packages/multi_dropdown/install

void main() {
  runApp(const TodoApp());
}

Route _taskScreenRoute(Task task) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TaskScreen(task: task),
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide in from the right
      const end = Offset.zero;
      const curve = Curves.easeInOut; // Smooth transition

      var tween = Tween(begin: begin, end: end);
      var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
      var offsetAnimation = tween.animate(curvedAnimation);

      return SlideTransition(
        position: offsetAnimation,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 80,
                spreadRadius: 80
              ),
            ],
          ),
          child: child,
        ),
      );
    },
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      debugShowCheckedModeBanner: false, // Hides the debug banner in the AppBar
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 132, 201, 87),
          // brightness: Brightness.dark,
        ),
        // appBarTheme: AppBarTheme(),
        // scaffoldBackgroundColor: const Color.fromARGB(255, 50, 56, 56),
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
  final List<Task> _tasks = [];
  bool filterFinished = false;
  bool filterUnfinished = false;
  Future<void> _loadTasks(List<String> filter) async {
    try {
      List<Task> tasks = await fetchTodosAsTasks(API_KEY);
      if (filter.isNotEmpty) {
        List<Task> filteredTasks = tasks.where((task) {
          if (filter.contains("Finished") && task.isCompleted) {
            return false;
          }
          if (filter.contains("Unfinished") && !task.isCompleted) {
            return false;
          }
          return true;
        }).toList();

        setState(() {
          _tasks.clear();
          _tasks.addAll(filteredTasks);
        });
      }
      else{
        setState(() {
          _tasks.clear();
          _tasks.addAll(tasks);
        });
      }

    } catch (e) {
      print('Error loading tasks: $e');
    }
  }
  void _addTask(Task task) async {
    // We need to do this so that the added task has an id
    var addedTodo = await addTodo(API_KEY, task);
    var addedTask = Task.fromJson(addedTodo);
    setState(() {
      _tasks.add(addedTask);
    });
  }
  void _removeTask(Task task) async {
    await deleteTodo(API_KEY, task);
    setState(() {
      _tasks.remove(task);
    });
  }
  void _editTask(Task task, int index) async {
    await updateTodo(API_KEY, task);
    setState(() {
      _tasks[index] = task;
    });
  }
  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      updateTodo(API_KEY, task);
    });
  }
  
  @override
  void initState() {
    super.initState();
    _loadTasks(List.empty());
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
          Padding(padding: const EdgeInsets.only(top: 2.5, left: 5, right: 5),
            child: MultiDropdown<String>(
              items: [
                DropdownItem(label: "Finished", value: "Finished"),
                DropdownItem(label: "Unfinished", value: "Unfinished")
              ],
              enabled: true,
              fieldDecoration: FieldDecoration(
                hintText: 'Hide',
                hintStyle: const TextStyle(color: Colors.black87),
                prefixIcon: const Icon(Icons.filter_alt),
                showClearIcon: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black87,
                  ),
                ),
              ),
              onSelectionChange: (selectedItems) {
                _loadTasks(selectedItems);
              },
            ),
          ),
          Expanded(child: ListView.builder(
            itemCount: _tasks.length,
            // ADD TASKS TO LIST
            itemBuilder: (context, index) {
              return TaskWidget(
                title: _tasks[index].title,
                isCompleted: _tasks[index].isCompleted,

                onTap: () async {
                  final result = await Navigator.of(context).push(_taskScreenRoute(_tasks[index]));
                  if (result != null) {
                    _editTask(result, index);
                  }
                },
                onToggle: () => _toggleTask(_tasks[index]),
                onDelete: () => _removeTask(_tasks[index]),
              );
            },
          ),)
          
        ],
      ),
      // ADD TASK BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(_taskScreenRoute(Task(id: "", title: "", body: "")));
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
    final TextEditingController taskTitleController = TextEditingController(text: task.title);
    final TextEditingController taskBodyController = TextEditingController(text: task.body);
    String taskContextTitle;
    if (task.title != ""){
      taskContextTitle = "Edit task";
    }
    else{
      taskContextTitle = "Create New Task";
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only( left: 40, right: 40, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TEXT
            Text(
              taskContextTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                ),
            ),

            const SizedBox(height: 20),

            // TASK TITLE
            TextField(
              controller: taskTitleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Title',
              ),
            ),

            const SizedBox(height: 20),

            // TASK BODY
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              controller: taskBodyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Add Note...',
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
