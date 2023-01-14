import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

class Ship extends PositionComponent
    with
        HasGameRef<WatchsteroidsGame>,
        FlameBlocListenable<GameCubit, GameState> {
  Ship() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await add(rotateShipEffect);
    size = Vector2(width, width);
  }

  @override
  void onNewState(GameState state) {
    rotateShipEffect.go(to: state.shipAngle);
  }

  final effectController = CurvedEffectController(0.3, Curves.linear)
    ..setToEnd();

  late final rotateShipEffect = RotateShipEffect(0.1, effectController);

  @override
  late final width = 40;

  late final path = Path()
    ..moveTo(width / 2, 0)
    ..lineTo(width, width)
    ..lineTo(width / 2, width * 0.7)
    ..lineTo(0, width)
    ..close();

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = WatchsteroidsColors.ship
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter
        ..strokeMiterLimit = 90,
    );
  }
}

class RotateShipEffect extends Effect with EffectTarget<Ship> {
  RotateShipEffect(this._to, super.controller);

  @override
  void onMount() {
    super.onMount();
    _from = target.angle;
  }

  double _to;
  late double _from;

  void go({required double to}) {
    _to = to;
    _from = target.angle;

    reset();
    final delta = (_to - _from).abs();
    (controller as DurationEffectController).duration = (delta / math.pi) / 2;
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
