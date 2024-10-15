import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task_widget.dart';

// Base URL for the API
const String apiUrl = 'https://todoapp-api.apps.k8s.gu.se';
const API_KEY = 'ff51099b-cfe2-4982-9bfb-1ba3c74a36dc';

// Fetch API key from the /register endpoint
Future<String> getApiKey() async {
  final response = await http.get(Uri.parse('$apiUrl/register'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to register API key');
  }
}

// Fetch all todos
Future<List<dynamic>> fetchTodos(String apiKey) async {
  final response = await http.get(Uri.parse('$apiUrl/todos?key=$apiKey'));
  if (response.statusCode == 200) {
    print("Todos successfully loaded");
    return jsonDecode(response.body);
  }
  else {
    throw Exception('Failed to load todos');
  }
  
}

// Adds and returns a new todo
Future<dynamic> addTodo(String apiKey, Task task) async {
  final response = await http.post(
    Uri.parse('$apiUrl/todos?key=$apiKey'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: task.todoAPIFormat(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to add todo');
  }
  else {
    print("Todo successfully added");
    var todos = jsonDecode(response.body) as List<dynamic>;
    return todos.last;
  }
}


// Update an existing todo
Future<void> updateTodo(String apiKey, Task task) async {
  String id = task.id;
  final response = await http.put(
    Uri.parse('$apiUrl/todos/$id?key=$apiKey'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: task.todoAPIFormat(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update todo');
  }
  else {
    print("Todo successfully updated");
  }
}

// Delete a todo
Future<void> deleteTodo(String apiKey, Task task) async {
  String id = task.id;
  final response = await http.delete(
    Uri.parse('$apiUrl/todos/$id?key=$apiKey'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete todo');
  }
  else {
    print("Todo successfully deleted");
  }
}

// Convert a list of todos to a list of Tasks
List<Task> todosToTasks(List<dynamic> todos) {
  List<Task> tasks = [];
  for (var todo in todos) {
    Task task = Task.fromJson(todo);
    tasks.add(task);
  }
  return tasks;
}

// Fetch all todos as Tasks
Future<List<Task>> fetchTodosAsTasks(String apiKey) async {
  List<dynamic> todos = await fetchTodos(apiKey);
  return todosToTasks(todos);
}