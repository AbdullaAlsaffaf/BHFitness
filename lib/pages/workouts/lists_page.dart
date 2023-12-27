import 'package:bhfit/pages/workouts/exercise_list_page.dart';
import 'package:bhfit/pages/workouts/user_exercises_page.dart';
import 'package:flutter/material.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  final _pageController = PageController();

  final pages = [
    const ExercisesPage(),
    const ExerciseListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: pages,
    );
  }
}
