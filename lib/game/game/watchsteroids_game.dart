import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

class WatchsteroidsColors {
  static const Color transparent = Color(0x00000000);
  static const Color vignette = Color(0xFF000000);
  static const Color background = Color(0xFF010101);
  static const Color ringColor = Color(0x0BFF3535);
  static const Color ship = Color(0xFFFBE294);
  static const Color shipShadow1 = Color(0xFFFB3324);
  static const Color shipShadow2 = Color(0xFF0485AC);
}

class WatchsteroidsGame extends FlameGame with HasCollisionDetection {
  WatchsteroidsGame({
    required this.gameCubit,
  }) {
    add(Background());
  }

  final GameCubit gameCubit;

  late final CameraSubject cameraSubject;

  @override
  Future<void> onLoad() async {
    await add(
      FlameBlocProvider<GameCubit, GameState>.value(
        value: gameCubit,
        children: [
          ShipContainer(),
        ],
      ),
    );

    await add(AsteroidSpawner());

    await add(NoiseAdd());
    await add(NoiseOverlay());

    await add(Vignette());
    await add(cameraSubject = CameraSubject());

    camera
      ..followComponent(cameraSubject)
      ..viewport = FixedResolutionViewport(Vector2(400, 400));
  }
}

class Background extends PositionComponent with HasGameRef<WatchsteroidsGame> {
  Background()
      : super(
          children: [
            RectangleComponent(
              anchor: Anchor.center,
              position: Vector2(0, 0),
              size: Vector2(500, 500),
              paint: Paint()..color = WatchsteroidsColors.background,
            ),
          ],
        );

  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    width = size.x;
    //
    // await add(
    //   CircleComponent(
    //     anchor: Anchor.center,
    //     radius: width * 0.395,
    //     paint: Paint()..color = WatchsteroidsColors.ringColor,
    //   ),
    // );
    //
    // await add(
    //   CircleComponent(
    //     anchor: Anchor.center,
    //     radius: width * 0.295,
    //     paint: Paint()..color = WatchsteroidsColors.ringColor,
    //   ),
    // );

    // await add(
    //   CircleComponent(
    //     anchor: Anchor.center,
    //     radius: width * 0.1825,
    //     paint: Paint()..color = WatchsteroidsColors.ringColor,
    //   ),
    // );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size.clone();
  }
}

class CameraSubject extends PositionComponent
    with HasGameRef<WatchsteroidsGame> {
  CameraSubject()
      : super(
          size: Vector2.all(10),
          anchor: Anchor.center,
        );

  final effectController = CurvedEffectController(0.1, Curves.easeOutQuint)
    ..setToEnd();

  late final moveEffect = MoveCameraSubject(position, effectController);

  @override
  Future<void> onLoad() async {
    await add(moveEffect);
  }

  void go({required Vector2 to}) {
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
    final delta = _to - _from;
    (controller as DurationEffectController).duration = 2;
  }
}
