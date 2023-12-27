import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Stream? _machinesStream;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _machinesStream =
        supabase.from('machines').select('id, name, label').asStream();
    _searchController.addListener(() {
      setState(() {
        String? query = _searchController.text;
        _machinesStream = supabase
            .from('machines')
            .select('id, name, label')
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
        title: const Text('Gym Map'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(20, 43, 43, 43),
                        border: Border.all(width: 3.0),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(3.0),
                        ),
                      ),
                      child: InteractiveViewer(
                        child: const Image(
                          image: AssetImage(
                            'assets/images/GymMap.png',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    CustomSearchBar(
                      controller: _searchController,
                    ),
                    Expanded(
                      child: StreamBuilder<dynamic>(
                        stream: _machinesStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final machines = snapshot.data;

                          return ListView.builder(
                            itemCount: machines.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      context.push(
                                          '/machine/exercises/${machines[index]['id']}');
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18.0, horizontal: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                machines[index]['name'],
                                              ),
                                            ),
                                            Text(
                                              machines[index]['label'],
                                              style: const TextStyle(
                                                  fontSize: 10.0),
                                            ),
                                          ],
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
