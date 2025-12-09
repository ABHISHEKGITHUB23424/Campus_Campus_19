import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/class_selector_page.dart';
import 'pages/attendance_take_page.dart';
import 'pages/student_list_page.dart';
import 'pages/attendance_summary_page.dart';
import 'pages/student_report_page.dart';
import 'pages/add_class_page.dart';
import 'data/models/class_model.dart';

/// Router configuration for attendance module
class AttendanceRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/attendance',
    routes: [
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ClassSelectorPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/attendance/take',
        name: 'attendance-take',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AttendanceTakePage(
              classId: extra['classId'] as int,
              classInfo: extra['classInfo'] as ClassModel,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/attendance/students',
        name: 'student-list',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StudentListPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/attendance/summary',
        name: 'attendance-summary',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AttendanceSummaryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/attendance/report',
        name: 'student-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StudentReportPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/attendance/add-class',
        name: 'add-class',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddClassPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}
