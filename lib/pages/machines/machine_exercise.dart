import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MachineExercisesPage extends StatefulWidget {
  const MachineExercisesPage({super.key, required this.machineid});

  final String machineid;

  @override
  State<MachineExercisesPage> createState() => _MachineExercisesPageState();
}

class _MachineExercisesPageState extends State<MachineExercisesPage> {
  bool _machineLoaded = false;
  bool _exercisesLoaded = false;

  late final dynamic _machine;
  late final dynamic _exercises;

  @override
  void initState() {
    super.initState();
    _getMachine();
    _getExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _machineLoaded
            ? FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(_machine['name']),
              )
            : null,
      ),
      body: !_exercisesLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          final exerciseid =
                              _exercises[index]['exercise_list']['id'];
                          context.push('/exercise/info/$exerciseid');
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 8.0),
                            child: Text(
                              _exercises[index]['exercise_list']['name'],
                              textAlign: TextAlign.center,
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
  }

  Future<void> _getMachine() async {
    _machine = await supabase
        .from('machines')
        .select()
        .match({'id': widget.machineid}).single();

    setState(() {
      _machineLoaded = true;
    });
  }

  Future<void> _getExercises() async {
    _exercises = await supabase
        .from('machine_exercises')
        .select('exercise_list:exercise_id (id, name)')
        .match({'machine_id': widget.machineid});

    setState(() {
      _exercisesLoaded = true;
    });
  }
}
