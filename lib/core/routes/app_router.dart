import 'package:go_router/go_router.dart';

import '../../features/auth/presentations/login_screen.dart';
import '../../features/camera/presentations/camera_screen.dart';
import '../../features/students/presentations/students_list_screen.dart';
import '../../features/task/presentations/tasks_list_screen.dart';
import '../../features/courses/presentations/courses_list_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => "/courses"),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/camera', builder: (context, state) => CameraScreen()),
    GoRoute(path: '/courses', builder: (context, state) => CoursesListScreen()),
    GoRoute(
      path: '/courses/:courseId',
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!; // Получаем ID
        return TasksListScreen(courseId: courseId);
      },
    ),
    GoRoute(
      path: '/tasks/:web_id',
      builder: (context, state) {
        final webId = state.pathParameters['web_id']!; // Получаем ID
        return StudentsListScreen(web_id: webId);
      },
    ),
  ],
);
