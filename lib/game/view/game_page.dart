import 'package:flutter/material.dart';
import 'package:watchsteroids/game/cubit/cubit.dart';
import 'package:watchsteroids/game/widgets/game_body.dart';

/// {@template game_page}
/// A description for GamePage
/// {@endtemplate}
class GamePage extends StatelessWidget {
  /// {@macro game_page}
  const GamePage({super.key});

  /// The static route for GamePage
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const GamePage());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameCubit>(create: (_) => GameCubit()),
        BlocProvider<RotationCubit>(create: (context) => RotationCubit()),
        BlocProvider<ScoreCubit>(create: (context) => ScoreCubit()),
      ],
      child: const Scaffold(
        body: GameView(),
      ),
    );
  }
}

/// {@template game_view}
/// Displays the Body of GameView
/// {@endtemplate}
class GameView extends StatelessWidget {
  /// {@macro game_view}
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return const GameBody();
  }
}
