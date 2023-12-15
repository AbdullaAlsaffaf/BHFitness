import 'dart:async';

import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/password_reset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PassResetPage extends StatefulWidget {
  const PassResetPage({super.key});

  @override
  State<PassResetPage> createState() => _PassResetPageState();
}

class _PassResetPageState extends State<PassResetPage> {
  late final StreamSubscription<AuthState> _authSupbscription;

  @override
  void initState() {
    super.initState();
    _authSupbscription = supabase.auth.onAuthStateChange.listen((event) {
      final User? user = supabase.auth.currentUser;
      if (user == null) {
        context.go('/login');
      } else {
        debugPrint(user.toString());
      }
    });
  }

  @override
  void dispose() {
    _authSupbscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(onPressed: () => {context.go('/login')}),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(0, 0, 0, 1)
                // CustomTheme.loginGradientStart,
                // CustomTheme.loginGradientEnd
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 1.0),
              stops: <double>[0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Image(
                  image: const AssetImage(
                      'assets/images/BHFitness-transparent.png'),
                  height: MediaQuery.of(context).size.height > 800 ? 300 : 250,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: 300.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: const Color(0x552B2B2B),
                  border:
                      Border.all(color: const Color(0x552B2B2B), width: 5.0),
                  borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                ),
                child: const Expanded(
                  child: Center(
                    child: Text(
                      'New Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: PageView(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: const PasswordReset(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
