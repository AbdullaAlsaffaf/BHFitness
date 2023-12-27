import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  Stream? _exercisesStream;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _exercisesStream = supabase
        .from('plan_exercises')
        .select('id, exercise_id, user_exercises!inner (name, type_id)')
        .eq('plan_id', widget.planid)
        .asStream();
    _searchController.addListener(() {
      setState(() {
        String? query = _searchController.text;
        _exercisesStream = supabase
            .from('plan_exercises')
            .select('id, exercise_id, user_exercises!inner (name, type_id)')
            .eq('plan_id', widget.planid)
            .ilike('user_exercises.name', '%$query%')
            .asStream();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.planName),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomSearchBar(controller: _searchController),
          ),
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: _exercisesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData && snapshot.data.length == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        child: const Text(
                          'no exercises for this plan, please add some exercises to this plan thank u',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String? exerciseid = await context
                              .push('/exercises', extra: {'toAdd': true});
                          if (exerciseid != null) {
                            await supabase.from('plan_exercises').insert({
                              'plan_id': int.parse(widget.planid),
                              'exercise_id': int.parse(exerciseid)
                            });
                            setState(() {
                              _exercisesStream = supabase
                                  .from('plan_exercises')
                                  .select(
                                      'exercise_id, user_exercises:exercise_id (name, type_id)')
                                  .eq('plan_id', widget.planid)
                                  .asStream();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10.0),
                        ),
                        child: const Icon(Icons.add, size: 40),
                      ),
                    ],
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
                                          .from('plan_exercises')
                                          .delete()
                                          .match(
                                              {'id': exercises[index]['id']});
                                      setState(() {
                                        _exercisesStream = supabase
                                            .from('plan_exercises')
                                            .select(
                                                'exercise_id, user_exercises:exercise_id (name, type_id)')
                                            .eq('plan_id', widget.planid)
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
                                      final String title = exercises[index]
                                          ["user_exercises"]["name"];
                                      final String typeid = exercises[index]
                                              ["user_exercises"]["type_id"]
                                          .toString();
                                      final String exerciseid = exercises[index]
                                              ["exercise_id"]
                                          .toString();
                                      final String planid =
                                          widget.planid.toString();
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
                                            exercises[index]["user_exercises"]
                                                ["name"],
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
                            onPressed: () async {
                              String? exerciseid =
                                  await context.push('/exercises');
                              if (exerciseid != null) {
                                await supabase.from('plan_exercises').insert({
                                  'plan_id': int.parse(widget.planid),
                                  'exercise_id': int.parse(exerciseid)
                                });
                                setState(() {
                                  _exercisesStream = supabase
                                      .from('plan_exercises')
                                      .select(
                                          'exercise_id, user_exercises:exercise_id (name, type_id)')
                                      .eq('plan_id', widget.planid)
                                      .asStream();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(10.0),
                            ),
                            child: const Icon(Icons.add, size: 40),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
