import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:watchsteroids/game/game.dart';

class GameBody extends StatelessWidget {
  const GameBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return const RotaryInputController(
          child: GameWrapper(),
        );
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
  late final gameCubit = context.read<GameCubit>();

  late final game = WatchsteroidsGame(gameCubit: gameCubit);

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
            child: AspectRatio(
              aspectRatio: 1,
              child: TouchInputController(
                child: GameWidget(game: game),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
