import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:watchsteroids/app/app.dart';
import 'package:watchsteroids/game/game.dart';

class NoiseOverlay extends SpriteComponent with HasGameRef<WatchsteroidsGame> {
  NoiseOverlay() : super(anchor: Anchor.center, priority: 95);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(600);
    sprite = await gameRef.loadSprite('noise7.png');
  }

  @override
  late Paint paint = super.paint
    ..blendMode = BlendMode.colorDodge
    ..color = const Color(0x20000000);

  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.camera.position * -0.35;
  }
}

class NoiseAdd extends SpriteComponent with HasGameRef<WatchsteroidsGame> {
  NoiseAdd() : super(anchor: Anchor.center, priority: 95);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(600);
    sprite = await gameRef.loadSprite('noise6.png');
  }

  @override
  late Paint paint = super.paint..blendMode = BlendMode.colorDodge;

  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.camera.position * -0.15;
  }
}

class Vignette extends RectangleComponent with HasGameRef<WatchsteroidsGame> {
  @override
  Future<void> onLoad() async {
    size = Vector2(400, 400);
    priority = 100;
  }

  @override
  PositionType positionType = PositionType.viewport;

  @override
  Paint paint = BasicPalette.white.paint()
    ..shader = Gradient.radial(
      const Offset(200, 200),
      200,
      [WatchsteroidsColors.transparent, const Color(0xFF000000)],
      [0.45, 1.0],
    );
}
