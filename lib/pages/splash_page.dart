import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = supabase.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/account');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image(
                    height:
                        MediaQuery.of(context).size.height > 800 ? 300 : 250,
                    image: const AssetImage(
                        'assets/images/BHFitness-transparent.png'),
                  ),
                ),
                Center(
                  child: Text('BHFitness',
                      style: Theme.of(context).textTheme.displayLarge),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
