import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:narxoz_face_id/features/auth/data/login_request.dart';
import 'package:narxoz_face_id/features/courses/domain/courses_class.dart';
import 'package:narxoz_face_id/features/courses/presentations/widgets/course_card_widget.dart';
import 'package:provider/provider.dart';

import '../../../core/LocaleProvider.dart';
import '../data/get_courses_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.courses_title),
        actions: [
          TextButton(
            onPressed: () {
              if (localeProvider.locale.languageCode == 'en') {
                localeProvider.setLocale(Locale('ru'));
              } else {
                localeProvider.setLocale(Locale('en'));
              }
            },
            child: Text(AppLocalizations.of(context)!.next_locale),
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
                  coursesFuture = get_courses();
                });
              },
              title: Text(AppLocalizations.of(context)!.courses_more_button),
              leading: Icon(Icons.cloud_download),
            ),
            FutureBuilder(
              future: coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(AppLocalizations.of(context)!.courses_loading_error));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.courses_empty));
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
