import 'package:bhfit/pages/exercise_details_page.dart';
import 'package:bhfit/pages/home_page.dart';
import 'package:bhfit/pages/login_page.dart';
import 'package:bhfit/pages/news_details.dart';
import 'package:bhfit/pages/password_reset_page.dart';
import 'package:bhfit/pages/plan_exercises_page.dart';
import 'package:bhfit/pages/splash_page.dart';
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
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/passreset',
        builder: (context, state) => const PassResetPage(),
      ),
      GoRoute(
        path: '/details/:id',
        builder: (context, state) =>
            DetailsPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/plan/exercises/:id/:title',
        builder: (context, state) => PlanExercisesPage(
          planid: state.pathParameters['id']!,
          planName: state.pathParameters['title']!,
        ),
      ),
      GoRoute(
        path: '/exercise/details/:exerciseid/:title/:typeid/:planid',
        builder: (context, state) => ExerciseDetails(
          exerciseid: state.pathParameters['exerciseid']!,
          exerciseName: state.pathParameters['title']!,
          typeid: state.pathParameters['typeid']!,
          planid: state.pathParameters['planid'],
        ),
      ),
      GoRoute(
        path: '/exercise/details/:exerciseid/:title/:typeid',
        builder: (context, state) => ExerciseDetails(
          exerciseid: state.pathParameters['exerciseid']!,
          exerciseName: state.pathParameters['title']!,
          typeid: state.pathParameters['typeid']!,
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
