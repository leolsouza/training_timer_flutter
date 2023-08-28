import 'package:flutter/material.dart';
import 'package:training_app/constants/ui_helpers.dart';
import 'package:training_app/controllers/stream_training_controller.dart';
import 'package:training_app/events/end_event.dart';
import 'package:training_app/events/exercise_event.dart';
import 'package:training_app/events/start_event.dart';
import 'package:training_app/events/training_event.dart';
import 'package:training_app/models/training.dart';
import 'package:training_app/widgets/button_widget.dart';
import 'package:training_app/widgets/count_down.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  bool showStartButton = true;

  final StreamTrainingController streamController =
      StreamTrainingController(trainingList: [
    Training(seconds: 10, name: 'Abdominal'),
    Training(seconds: 12, name: 'Rest'),
    Training(seconds: 8, name: 'Jumping jacks'),
  ]);

  start() {
    streamController.startTraining();
    setState(() {
      showStartButton = false;
    });
  }

  cancel() {
    streamController.cancelTraining();
    setState(() {
      showStartButton = true;
    });
  }

  pause() {
    streamController.pauseTraining();
  }

  resume() {
    streamController.resumeTraining();
  }

  @override
  void dispose() {
    streamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: showStartButton
            ? ButtonWidget(text: 'Start training', onClicked: start)
            : StreamBuilder(
                stream: streamController.eventStream,
                builder: (context, snapshot) {
                  TrainingEvent? event = snapshot.data;

                  if (snapshot.hasError) {
                    return const Text('Error loading data');
                  } else if (event is StartEvent) {
                    return buildTextEvent('Starting training...');
                  } else if (event is EndEvent) {
                    return buildFinishedExercise();
                  } else if (event is ExerciseEvent) {
                    return buildTimer();
                  }
                  return Container();
                },
              ),
      ),
    );
  }

  Widget buildTimer() {
    return StreamBuilder(
      stream: streamController.exerciseStream,
      builder: (context, snapshot) {
        Training? training = snapshot.data;

        if (snapshot.hasData) {
          return buildExercise(training!);
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget buildFinishedExercise() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTextEvent('Finishing Training'),
        verticalSpaceSmall,
        ButtonWidget(text: 'Restart training', onClicked: start)
      ],
    );
  }

  Widget buildExercise(Training training) {
    return StreamBuilder(
      stream: streamController.timerStream,
      builder: (context, snapshot) {
        int? seconds = snapshot.data;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CountDown(
              training: training,
              now: seconds ?? training.seconds,
            ),
            verticalSpaceSmall,
            buildActionButtons()
          ],
        );
      },
    );
  }

  Widget buildActionButtons() {
    return StreamBuilder<bool>(
        stream: streamController.paused,
        builder: (context, snapshot) {
          final paused = snapshot.data ?? false;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(
                text: !paused ? 'Pause' : 'Resume',
                onClicked: !paused ? pause : resume,
              ),
              horizontalSpaceSmall,
              ButtonWidget(text: 'Cancel', onClicked: cancel)
            ],
          );
        });
  }

  Widget buildTextEvent(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
