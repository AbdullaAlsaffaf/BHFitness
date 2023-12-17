import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id),
      ),
    );
  }
}
