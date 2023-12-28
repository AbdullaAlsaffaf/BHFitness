import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key, this.toAdd = false});

  final bool toAdd;

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  Stream? _exercisesStream;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _exercisesStream =
        supabase.from('user_exercises').select('id, name, type_id').asStream();
    _searchController.addListener(() {
      setState(() {
        String? query = _searchController.text;
        _exercisesStream = supabase
            .from('user_exercises')
            .select('id, name, type_id')
            .ilike('name', '%$query%')
            .asStream();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Exercises'),
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
                                          .match(
                                              {'id': exercises[index]['id']});
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
                                      if (widget.toAdd) {
                                        context.pop(
                                            exercises[index]['id'].toString());
                                        return;
                                      }
                                      final exerciseid =
                                          exercises[index]['id'].toString();
                                      final title = exercises[index]['name'];
                                      final typeid = exercises[index]['type_id']
                                          .toString();

                                      context.push(
                                          '/exercise/details/$exerciseid/$title/$typeid');
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: widget.toAdd
                ? const Text('Select an exercise to add')
                : IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ElevatedButton(
                              onPressed: _addFromList,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10.0),
                              ),
                              child: const Text('Exercise List'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: ElevatedButton(
                              onPressed: _addNew,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10.0),
                              ),
                              child: const Text('New Exercise'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFromList() async {
    await context.push('/exercise/list');
    setState(() {
      _exercisesStream =
          supabase.from('user_exercises').select('id, name').asStream();
    });
  }

  Future<void> _addNew() async {
    await context.push('/exercises/new');
    setState(() {
      _exercisesStream =
          supabase.from('user_exercises').select('id, name').asStream();
    });
  }
}
