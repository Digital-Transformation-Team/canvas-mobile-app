import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  late PagingState<int, Course> _state = PagingState();

  void _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? 0) + 1;
      final newItems = await get_courses(newKey);
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

  @override
  void initState() {
    super.initState();
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
        child: PagedListView<int, Course>(
          state: _state,
          fetchNextPage: _fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder:
                (context, item, index) =>
                    CourseCardWidget(course: item, index: index),
          ),
        ),
      ),
    );
  }
}
