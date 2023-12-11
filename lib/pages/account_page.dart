import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';

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
                  await Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text('splashscreen')),
            ElevatedButton(
                onPressed: () async {
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    await Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Text('Sign Out'))
          ],
        ));
  }
}
