import 'package:flutter/material.dart';
import 'package:watchsteroids/game/game.dart';

class InitialOverlay extends StatelessWidget {
  const InitialOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final gameCubit = context.read<GameCubit>();
        if (gameCubit.isPlaying) {
          return;
        }
        context.read<GameCubit>().startGame();
      },
      child: const SizedBox.expand(
        child: Align(
          alignment: Alignment(0, 0.6),
          child: Text(
            'Tap to start',
            style: TextStyle(
              color: Color(0xFFFBE294),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        final gameCubit = context.read<GameCubit>();
        if (gameCubit.state != GameState.gameOver) {
          return;
        }
        context.read<GameCubit>().setInitial();
      },
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: const [
              Text(
                'Game over',
                style: TextStyle(
                  color: Color(0xFFFBE294),
                  fontSize: 12,
                ),
              ),
              Spacer(),
              Text(
                'Tap to continue',
                style: TextStyle(
                  color: Color(0xFFFBE294),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
