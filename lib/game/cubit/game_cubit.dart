import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial);

  void setState(GameState state) {
    emit(state);
  }

  void gameOver() {
    setState(GameState.gameOver);
  }
}

enum GameState {
  initial,
  playing,
  // paused,
  gameOver,
}
