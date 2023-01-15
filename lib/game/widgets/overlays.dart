import 'package:flutter/material.dart';
import 'package:watchsteroids/game/game.dart';

class InitialOverlay extends StatelessWidget {
  const InitialOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final gameCubit = context.read<GameCubit>();
        if (gameCubit.isPlaying) {
          return;
        }
        context.read<GameCubit>().startGame();
      },
      child: const Align(
        alignment: Alignment(0.0, 0.6),
        child: Text(
          'Tap to start',
          style: TextStyle(
            color: Color(0xFFFBE294),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final gameCubit = context.read<GameCubit>();
        if (gameCubit.state != GameState.gameOver) {
          return;
        }
        context.read<GameCubit>().setInitial();
      },
      child: const Align(
        alignment: Alignment(0.0, 0.6),
        child: Text(
          'Tap to continue',
          style: TextStyle(
            color: Color(0xFFFBE294),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

