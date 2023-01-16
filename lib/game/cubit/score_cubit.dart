import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ScoreCubit extends HydratedCubit<ScoreState> {
  ScoreCubit() : super(const ScoreState.initial());

  void point() {
    emit(state.point());
  }

  void reset() {
    emit(state.reset());
  }

  @override
  ScoreState? fromJson(Map<String, dynamic> json) {
    final highScore = json['highScore'] as int?;

    return ScoreState(0, highScore ?? 0);
  }

  @override
  Map<String, dynamic>? toJson(ScoreState state) {
    return {'highScore': state.highScore};
  }
}

class ScoreState extends Equatable {
  const ScoreState(this.currentScore, this.highScore);

  const ScoreState.initial() : this(0, 0);

  final int currentScore;
  final int highScore;

  ScoreState point() {
    return ScoreState(currentScore + 1, max(currentScore + 1, highScore));
  }

  ScoreState reset() {
    return ScoreState(0, highScore);
  }

  @override
  List<Object> get props => [currentScore, highScore];
}
