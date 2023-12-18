import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';

class PlanCard extends StatefulWidget {
  const PlanCard({super.key, required this.planid, required this.title});

  final String planid;
  final String title;

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  @override
  Widget build(BuildContext context) {
    final exercisesStream = supabase
        .from('plan_exercises')
        .select('exercise_id, user_exercises:exercise_id ( name )')
        .eq('plan_id', widget.planid)
        .asStream();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(widget.title),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1.0,
            color: Colors.grey[400],
          ),
          StreamBuilder<dynamic>(
            stream: exercisesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final exercises = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exercises[index]["user_exercises"]["name"],
                        ),
                        Icon(Icons.arrow_right_outlined),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
        onExpansionChanged: (bool expanded) {
          setState(() {});
        },
      ),
    );
    // return Container(
    //   child: Column(
    //     children: [
    //       Container(
    //         margin: EdgeInsets.symmetric(horizontal: 20.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(widget.title),
    //             IconButton(
    //               onPressed: () {
    //                 setState(() {
    //                   _expanded = !_expanded;
    //                 });
    //               },
    //               icon: _expanded
    //                   ? Icon(Icons.arrow_downward)
    //                   : Icon(Icons.arrow_right),
    //               iconSize: 30.0,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
