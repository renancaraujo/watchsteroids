import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial);

  bool get isPlaying => state == GameState.playing;

  void setState(GameState state) {
    emit(state);
  }

  void gameOver() {
    setState(GameState.gameOver);
  }

  void startGame() {
    setState(GameState.playing);
  }

  void setInitial() {
    setState(GameState.initial);
  }
}

enum GameState {
  initial,
  playing,
  // paused,
  gameOver,
}
