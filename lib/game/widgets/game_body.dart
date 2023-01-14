import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:watchsteroids/game/cubit/cubit.dart';
import 'package:watchsteroids/game/game/weatchsteroids_game.dart';

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
  late final game = WatchsteroidsGame();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:  BoxConstraints.loose(
        const Size.square(400),
      ),
      child: GameWidget(game: game),
    );
  }
}
