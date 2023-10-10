import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/app/app.dart';
import 'package:watchsteroids/game/game.dart';

class WatchsteroidsGame extends FlameGame with HasCollisionDetection {
  WatchsteroidsGame({
    required this.rotationCubit,
    required this.gameCubit,
    required this.scoreCubit,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: 400,
            height: 400,
            hudComponents: [Vignette()],
          ),
        );

  final RotationCubit rotationCubit;
  final GameCubit gameCubit;
  final ScoreCubit scoreCubit;

  late final CameraSubject cameraSubject;

  @override
  Color backgroundColor() {
    return WatchsteroidsColors.background;
  }

  late FlameMultiBlocProvider flameMultiBlocProvider;

  @override
  Future<void> onLoad() async {
    await world.add(
      flameMultiBlocProvider = FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<RotationCubit, RotationState>.value(
            value: rotationCubit,
          ),
          FlameBlocProvider<GameCubit, GameState>.value(
            value: gameCubit,
          ),
        ],
        children: [
          GameStateSyncController(),
          LogoInitial(),
          ShipContainer(
            gameCubit,
          ),
          AsteroidSpawner(),
        ],
      ),
    );

    await world.add(NoiseAdd());
    await world.add(Radar());
    await world.add(NoiseOverlay());
    await world.add(cameraSubject = CameraSubject());
    camera.follow(cameraSubject);
  }
}

class CameraSubject extends PositionComponent
    with HasGameRef<WatchsteroidsGame> {
  CameraSubject()
      : super(
          size: Vector2.all(10),
          anchor: Anchor.center,
        );

  final effectController = CurvedEffectController(
    0.1,
    Curves.easeInOut,
  )..setToEnd();

  late final moveEffect = MoveCameraSubject(position, effectController);

  @override
  Future<void> onLoad() async {
    await add(moveEffect);
  }

  void go({required Vector2 to, bool calm = false}) {
    effectController.duration = calm ? 10 : 0.5;

    moveEffect.go(to: to);
  }
}

class MoveCameraSubject extends Effect with EffectTarget<CameraSubject> {
  MoveCameraSubject(this._to, super.controller);

  @override
  void onMount() {
    super.onMount();
    _from = target.position;
  }

  Vector2 _to;
  late Vector2 _from;

  @override
  bool get removeOnFinish => false;

  @override
  void apply(double progress) {
    final delta = _to - _from;
    final position = _from + delta * progress;
    target.position = position;
  }

  void go({required Vector2 to}) {
    reset();
    _to = to;
    _from = target.position;
  }
}

class LogoInitial extends SpriteComponent
    with
        HasGameRef<WatchsteroidsGame>,
        FlameBlocListenable<GameCubit, GameState> {
  LogoInitial()
      : super(
          anchor: Anchor.center,
          priority: 4,
        );

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'logoinitial.png',
      srcSize: Vector2(298, 319),
    );

    size = Vector2(298, 319);
  }

  late final effectController = EffectController(
    duration: 2,
  );

  OpacityEffect? opacityEffect;

  @override
  void onNewState(GameState state) {
    if (!effectController.completed) {
      effectController.setToEnd();
      opacityEffect?.removeFromParent();
    }

    switch (state) {
      case GameState.initial:
        effectController.setToStart();
        add(
          opacityEffect = OpacityEffect.to(1, effectController),
        );
        break;
      case GameState.playing:
      case GameState.gameOver:
        effectController.setToStart();
        add(
          opacityEffect = OpacityEffect.to(0, effectController),
        );
        break;
    }
  }
}

class GameStateSyncController extends Component
    with
        HasGameRef<WatchsteroidsGame>,
        FlameBlocListenable<GameCubit, GameState> {
  GameStateSyncController();

  @override
  void onNewState(GameState state) {
    switch (state) {
      case GameState.initial:
        gameRef.overlays.clear();
        gameRef.overlays.add('initial');
        gameRef.cameraSubject.go(
          to: Vector2(0, 0),
          calm: true,
        );
        gameRef.rotationCubit.rotateTo(0);
        break;
      case GameState.playing:
        gameRef.overlays.clear();
        gameRef.overlays.add('score');
        break;
      case GameState.gameOver:
        gameRef.overlays.clear();
        gameRef.overlays.add('gameOver');
        break;
    }
  }
}
