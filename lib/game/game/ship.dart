import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

class ShipContainer extends PositionComponent
    with
        FlameBlocListenable<RotationCubit, RotationState>,
        HasGameRef<WatchsteroidsGame> {
  ShipContainer()
      : super(
          anchor: Anchor.center,
          position: Vector2.zero(),
        );

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
      CameraSpot()..position = Vector2(side / 2, side / 2 - 40),
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
}

class Ship extends PositionComponent
    with HasGameRef<WatchsteroidsGame>, ParentIsA<ShipContainer> {
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
    with HasGameRef<WatchsteroidsGame>, ParentIsA<PositionComponent> {
  ShipGlow() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    size = Vector2(270, 270) * 1.5;
    position = parent.size / 2;
    position.y -= 20;
    sprite = await gameRef.loadSprite('shipglow.png');

    angle = math.pi;
  }
}

class CameraSpot extends PositionComponent with HasGameRef<WatchsteroidsGame> {
  CameraSpot()
      : super(
          anchor: Anchor.center,
        );

  final timerInitial = 0.1;

  late double timer = timerInitial;

  @override
  void update(double dt) {
    if (timer <= 0) {
      gameRef.cameraSubject.go(to: absolutePosition);
      timer = timerInitial;
    }
    timer -= dt;
    super.update(dt);
  }
}
