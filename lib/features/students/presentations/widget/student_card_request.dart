import 'package:flutter/material.dart';

import '../../domain/students_class.dart';

class StudentCardWidget extends StatefulWidget {
  final int index;
  final Student student;
  final Function showStudentModalBottomSheet;

  const StudentCardWidget({
    super.key,
    required this.student,
    required this.index,
    required this.showStudentModalBottomSheet,
  });

  @override
  State<StudentCardWidget> createState() => _StudentCardWidgetState();
}

class _StudentCardWidgetState extends State<StudentCardWidget> {
  Icon? statusIcon;
  Icon? valueIcon;

  @override
  initState() {
    super.initState();
    setStatusIcon(widget.student.status, widget.student.value);
  }

  void setStatusIcon(String status, String value) {
    switch (status) {
      case "INITIATED":
        statusIcon = Icon(Icons.access_time, color: Colors.grey);
        break;
      case "IN_PROGRESS":
        statusIcon = Icon(Icons.access_time, color: Colors.grey);
        break;
      default:
        statusIcon = Icon(Icons.access_time, color: Colors.transparent);
    }

    switch (value) {
      case "complete":
        valueIcon = Icon(Icons.check, color: Colors.green);
        break;
      case "incomplete":
        valueIcon = Icon(Icons.close, color: Colors.red);
        break;
      case "excuse":
        valueIcon = Icon(Icons.sick_outlined, color: Colors.blue);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(widget.student.name, style: TextStyle(fontSize: 18)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [statusIcon!, valueIcon!],
        ),
        onTap: () {
          widget.showStudentModalBottomSheet(widget.student, widget.index);
        },
      ),
    );
  }
}
