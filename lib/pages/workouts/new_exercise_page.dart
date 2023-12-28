import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  bool _adding = false;
  bool _typesLoaded = false;
  bool _groupsLoaded = false;

  dynamic _typeDropdownValue;
  dynamic _groupDropdownValue;

  late final dynamic _types;
  late final dynamic _groups;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    _getTypes();
    _getGroups();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Exercise'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _nameController,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      hintText: 'Exercise name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      hintText: 'Exercise Instructions (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15.0),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Exercise Type:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          child: _typesLoaded
                              ? DropdownButton(
                                  alignment: AlignmentDirectional.topStart,
                                  hint: const Text('Exercise Type'),
                                  value: _typeDropdownValue,
                                  isExpanded: true,
                                  items: List.generate(
                                      _types.length,
                                      (index) => DropdownMenuItem(
                                            value: _types[index]['id'],
                                            child: Text(_types[index]['type']),
                                          )),
                                  onChanged: (value) {
                                    setState(() {
                                      _typeDropdownValue = value;
                                    });
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Muscle Group:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8.0),
                          child: _groupsLoaded
                              ? DropdownButton(
                                  alignment: AlignmentDirectional.topStart,
                                  hint: const Text('Muscle Group (optional)'),
                                  value: _groupDropdownValue,
                                  isExpanded: true,
                                  items: List.generate(
                                      _groups.length,
                                      (index) => DropdownMenuItem(
                                            value: _groups[index]['id'],
                                            child:
                                                Text(_groups[index]['group']),
                                          )),
                                  onChanged: (value) {
                                    setState(() {
                                      _groupDropdownValue = value;
                                    });
                                  },
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: !_adding ? _addExercise : null,
                    child: const Text('Add'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getTypes() async {
    _types = await supabase.from('exercise_types').select();

    setState(() {
      _typesLoaded = true;
    });
  }

  Future<void> _getGroups() async {
    _groups = await supabase.from('muscle_groups').select();

    setState(() {
      _groupsLoaded = true;
    });
  }

  Future<void> _addExercise() async {
    setState(() {
      _adding = true;
    });
    if (_nameController.text.trim() == '') {
      _showError("Enter a name for your exercise");
      setState(() {
        _adding = false;
      });
      return;
    }

    if (_typeDropdownValue == null) {
      setState(() {
        _adding = false;
      });
      _showError("Please select an exercise type");
      return;
    }

    final name = _nameController.text;
    final typeid = _typeDropdownValue;
    final userid = supabase.auth.currentSession!.user.id;
    final instructions = _instructionsController.text.trim();
    final groupid = _groupDropdownValue;

    await supabase.from('user_exercises').insert({
      'name': name,
      'type_id': typeid,
      'instructions': instructions,
      'user_id': userid,
      'muscle_group_id': groupid
    });

    if (mounted) {
      context.pop();
    }
  }

  void _showError(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(
          child: Text(text),
        ),
      ));
    }
  }
}
