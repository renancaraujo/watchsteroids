import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

class WatchsteroidsColors {
  static const Color transparent = Color(0x00000000);
  static const Color vignette = Color(0xFF000000);
  static const Color background = Color(0xFF010101);
  static const Color ringColor = Color(0xFFDB7900);
  static const Color ship = Color(0xFFFBE294);
  static const Color shipShadow1 = Color(0xFFFB3324);
  static const Color shipShadow2 = Color(0xFF0485AC);
}

class WatchsteroidsGame extends FlameGame with HasCollisionDetection {
  WatchsteroidsGame({
    required this.rotationCubit,
    required this.gameCubit,
  });

  final RotationCubit rotationCubit;
  final GameCubit gameCubit;

  late final CameraSubject cameraSubject;

  @override
  Color backgroundColor() {
    return WatchsteroidsColors.background;
  }

  late FlameMultiBlocProvider flameMultiBlocProvider;

  @override
  Future<void> onLoad() async {
    await add(Radar());

    await add(
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

    await add(NoiseAdd());
    await add(NoiseOverlay());

    await add(Vignette());
    await add(cameraSubject = CameraSubject());

    camera
      ..followComponent(cameraSubject)
      ..viewport = FixedResolutionViewport(Vector2(400, 400));
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
    10.5,
   Curves.elasticOut,
  )..setToEnd();

  late final moveEffect = MoveCameraSubject(position, effectController);

  @override
  Future<void> onLoad() async {
    await add(moveEffect);
  }

  void go({required Vector2 to, bool calm = false}) {
    (effectController as DurationEffectController)..duration = calm ? 30 : 10.5;
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
    (controller as DurationEffectController).duration = 2;
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
    duration: 1,
  );

  @override
  void onNewState(GameState state) {
    switch (state) {
      case GameState.initial:
        add(
          OpacityEffect.to(1, effectController),
        );
        break;
      case GameState.playing:
      case GameState.gameOver:
        add(
          OpacityEffect.to(0, effectController),
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
        break;
      case GameState.gameOver:
        gameRef.overlays.clear();
        gameRef.overlays.add('gameOver');
        break;
    }
  }
}
