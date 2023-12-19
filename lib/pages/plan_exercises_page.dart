import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlanExercisesPage extends StatefulWidget {
  const PlanExercisesPage(
      {super.key, required this.planid, required this.planName});

  final String planid;
  final String planName;

  @override
  State<PlanExercisesPage> createState() => _PlanExercisesPageState();
}

class _PlanExercisesPageState extends State<PlanExercisesPage> {
  late final _exercisesStream = supabase
      .from('plan_exercises')
      .select('exercise_id, user_exercises:exercise_id (name, type_id)')
      .eq('plan_id', widget.planid)
      .asStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.planName),
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
                  'no exercises for this plan, please add some exercises to this plan thank u'),
            );
          }

          final exercises = snapshot.data!;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          final String title =
                              exercises[index]["user_exercises"]["name"];
                          final String typeid = exercises[index]
                                  ["user_exercises"]["type_id"]
                              .toString();
                          final String exerciseid =
                              exercises[index]["exercise_id"].toString();
                          final String planid = widget.planid.toString();
                          context.push(
                              '/exercise/details/$exerciseid/$title/$typeid/$planid');
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
                                exercises[index]["user_exercises"]["name"],
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
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
