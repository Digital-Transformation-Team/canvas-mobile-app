import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:narxoz_face_id/features/auth/data/login_request.dart';
import 'package:narxoz_face_id/features/students/presentations/widget/student_card_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/LocaleProvider.dart';
import '../data/change_status_request.dart';
import '../data/get_students_request.dart';
import '../domain/students_class.dart';

class StudentsListScreen extends StatefulWidget {
  final String id;
  final String web_id;

  const StudentsListScreen({super.key, required this.web_id, required this.id});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  late PagingState<int, Student> _state = PagingState();
  final TextEditingController selectedController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchFirstPage() async {
    setState(() {
      _state = _state.copyWith(pages: [], keys: []);
    });

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newItems = await get_students(widget.id, 1);
      final isLastPage = newItems.isEmpty;

      setState(() {
        _state = _state.copyWith(
          pages: [newItems],
          keys: [1],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: "Something wrong", isLoading: false);
      });
    }
  }

  void _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? 0) + 1;
      print(newKey);
      final newItems = await get_students(widget.id, newKey);
      final isLastPage = newItems.isEmpty;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, newItems],
          keys: [...?_state.keys, newKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
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
      _fetchFirstPage();
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
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() => _fetchFirstPage()),
            child: PagedListView<int, Student>(
              state: _state,
              fetchNextPage: _fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder:
                    (context, item, index) => StudentCardWidget(
                      student: item,
                      index: index,
                      showStudentModalBottomSheet: showStudentModalBottomSheet,
                    ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        disabledElevation: 1,
        onPressed: () async {
          context.push('/camera');
        },
        child: Icon(Icons.camera_alt_rounded),
      ),
    );
  }
}
