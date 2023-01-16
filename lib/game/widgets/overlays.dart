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
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'Tap to start',
                style: TextStyle(
                  color: Color(0xFFFBE294),
                  fontSize: 12,
                ),
              ),
              BlocBuilder<ScoreCubit, ScoreState>(
                builder: (context, state) {
                  if (state.highScore == 0) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    'High score: ${state.highScore}',
                    style: const TextStyle(
                      color: Color(0xC0FBE294),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ],
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
        context.read<ScoreCubit>().reset();
        context.read<GameCubit>().setInitial();
      },
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              const Text(
                'Game over',
                style: TextStyle(
                  color: Color(0xFFFBE294),
                  fontSize: 12,
                ),
              ),
              BlocBuilder<ScoreCubit, ScoreState>(
                builder: (context, state) {
                  if (state.currentScore == 0) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    'Score: ${state.currentScore}',
                    style: const TextStyle(
                      color: Color(0xC0FBE294),
                      fontSize: 10,
                    ),
                  );
                },
              ),
              const Spacer(),
              const Text(
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

class ScoreOverlay extends StatelessWidget {
  const ScoreOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScoreCubit, ScoreState>(
      builder: (context, state) {
        return SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  '${state.currentScore}',
                  style: const TextStyle(
                    color: Color(0xFFFBE294),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
