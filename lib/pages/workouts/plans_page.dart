import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  Stream? _plansStream;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _plansStream = supabase.from('plans').select('id, name').asStream();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Workout Plans'),
        ),
      ),
      body: StreamBuilder<dynamic>(
        stream: _plansStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final plans = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: plans.length,
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
                                  .from('plans')
                                  .delete()
                                  .match({'id': plans[index]['id']});
                              setState(() {
                                _plansStream = supabase
                                    .from('plans')
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
                      child: PlanCard(
                        planid: plans[index]['id'].toString(),
                        title: plans[index]['name'],
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      _nameController.clear();
                      final name = await openDialog();

                      if (name == null || name.trim().isEmpty) {
                        debugPrint('it null');
                        debugPrint(name);
                        return;
                      }

                      await supabase.from('plans').insert({
                        'name': name,
                        'user_id': supabase.auth.currentUser!.id
                      });
                      setState(() {
                        _plansStream = supabase
                            .from('plans')
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
          );
        },
      ),
    );
  }

  Future<String?> openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(
            child: Text('New Workout Plan'),
          ),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop(_nameController.text);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
}
