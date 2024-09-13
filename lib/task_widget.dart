import 'package:flutter/material.dart';

// Define the custom task widget
class TaskWidget extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  // Constructor to accept parameters
  const TaskWidget({
    Key? key,
    required this.title,
    required this.isCompleted,
    required this.onToggle,
    required this.onTap,
    required this.onLongPress
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: ListTile(

        leading: Checkbox(
          value: isCompleted,
          onChanged: (bool? value) {
            onToggle();
          },
        ),

        title: Text(
          title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),

      )
      // You can add more features here if needed
    );
  }
}
