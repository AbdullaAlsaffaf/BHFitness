import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExerciseDetails extends StatefulWidget {
  const ExerciseDetails({
    super.key,
    required this.exerciseid,
    required this.exerciseName,
    required this.typeid,
    this.planid,
  });

  final String exerciseid;
  final String typeid;
  final String exerciseName;
  final String? planid;

  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  bool _withPlan = false;
  bool _cardio = false;

  final _weightControllers = <TextEditingController>[];
  final _repsControllers = <TextEditingController>[];
  final _speedControllers = <TextEditingController>[];
  final _timeControllers = <TextEditingController>[];

  late Stream<dynamic> _setsStream;

  @override
  void dispose() {
    for (final controller in _weightControllers) {
      controller.dispose();
    }
    for (final controller in _repsControllers) {
      controller.dispose();
    }
    for (final controller in _speedControllers) {
      controller.dispose();
    }
    for (final controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.planid == null) {
      _setsStream = supabase
          .from('sets')
          .select('id, weight, speed, time, reps')
          .eq('exercise_id', widget.exerciseid)
          .filter('plan_id', 'is', 'null')
          .order('id', ascending: true)
          .asStream();
    } else {
      _withPlan = true;
      _setsStream = supabase
          .from('sets')
          .select('id, weight, speed, time, reps')
          .eq('exercise_id', widget.exerciseid)
          .eq('plan_id', widget.planid)
          .order('id', ascending: true)
          .asStream();
    }

    if (widget.typeid == '1') {
      _cardio = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.exerciseName,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<dynamic>(
        stream: _setsStream,
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
                  margin: const EdgeInsets.all(8.0),
                  child: const Text(
                    'no sets for this exercise, please add some sets to this exercise thank u',
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_withPlan) {
                      await supabase.from('sets').insert({
                        'exercise_id': int.parse(widget.exerciseid),
                        'plan_id': int.parse(widget.planid!)
                      });

                      setState(() {});
                    } else {
                      await supabase.from('sets').insert(
                          {'exercise_id': int.parse(widget.exerciseid)});

                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10.0),
                  ),
                  child: const Icon(Icons.add_circle, size: 40),
                ),
              ],
            );
          }

          final sets = snapshot.data!;

          for (final set in sets) {
            if (set['weight'] == null) {
              _weightControllers.add(TextEditingController(text: ""));
            } else {
              _weightControllers
                  .add(TextEditingController(text: set['weight'].toString()));
            }

            if (set['reps'] == null) {
              _repsControllers.add(TextEditingController(text: ""));
            } else {
              _repsControllers
                  .add(TextEditingController(text: set['reps'].toString()));
            }

            if (set['speed'] == null) {
              _speedControllers.add(TextEditingController(text: ""));
            } else {
              _speedControllers
                  .add(TextEditingController(text: set['speed'].toString()));
            }
            if (set['time'] == null) {
              _timeControllers.add(TextEditingController(text: ""));
            } else {
              _timeControllers
                  .add(TextEditingController(text: set['time'].toString()));
            }
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sets.length,
                      itemBuilder: (context, index) {
                        final setNumber = index + 1;
                        return Slidable(
                          key: ValueKey(index),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 1 / 3,
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  await supabase
                                      .from('sets')
                                      .delete()
                                      .match({'id': sets[index]['id']});
                                  setState(() {});
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
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 50.0),
                                        child: Text(
                                          _cardio
                                              ? 'interval $setNumber'
                                              : 'set $setNumber',
                                        ),
                                      ),
                                      Expanded(
                                        child: _cardio
                                            ? SizedBox(
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _speedControllers[
                                                                index],
                                                        textAlign:
                                                            TextAlign.center,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText: 'Speed',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    201,
                                                                    201,
                                                                    201),
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                        ),
                                                        onEditingComplete: () {
                                                          debugPrint(
                                                              'editing finished');
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5.0,
                                                              right: 7.0),
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: const Text(
                                                        'Km/hr',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 12.0),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _timeControllers[
                                                                index],
                                                        textAlign:
                                                            TextAlign.center,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText: 'Time',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    201,
                                                                    201,
                                                                    201),
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                        ),
                                                        onEditingComplete: () {
                                                          debugPrint(
                                                              'editing finished');
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5.0),
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: const Text(
                                                        'mins',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 12.0),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : SizedBox(
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _weightControllers[
                                                                index],
                                                        textAlign:
                                                            TextAlign.center,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText: 'Weight',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    201,
                                                                    201,
                                                                    201),
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5.0,
                                                              right: 7.0),
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: const Text(
                                                        'KG',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 12.0),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _repsControllers[
                                                                index],
                                                        textAlign:
                                                            TextAlign.center,
                                                        textAlignVertical:
                                                            TextAlignVertical
                                                                .center,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          hintText: 'Reps',
                                                          hintStyle: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    201,
                                                                    201,
                                                                    201),
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5.0),
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: const Text(
                                                        'Rps',
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 12.0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ],
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
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_withPlan) {
                          await supabase.from('sets').insert({
                            'exercise_id': int.parse(widget.exerciseid),
                            'plan_id': int.parse(widget.planid!)
                          });
                          setState(() {});
                        } else {
                          await supabase.from('sets').insert(
                              {'exercise_id': int.parse(widget.exerciseid)});

                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10.0),
                      ),
                      child: const Icon(Icons.add, size: 40),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_cardio) {
                          for (var i = 0; i < sets.length; i++) {
                            try {
                              await supabase.from('sets').update({
                                'speed': double.parse(_speedControllers[i].text)
                              }).match({'id': sets[i]['id']});
                            } on FormatException catch (error) {
                              debugPrint(error.message);
                              if (_speedControllers[i].text.isEmpty) {
                                await supabase
                                    .from('sets')
                                    .update({'speed': null}).match(
                                        {'id': sets[i]['id']});
                              }
                            }
                            try {
                              await supabase.from('sets').update({
                                'time': double.parse(_timeControllers[i].text)
                              }).match({'id': sets[i]['id']});
                            } on FormatException catch (error) {
                              debugPrint(error.message);
                              if (_timeControllers[i].text.isEmpty) {
                                await supabase
                                    .from('sets')
                                    .update({'time': null}).match(
                                        {'id': sets[i]['id']});
                              }
                            }
                          }
                        } else {
                          for (var i = 0; i < sets.length; i++) {
                            try {
                              await supabase.from('sets').update({
                                'weight':
                                    double.parse(_weightControllers[i].text)
                              }).match({'id': sets[i]['id']});
                            } on FormatException catch (error) {
                              debugPrint(error.message);
                              if (_weightControllers[i].text.isEmpty) {
                                await supabase
                                    .from('sets')
                                    .update({'weight': null}).match(
                                        {'id': sets[i]['id']});
                              }
                            }
                            try {
                              await supabase.from('sets').update({
                                'reps': int.parse(_repsControllers[i].text)
                              }).match({'id': sets[i]['id']});
                            } on FormatException catch (error) {
                              debugPrint(error.message);
                              if (_repsControllers[i].text.isEmpty) {
                                await supabase
                                    .from('sets')
                                    .update({'reps': null}).match(
                                        {'id': sets[i]['id']});
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10.0),
                      ),
                      child: const Icon(Icons.save, size: 40),
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
