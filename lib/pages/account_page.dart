import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text('Account'))),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  context.go('/');
                },
                child: const Text('splashscreen')),
            ElevatedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: const Text('Sign Out'))
          ],
        ));
  }
}
