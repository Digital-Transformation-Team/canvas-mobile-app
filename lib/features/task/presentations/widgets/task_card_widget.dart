import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/tasks_class.dart';

class TaskCardWidget extends StatelessWidget {
  final String courseId;
  final Task task;

  const TaskCardWidget({super.key, required this.task, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(task.name, style: TextStyle(fontSize: 18)),
        leading: Icon(Icons.task_alt, color: Colors.green),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey),
        onTap: () {
          context.push('/tasks/${task.web_id}');
        },
      ),
    );
  }
}
