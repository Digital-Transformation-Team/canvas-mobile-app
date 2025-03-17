import 'package:flutter/material.dart';

import '../../domain/students_class.dart';

class StudentCardWidget extends StatefulWidget {
  final int index;
  final Student student;

  const StudentCardWidget({
    super.key,
    required this.student,
    required this.index,
  });

  @override
  State<StudentCardWidget> createState() => _StudentCardWidgetState();
}

class _StudentCardWidgetState extends State<StudentCardWidget> {
  Icon? icon;
  String? selectedValue;

  @override
  initState() {
    super.initState();
    setStatusIcon(widget.student.status);
  }

  void setStatusIcon(String status) {
    switch (status) {
      case "COMPLETED":
        icon = Icon(Icons.check, color: Colors.green);
        break;
      case "INITIATED":
        icon = Icon(Icons.close, color: Colors.red);
        break;
      case "IN_PROGRESS":
        icon = Icon(Icons.pending, color: Colors.black);
        break;
      case "excuse":
        icon = Icon(Icons.sick, color: Colors.blue);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(
          widget.student.name,
          style: TextStyle(fontSize: 18),
        ),
        trailing: icon,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      widget.student.name,
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                    Column(
                      children: [
                        DropdownMenu(
                          onSelected: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: "checked",
                              label: "Attend",
                              labelWidget: ListTile(
                                title: Text("Attend"),
                                leading: Icon(Icons.check, color: Colors.green),
                              )
                            ),
                            DropdownMenuEntry(
                              value: "not_checked",
                                label: "Not attend",
                                labelWidget: ListTile(
                                  title: Text("Not attend"),
                                  leading: Icon(Icons.close, color: Colors.red),
                                )
                            ),
                            DropdownMenuEntry(
                              value: "not_checked_2",
                                label: "Has reason to not attend",
                                labelWidget: ListTile(
                                  title: Text("Has reason to not attend"),
                                  leading: Icon(Icons.sick_outlined, color: Colors.blue),
                                )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
