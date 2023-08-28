import 'package:flutter/material.dart';

import 'package:training_app/models/training.dart';

class CountDown extends StatelessWidget {
  final Training training;
  final int now;

  const CountDown({
    Key? key,
    required this.training,
    required this.now,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getColor(int now, int limit) {
      double factor = now / limit;

      if (factor > 0.6) {
        return Colors.green;
      } else if (factor > 0.2 && factor <= 0.6) {
        return Colors.blue[400];
      } else if (factor > 0.1 && factor <= 0.2) {
        return Colors.yellow[400];
      } else {
        return Colors.red[400];
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            backgroundColor: Colors.grey.shade300,
            value: 1 - (now / training.seconds),
            strokeWidth: 15,
            color: getColor(now, training.seconds),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              now.toString(),
              style: const TextStyle(fontSize: 70),
            ),
            Text(
              training.name,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        )
      ],
    );
  }
}
