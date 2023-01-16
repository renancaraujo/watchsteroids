import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/app/app.dart';
import 'package:watchsteroids/game/game.dart';

class ShipContainer extends PositionComponent
    with
        FlameBlocListenable<RotationCubit, RotationState>,
        HasGameRef<WatchsteroidsGame> {
  ShipContainer(this.gameCubit)
      : super(
          anchor: Anchor.center,
          position: Vector2.zero(),
          priority: 5,
        );

  final GameCubit gameCubit;

  late final side = 40.0;

  late final ship = Ship(
    Paint()
      ..style = PaintingStyle.stroke
      ..color = WatchsteroidsColors.ship
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 90
      ..shader = Gradient.radial(
        const Offset(20, 0),
        40,
        [
          WatchsteroidsColors.ship,
          const Color(0xA6FBE294),
        ],
      ),
  );

  late final shadow = Ship(
    Paint()
      ..style = PaintingStyle.stroke
      ..color = WatchsteroidsColors.shipShadow1
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 90
      ..blendMode = BlendMode.colorDodge,
  );

  late final shadow2 = Ship(
    Paint()
      ..style = PaintingStyle.stroke
      ..color = WatchsteroidsColors.shipShadow2
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 90
      ..blendMode = BlendMode.colorDodge,
  );

  late final path = Path()
    ..moveTo(side / 2, 0)
    ..lineTo(side, side)
    ..lineTo(side / 2, side * 0.7)
    ..lineTo(0, side)
    ..close();

  @override
  Future<void> onLoad() async {
    await add(shadow2);
    await add(shadow);
    await add(ship);

    await ship.add(ShipGlow());
    await ship.add(Cannon());
    await ship.add(
      PolygonHitbox(
        isSolid: true,
        [
          Vector2(side / 2, 0),
          Vector2(side, side),
          Vector2(side / 2, side * 0.7),
          Vector2(0, side),
        ],
      ),
    );

    await ship.add(
      CameraSpot(gameCubit)..position = Vector2(side / 2, side / 2 - 50),
    );
  }

  @override
  void onNewState(RotationState state) {
    final from = ship.angle;
    final to = state.shipAngle;

    final delta = (to - from).abs();

    ship.effectController.duration = ((delta / math.pi) / 1.1) + 0.1;
    ship.go(to: state.shipAngle);

    shadow.effectController.duration = ship.effectController.duration * 1.5;
    shadow.go(to: state.shipAngle);

    shadow2.effectController.duration = ship.effectController.duration * 2;
    shadow2.go(to: state.shipAngle);
  }

  void hitAsteroid(Set<Vector2> intersectionPoints) {
    gameCubit.gameOver();
    gameRef.flameMultiBlocProvider.add(
      AsteroidExplosion(position: absolutePositionOfAnchor(Anchor.center)),
    );
    gameRef.cameraSubject.go(to: intersectionPoints.first, calm: true);
  }
}

class Ship extends PositionComponent
    with
        HasGameRef<WatchsteroidsGame>,
        ParentIsA<ShipContainer>,
        CollisionCallbacks {
  Ship(this.paint) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await add(rotateShipEffect);
    size = Vector2(parent.side, parent.side);
  }

  final effectController = CurvedEffectController(0.1, Curves.easeOutQuint)
    ..setToEnd();

  late final rotateShipEffect = RotateShipEffect(0, effectController);

  final Paint paint;

  bool canShoot = true;

  void go({required double to}) {
    canShoot = false;
    rotateShipEffect
      ..go(to: to)
      ..onComplete = () {
        canShoot = true;
      };
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawPath(parent.path, paint);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is AsteroidSprite) {
      parent.hitAsteroid(intersectionPoints);
    }
  }
}

class RotateShipEffect extends Effect with EffectTarget<PositionComponent> {
  RotateShipEffect(this._to, super.controller);

  @override
  void onMount() {
    super.onMount();
    _from = target.angle;
  }

  double _to;
  late double _from;

  void go({required double to}) {
    reset();
    _to = to;
    _from = target.angle;
  }

  @override
  void apply(double progress) {
    final delta = _to - _from;
    final angle = _from + delta * progress;
    target.angle = angle;
  }

  @override
  bool get removeOnFinish => false;
}

class ShipGlow extends SpriteComponent
    with
        HasGameRef<WatchsteroidsGame>,
        ParentIsA<Ship>,
        FlameBlocListenable<GameCubit, GameState> {
  ShipGlow() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    size = Vector2(270, 270) * 1.5;
    position = parent.size / 2;
    opacity = 0.0;

    sprite = await gameRef.loadSprite('shipglow.png');

    angle = math.pi;
  }

  @override
  void onNewState(GameState state) {
    switch (state) {
      case GameState.playing:
        position.y = (parent.y / 2) - 20;
        opacity = 1.0;
        break;
      case GameState.initial:
        parent.parent.ship.angle = 0;
        parent.parent.shadow.angle = 0;
        parent.parent.shadow2.angle = 0;
        opacity = 0.0;
        break;
      case GameState.gameOver:
        position.y = parent.y / 2;

        break;
    }
  }
}

class CameraSpot extends PositionComponent with HasGameRef<WatchsteroidsGame> {
  CameraSpot(this.gameCubit)
      : super(
          anchor: Anchor.center,
        );

  final timerInitial = 0.1;
  final GameCubit gameCubit;

  late double timer = timerInitial;

  @override
  void update(double dt) {
    if (!gameCubit.isPlaying) {
      return;
    }

    if (timer <= 0) {
      gameRef.cameraSubject.go(to: absolutePosition);
      timer = timerInitial;
    }
    timer -= dt;
  }
}
