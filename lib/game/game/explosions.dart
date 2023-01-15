import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/rendering.dart';
import 'package:watchsteroids/game/game.dart';

class AsteroidHit extends PositionComponent with HasGameRef<WatchsteroidsGame> {
  @override
  Future<void> onLoad() async {}
}

class AsteroidHitCore extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('hit_core.png');
  }
}

class AsteroidHitGlare extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('hit_glare.png');
  }
}
