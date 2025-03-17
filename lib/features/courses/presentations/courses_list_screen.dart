import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/features/auth/data/login_request.dart';
import 'package:narxoz_face_id/features/courses/domain/courses_class.dart';
import 'package:narxoz_face_id/features/courses/presentations/widgets/course_card_widget.dart';

import '../data/get_courses_request.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  late Future<List<Course>> coursesFuture;

  @override
  void initState() {
    super.initState();
    coursesFuture = initClasses();
  }

  Future<List<Course>> initClasses() async {
    return await get_courses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
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
                  coursesFuture = get_courses();
                });
              },
              title: Text("More courses"),
              leading: Icon(Icons.cloud_download),
            ),
            FutureBuilder(
              future: coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Ошибка загрузки данных"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Нет классов"));
                }

                final classes = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    return CourseCardWidget(
                      course: classes[index],
                      index: index,
                    );
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
