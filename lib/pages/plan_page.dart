import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/plan_card.dart';
import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final _plansStream = supabase.from('plans').select('id, name').asStream();

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

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              return PlanCard(
                planid: plans[index]['id'].toString(),
                title: plans[index]['name'],
              );
            },
          );
        },
      ),
    );
  }
}
