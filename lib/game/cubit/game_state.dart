part of 'game_cubit.dart';

class GameState extends Equatable {
  const GameState(this.shipAngle);

  final double shipAngle;

  @override
  List<Object> get props => [shipAngle];
}

class GameInitial extends GameState {
  const GameInitial() : super(0);
}
