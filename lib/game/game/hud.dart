import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:watchsteroids/app/app.dart';
import 'package:watchsteroids/game/game.dart';

class NoiseOverlay extends SpriteComponent with HasGameRef<WatchsteroidsGame> {
  NoiseOverlay() : super(anchor: Anchor.center, priority: 95);

  @override
  Future<void> onLoad() async {
    size = Vector2.all(500);
    sprite = await gameRef.loadSprite('noise7.png');
  }

  @override
  late Paint paint = super.paint
    ..blendMode = BlendMode.colorDodge
    ..color = const Color(0x20000000);

  @override
  void update(double dt) {
    super.update(dt);
    position = gameRef.cameraSubject.position * -0.5;
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
    position = gameRef.cameraSubject.position * 0.15;
  }
}

class Vignette extends RectangleComponent with HasGameRef<WatchsteroidsGame> {
  @override
  Future<void> onLoad() async {
    final parent = this.parent! as Viewport;
    size = parent.size;
    priority = 100;

    paint = BasicPalette.white.paint()
      ..shader = Gradient.radial(
        (size / 2).toOffset(),
        (size / 2).x,
        [WatchsteroidsColors.transparent, const Color(0xff000000)],
        [0.45, 1.0],
      );
  }

  @override
  PositionType positionType = PositionType.viewport;
}
