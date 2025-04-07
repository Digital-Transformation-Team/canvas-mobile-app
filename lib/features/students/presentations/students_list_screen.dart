import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/features/auth/data/login_request.dart';
import 'package:narxoz_face_id/features/students/presentations/widget/student_card_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/LocaleProvider.dart';
import '../data/change_status_request.dart';
import '../data/get_students_request.dart';
import '../domain/students_class.dart';

class StudentsListScreen extends StatefulWidget {
  final String web_id;

  const StudentsListScreen({
    super.key,
    required this.web_id,
  });

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  late Future<List<Student>> studentsFuture;
  final TextEditingController selectedController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    studentsFuture = initStudents();
  }

  Future<List<Student>> initStudents() async {
    return get_students(widget.web_id);
  }

  void showStudentModalBottomSheet(student, index) {
    setState(() {
      selectedValue = student.value;
    });
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
              Text(student.name, style: TextStyle(fontSize: 20)),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Column(
                children: [
                  DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: "complete",
                        child: Text(
                          AppLocalizations.of(context)!.students_attend,
                        ),
                      ),
                      DropdownMenuItem(
                        value: "incomplete",
                        child: Text(
                          AppLocalizations.of(context)!.students_not_attend,
                        ),
                      ),
                      DropdownMenuItem(
                        value: "excuse",
                        child: Text(
                          AppLocalizations.of(context)!.students_excuse,
                        ),
                      ),
                    ],
                  ),
                  // DropdownMenu(
                  //   initialSelection: student.value,
                  //   controller: selectedController,
                  //   onSelected: (value) {
                  //     setState(() {
                  //       selectedValue = value.toString();
                  //     });
                  //   },
                  //   dropdownMenuEntries: [
                  //     DropdownMenuEntry(
                  //       value: "complete",
                  //       label: AppLocalizations.of(context)!.students_attend,
                  //       labelWidget: ListTile(
                  //         title: Text(
                  //           AppLocalizations.of(context)!.students_attend,
                  //         ),
                  //         leading: Icon(Icons.check, color: Colors.green),
                  //       ),
                  //     ),
                  //     DropdownMenuEntry(
                  //       value: "incomplete",
                  //       label:
                  //           AppLocalizations.of(context)!.students_not_attend,
                  //       labelWidget: ListTile(
                  //         title: Text(
                  //           AppLocalizations.of(context)!.students_not_attend,
                  //         ),
                  //         leading: Icon(Icons.close, color: Colors.red),
                  //       ),
                  //     ),
                  //     DropdownMenuEntry(
                  //       value: "excuse",
                  //       label: AppLocalizations.of(context)!.students_excuse,
                  //       labelWidget: ListTile(
                  //         title: Text(
                  //           AppLocalizations.of(context)!.students_excuse,
                  //         ),
                  //         leading: Icon(
                  //           Icons.sick_outlined,
                  //           color: Colors.blue,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              ElevatedButton(
                onPressed: () async {
                  context.pop();
                  await change_status(
                    widget.web_id,
                    student.web_id_assignment,
                    selectedValue!,
                  );
                  onStatusChanged();
                },
                child: Text(
                  AppLocalizations.of(context)!.students_send_attendance,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onStatusChanged() {
    setState(() {
      studentsFuture = initStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: [
          TextButton(
            onPressed: () {
              if (localeProvider.locale.languageCode == 'en') {
                localeProvider.setLocale(Locale('ru'));
              } else {
                localeProvider.setLocale(Locale('en'));
              }
            },
            child: Text(AppLocalizations.of(context)!.localeName),
          ),
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
                  studentsFuture = initStudents();
                });
              },
              title: Text(AppLocalizations.of(context)!.students_reload_page),
              leading: Icon(Icons.refresh),
            ),
            FutureBuilder(
              future: studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.students_loading_error,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.students_empty),
                  );
                }

                final students = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return StudentCardWidget(
                      student: students[index],
                      index: index,
                      showStudentModalBottomSheet: showStudentModalBottomSheet,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        disabledElevation: 1,
        onPressed: () async {
          // context.push('/courses/${widget.course_id}/tasks/${widget.task_id}/camera');
        },
        child: Icon(Icons.camera_alt_rounded),
      ),
    );
  }
}
