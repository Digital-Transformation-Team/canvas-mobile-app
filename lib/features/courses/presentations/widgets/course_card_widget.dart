import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/features/courses/domain/courses_class.dart';

class CourseCardWidget extends StatelessWidget {
  final int index;
  final Course course;

  const CourseCardWidget({Key? key, required this.course, required this.index})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(course.name, style: TextStyle(fontSize: 18)),
        leading: Icon(Icons.class_, color: Colors.green),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey),
        onTap: () {
          context.push('/courses/${course.web_id}');
        },
      ),
    );
  }
}
