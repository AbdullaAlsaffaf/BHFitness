import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseInfo extends StatefulWidget {
  const ExerciseInfo({super.key, required this.exerciseid});

  final String exerciseid;

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo> {
  bool _isLoaded = false;
  late final dynamic _exercise;

  @override
  void initState() {
    super.initState();
    _getExercise();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isLoaded
            ? FittedBox(fit: BoxFit.fitWidth, child: Text(_exercise['name']))
            : null,
      ),
      body: !_isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Instructions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(_exercise['instructions']
                        .replaceAll(". ", ".\n")
                        .trim()),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      width: double.infinity,
                      height: 1.0,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Muscle Group: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _exercise['muscle_groups']['group'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[850],
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Exercise Type: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _exercise['exercise_types']['type'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[850],
                            ),
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                        onPressed: _saveExercise,
                        child: const Text('Save to My Exercises'))
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _getExercise() async {
    _exercise = await supabase
        .from('exercise_list')
        .select(
            'id, name, instructions, muscle_group_id, type_id, muscle_groups:muscle_group_id (group), exercise_types:type_id (type)')
        .eq('id', widget.exerciseid)
        .single();
    setState(() {
      _isLoaded = true;
    });
  }

  Future<void> _saveExercise() async {
    setState(() {
      _isLoaded = false;
    });

    final name = _exercise['name'];
    final instructions = _exercise['instructions'];
    final typeId = _exercise['type_id'];
    final groupId = _exercise['muscle_group_id'];
    final listId = _exercise['id'];
    final userId = supabase.auth.currentSession!.user.id;

    try {
      await supabase.from('user_exercises').insert({
        'name': name,
        'instructions': instructions,
        'type_id': typeId,
        'muscle_group_id': groupId,
        'exercise_list_id': listId,
        'user_id': userId
      });
    } on PostgrestException catch (error) {
      debugPrint(error.message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(
            child: Text("Exercise is already saved to your list"),
          ),
        ));
      }
    }

    setState(() {
      _isLoaded = true;
    });
  }
}
