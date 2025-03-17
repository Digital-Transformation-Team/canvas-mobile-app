import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/core/overlays/loading_overlay.dart';
import 'package:narxoz_face_id/features/task/data/create_new_task_request.dart';
import 'package:narxoz_face_id/features/task/domain/tasks_class.dart';
import 'package:narxoz_face_id/features/task/presentations/widgets/task_card_widget.dart';

import '../../auth/data/login_request.dart';
import '../data/get_tasks_request.dart';

class TasksListScreen extends StatefulWidget {
  final String courseId;

  const TasksListScreen({super.key, required this.courseId});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  late Future<(String, List<Task>)> tasksFuture;
  late String name;

  @override
  void initState() {
    super.initState();
    tasksFuture = initTasks();
    name = "";
  }


  Future<(String, List<Task>)> initTasks() async {
    return await get_tasks(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                setState(() {
                  tasksFuture = get_tasks(widget.courseId);
                });
              },
              title: Text("More tasks"),
              leading: Icon(Icons.cloud_download),
            ),
            FutureBuilder(
              future: tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Ошибка загрузки данных"));
                } else if (!snapshot.hasData) {
                  return Center(child: Text("Нет тасков"));
                }

                final (name, tasks) = snapshot.data!;

                if (tasks.isEmpty) {
                  return Center(child: Text("Нет тасков"));
                }

                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCardWidget(
                        task: tasks[index],
                        courseId: widget.courseId,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LoadingOverlay.show(context);
          var (name, tasks) = await tasksFuture;
          tasks.insert(0, await create_task(widget.courseId));
          setState(() {
            tasksFuture = Future.value((name, tasks));
          });
          LoadingOverlay.hide();
        },
        child: Icon(Icons.add_task),
      ),
    );
  }
}
