import 'package:bhfit/pages/account/account_page.dart';
import 'package:bhfit/pages/map/map_page.dart';
import 'package:bhfit/pages/news/news_feed_page.dart';
import 'package:bhfit/pages/workouts/exercise_list_page.dart';
import 'package:bhfit/pages/workouts/plans_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 0;
  final pages = [
    const NewsFeed(),
    const PlansPage(),
    const ExerciseListPage(),
    const MapPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selected],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selected,
        onTap: (index) {
          setState(() {
            _selected = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        ],
      ),
    );
  }
}
