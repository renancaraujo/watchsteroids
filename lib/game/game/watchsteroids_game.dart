import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:watchsteroids/game/game.dart';
import 'package:watchsteroids/game/game/ship.dart';

class WatchsteroidsColors {
  static const Color background = Color(0xFF080807);
  static const Color ringColor = Color(0x05FFFFFF);
  static const Color ship = Color(0xFFFBE294);
}

class WatchsteroidsGame extends FlameGame {
  WatchsteroidsGame({
    required this.gameCubit,
  }) {
    add(Background());
  }

  final GameCubit gameCubit;

  @override
  Future<void> onLoad() async {
    await add(
      FlameBlocProvider<GameCubit, GameState>.value(
        value: gameCubit,
        children: [
          Ship(),
        ],
      ),
    );
    await add(Noise());
    camera
      ..followVector2(Vector2.zero())
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

    await add(
      CircleComponent(
        anchor: Anchor.center,
        radius: width * 0.395,
        paint: Paint()..color = WatchsteroidsColors.ringColor,
      ),
    );

    await add(
      CircleComponent(
        anchor: Anchor.center,
        radius: width * 0.295,
        paint: Paint()..color = WatchsteroidsColors.ringColor,
      ),
    );

    await add(
      CircleComponent(
        anchor: Anchor.center,
        radius: width * 0.1825,
        paint: Paint()..color = WatchsteroidsColors.ringColor,
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size.clone();
  }
}

class Noise extends SpriteComponent with HasGameRef<WatchsteroidsGame> {
  Noise() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    size = Vector2(400, 400);
    sprite = await gameRef.loadSprite('noise2.png');
  }

  @override
  late Paint paint = super.paint..blendMode = BlendMode.overlay;
}
