import 'package:bhfit/pages/feedback/feedback_channel_page.dart';
import 'package:bhfit/pages/machines/machine_exercise.dart';
import 'package:bhfit/pages/news/news_post_page.dart';
import 'package:bhfit/pages/workouts/exercise_details_page.dart';
import 'package:bhfit/pages/home_page.dart';
import 'package:bhfit/pages/account/login_page.dart';
import 'package:bhfit/pages/news/news_details_page.dart';
import 'package:bhfit/pages/account/password_reset_page.dart';
import 'package:bhfit/pages/workouts/exercise_info_page.dart';
import 'package:bhfit/pages/workouts/exercise_list_page.dart';
import 'package:bhfit/pages/workouts/plan_exercises_page.dart';
import 'package:bhfit/pages/splash_page.dart';
import 'package:bhfit/pages/workouts/user_exercises_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://vtwqasaslqttefzvbzhb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0d3Fhc2FzbHF0dGVmenZiemhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDA0NjU1ODMsImV4cCI6MjAxNjA0MTU4M30.w4TDPKI_8-jjvVgs6pDy1ofJPHjMrdpn210H4bQG5fc',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        // splash page
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        // login page
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        // password reset page
        path: '/passreset',
        builder: (context, state) => const PassResetPage(),
      ),
      GoRoute(
        // home page
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        // specific post details page
        path: '/post/details/:id',
        builder: (context, state) =>
            DetailsPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        // new news feed post creation page
        path: '/post/new',
        builder: (context, state) => const PostNews(),
      ),
      GoRoute(
        // user exercises page
        // name: RouteName,
        path: '/exercises',
        builder: (context, state) {
          final toAdd = state.extra as bool?;
          if (toAdd != null && toAdd == true) {
            return const ExercisesPage(
              toAdd: true,
            );
          }
          return const ExercisesPage();
        },
      ),
      GoRoute(
        // List of unconnected Exercises
        path: '/exercise/list',
        builder: (context, state) => const ExerciseListPage(),
      ),
      GoRoute(
        // page to view a plan's exercises
        path: '/plan/exercises/:id/:title',
        builder: (context, state) => PlanExercisesPage(
          planid: state.pathParameters['id']!,
          planName: state.pathParameters['title']!,
        ),
      ),
      GoRoute(
        // feedback channel page for specific plan
        path: '/plan/feedback/:planid',
        builder: (context, state) => FeedbackChannelPage(
          planid: state.pathParameters['planid']!,
        ),
      ),
      GoRoute(
        // page to view a plan's exercise's details
        path: '/exercise/details/:exerciseid/:title/:typeid/:planid',
        builder: (context, state) => ExerciseDetails(
          exerciseid: state.pathParameters['exerciseid']!,
          exerciseName: state.pathParameters['title']!,
          typeid: state.pathParameters['typeid']!,
          planid: state.pathParameters['planid'],
        ),
      ),
      GoRoute(
        // page to view a saved user exercise's details
        path: '/exercise/details/:exerciseid/:title/:typeid',
        builder: (context, state) => ExerciseDetails(
          exerciseid: state.pathParameters['exerciseid']!,
          exerciseName: state.pathParameters['title']!,
          typeid: state.pathParameters['typeid']!,
        ),
      ),
      GoRoute(
        // page to view the info of an exercise
        path: '/exercise/info/:exerciseid',
        builder: (context, state) => ExerciseInfo(
          exerciseid: state.pathParameters['exerciseid']!,
        ),
      ),
      GoRoute(
        // page to view the exercises related to a machine
        path: '/machine/exercises/:machineid',
        builder: (context, state) => MachineExercisesPage(
          machineid: state.pathParameters['machineid']!,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
