import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:watchsteroids/game/game.dart';

class GameBody extends StatelessWidget {
  const GameBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return const GameWrapper();
      },
    );
  }
}

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late final rotationCubit = context.read<RotationCubit>();
  late final gameCubit = context.read<GameCubit>();
  late final scoreCubit = context.read<ScoreCubit>();

  late final game = WatchsteroidsGame(
    rotationCubit: rotationCubit,
    gameCubit: gameCubit,
    scoreCubit: scoreCubit,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
              const Size.square(400),
            ),
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFBE294),
                fontSize: 12,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Nested(
                  // Thanks Remi!
                  children: const [
                    TouchInputController(),
                    RotaryInputController(),
                  ],
                  child: GameWidget(
                    game: game,
                    initialActiveOverlays: const ['initial'],
                    overlayBuilderMap: {
                      'initial': (context, game) {
                        return const InitialOverlay();
                      },
                      'gameOver': (context, game) {
                        return const GameOverOverlay();
                      },
                      'score': (context, game) {
                        return const ScoreOverlay();
                      },
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
