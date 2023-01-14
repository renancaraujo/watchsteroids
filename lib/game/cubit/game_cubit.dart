import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameInitial());

  void rotateBy(double delta) {
    emit(GameState(state.shipAngle + delta));
  }

  void rotateTo(double rotation) {
    emit(GameState(rotation));
  }
}
