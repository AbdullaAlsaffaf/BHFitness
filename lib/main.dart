import 'package:bhfit/pages/account_page.dart';
import 'package:bhfit/pages/login_page.dart';
import 'package:bhfit/pages/password_reset_page.dart';
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
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/passreset',
        builder: (context, state) => const PassResetPage(),
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
