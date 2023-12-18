import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return GestureDetector(
      onTap: () {
        final id = widget.planid;
        final title = widget.title;
        context.push('/plan/exercises/$id/$title');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        elevation: 2.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.arrow_right)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
