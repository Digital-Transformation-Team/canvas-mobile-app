import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/features/auth/data/login_request.dart';
import 'package:narxoz_face_id/features/students/presentations/widget/student_card_request.dart';

import '../data/get_students_request.dart';
import '../domain/students_class.dart';

class StudentsListScreen extends StatefulWidget {
  final String task_id;
  final String course_id;

  const StudentsListScreen({super.key, required this.task_id, required this.course_id});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  late Future<List<Student>> studentsFuture;

  @override
  void initState() {
    super.initState();
    studentsFuture = initStudents();
  }

  Future<List<Student>> initStudents() async {
    return get_students(widget.course_id, widget.task_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
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
                context.push('/courses/${widget.course_id}/tasks/${widget.task_id}/camera');
              },
              title: Text("Camera attendance"),
              leading: Icon(Icons.camera_alt_rounded),
            ),
            FutureBuilder(
              future: studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Ошибка загрузки данных"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Нет студентов"));
                }

                final students = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return StudentCardWidget(student: students[index], index: index);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
