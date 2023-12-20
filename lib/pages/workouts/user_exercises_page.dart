import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  Stream? _exercisesStream;

  @override
  void initState() {
    _exercisesStream =
        supabase.from('user_exercises').select('id, name').asStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Exercises'),
      ),
      body: StreamBuilder<dynamic>(
        stream: _exercisesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData && snapshot.data.length == 0) {
            return const Center(
              child: Text(
                  'You don\'t have any saved exercises, please save some exercises to your list'),
            );
          }

          final exercises = snapshot.data!;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: ValueKey(index),
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          extentRatio: 1 / 3,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                await supabase
                                    .from('user_exercises')
                                    .delete()
                                    .match({'id': exercises[index]['id']});
                                setState(() {
                                  _exercisesStream = supabase
                                      .from('user_exercises')
                                      .select('id, name')
                                      .asStream();
                                });
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'delete',
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                context.pop(exercises[index]['id'].toString());
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18.0, horizontal: 8.0),
                                    child: Text(
                                      exercises[index]["name"],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1.0,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO "add" logic
                        setState(() {
                          _exercisesStream = supabase
                              .from('user_exercises')
                              .select('id, name')
                              .asStream();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10.0),
                      ),
                      child: const Icon(Icons.add, size: 40),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
