import 'package:flutter/material.dart';
import 'dart:convert'; 
class Task {
  String id;
  String title;
  String body;
  bool isCompleted;

  static String separator = '\u200B'; // Zero-width space as separator

  Task({
    required this.id,
    required this.title,
    required this.body,
    this.isCompleted = false,
  });

  // Factory constructor to create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    String splitTitle;
    String splitBody;
    [splitTitle, splitBody] = json['title'].split(Task.separator);
    return Task(
      id: json['id'],
      title: splitTitle,
      body: splitBody,
      isCompleted: json['done'],
    );
  }

  String todoAPIFormat() {
     Map<String, dynamic> jsonObject = {
      "id": id,
      "title": '$title$separator$body',
      "done": isCompleted,
    };
    return jsonEncode(jsonObject);
  }
}

class TaskWidget extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete; 

  const TaskWidget({
    super.key,
    required this.title,
    required this.isCompleted,

    required this.onTap,
    
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [

            Checkbox(
              value: isCompleted,
              onChanged: (bool? value) {
                onToggle();
              },
            ),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null, // so clean
                  fontSize: 18
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDelete,
            )
                      ],
        ),

      ),
    );
  }
}
