import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/plan_card.dart';
import 'package:bhfit/pages/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  bool _channelsLoaded = false;
  dynamic _feedbackChannels;

  Stream? _plansStream;
  final userId = supabase.auth.currentSession!.user.id;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _plansStream = supabase
        .from('plans')
        .select('id, name')
        .match({'user_id': userId}).asStream();
    _searchController.addListener(() {
      setState(() {
        String? query = _searchController.text;
        _plansStream = supabase
            .from('plans')
            .select('id, name')
            .match({'user_id': userId})
            .ilike('name', '%$query%')
            .asStream();
      });
    });
    _loadChannels();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomSearchBar(controller: _searchController),
          ),
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: _plansStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData && snapshot.data.length == 0) {
                  return ElevatedButton(
                    onPressed: () async {
                      _nameController.clear();
                      final name = await openDialog();

                      if (name == null || name.trim().isEmpty) {
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
                            .match({'user_id': userId}).asStream();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10.0),
                    ),
                    child: const Icon(Icons.add, size: 40),
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
                              extentRatio: 3 / 5,
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
                                          .match(
                                              {'user_id': userId}).asStream();
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'delete',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    context.push(
                                        '/plan/feedback/${plans[index]['id']}');
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.chat_bubble_rounded,
                                  label: 'review',
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
                                  .match({'user_id': userId}).asStream();
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
          ),
          Container(
            child: _channelsLoaded
                ? const Text(
                    'Requested feedback',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
          ),
          Container(
            child: _channelsLoaded
                ? Flexible(
                    child: ListView.builder(
                        itemCount: _feedbackChannels.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: ValueKey(index),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              extentRatio: 3 / 5,
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    await supabase
                                        .from('feedback_channels')
                                        .delete()
                                        .match({
                                      'id': _feedbackChannels[index]['id']
                                    });
                                    setState(() {
                                      _channelsLoaded = false;
                                    });
                                    _loadChannels();
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.close,
                                  label: 'close',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    context.push(
                                        '/plan/feedback/${_feedbackChannels[index]['plans']['id']}');
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  icon: Icons.chat_bubble_rounded,
                                  label: 'review',
                                ),
                              ],
                            ),
                            child: PlanCard(
                              planid: _feedbackChannels[index]['plans']['id']
                                  .toString(),
                              title: _feedbackChannels[index]['plans']['name'],
                            ),
                          );
                        }),
                  )
                : null,
          ),
        ],
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

  Future<void> _loadChannels() async {
    final roleID = await supabase
        .from('users')
        .select('role_id')
        .match({'id': userId}).single();

    if (roleID['role_id'] != 3) {
      return;
    }

    _feedbackChannels = await supabase
        .from('feedback_channels')
        .select('id, plans:plan_id (id, name)');

    if (_feedbackChannels != null) {
      setState(() {
        _channelsLoaded = true;
      });
    }
  }
}
