import 'package:rxdart/rxdart.dart';
import 'package:training_app/events/end_event.dart';
import 'package:training_app/events/exercise_event.dart';
import 'package:training_app/events/start_event.dart';
import 'package:training_app/events/training_event.dart';
import 'package:training_app/models/training.dart';

class StreamTrainingController {
  List<Training> trainingList;

  StreamTrainingController({
    required this.trainingList,
  });

  final _exerciseSubject = BehaviorSubject<Training>();
  final _timerSubject = BehaviorSubject<int>();
  final _eventSubject = BehaviorSubject<TrainingEvent>();
  final _pausedSubject = BehaviorSubject<bool>.seeded(false);
  bool cancel = false;

  Stream<Training> get exerciseStream => _exerciseSubject.stream;
  Stream<int> get timerStream => _timerSubject.stream;
  Stream<bool> get paused => _pausedSubject.stream;
  Stream<TrainingEvent> get eventStream => _eventSubject.stream;

  Future<void> _startTrainingExercise([
    int? startTrainingFrom,
    int? startTimerFrom,
  ]) async {
    if (startTrainingFrom == null && startTimerFrom == null) {
      _eventSubject.add(ExerciseEvent());
    }

    for (int index = startTrainingFrom ?? 0;
        index < trainingList.length;
        index++) {
      final training = trainingList[index];
      int time =
          startTrainingFrom == index ? startTimerFrom! : training.seconds;

      if (_pausedSubject.value || cancel) break;
      _exerciseSubject.add(training);

      await _startTrainingTimer(time);
    }

    if (!_pausedSubject.value) _eventSubject.add(EndEvent());
  }

  Future<void> _startTrainingTimer([int? startFrom]) async {
    final training = _exerciseSubject.value;

    for (int seconds = startFrom ?? training.seconds; seconds >= 0; seconds--) {
      if (_pausedSubject.value || cancel) break;
      _timerSubject.add(seconds);
      print(seconds);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void pauseTraining() {
    _pausedSubject.add(true);
  }

  void resumeTraining() async {
    _pausedSubject.add(false);
    final startFrom = trainingList.indexOf(_exerciseSubject.value);
    await _startTrainingExercise(startFrom, _timerSubject.value);
  }

  void startTraining() async {
    cancel = false;
    _eventSubject.add(StartEvent());
    await Future.delayed(const Duration(seconds: 1));
    _startTrainingExercise();
  }

  void cancelTraining() {
    cancel = true;
    _timerSubject.add(trainingList.first.seconds);
    _exerciseSubject.add(trainingList.first);
    _eventSubject.add(EndEvent());
  }

  void dispose() {
    _exerciseSubject.close();
    _eventSubject.close();
    _pausedSubject.close();
    _timerSubject.close();
  }
}
