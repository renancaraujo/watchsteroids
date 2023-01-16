import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

class AsteroidHit extends PositionComponent with HasGameRef<WatchsteroidsGame> {
  AsteroidHit({super.position}) : super(anchor: Anchor.center, priority: 70);

  @override
  Future<void> onLoad() async {
    final out = AsteroidHitOut();
    await add(out);
    final core = AsteroidHitCore();
    await add(core);

    const duration = 0.5;

    final controller = EffectController(
      duration: duration / 2,
      reverseDuration: duration / 2,
      curve: Curves.easeOutCirc,
      alternate: true,
    );

    await out.add(OpacityEffect.fadeIn(controller));
    await core.add(
      OpacityEffect.to(
        0.5,
        controller,
        onComplete: removeFromParent,
      ),
    );
  }
}

class AsteroidHitCore extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidHitCore() : super(anchor: Anchor.center);

  static Paint staticPaint = Paint()..blendMode = BlendMode.hardLight;

  @override
  final paint = staticPaint;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'hit_core2.png',
      srcSize: Vector2(39, 39),
    );
    size = Vector2.all(25);
    opacity = 0.0;
  }
}

class AsteroidHitOut extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidHitOut() : super(anchor: Anchor.center);

  static Paint staticPaint = Paint()..blendMode = BlendMode.lighten;

  @override
  final paint = staticPaint;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'hit_out2.png',
      srcSize: Vector2(47, 46),
    );
    size = Vector2.all(40);
    opacity = 0.0;
  }
}

class AsteroidExplosion extends PositionComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidExplosion({super.position})
      : super(anchor: Anchor.center, priority: 10);

  @override
  Future<void> onLoad() async {
    final backdrop = AsteroidExplosionBackdrop();
    await add(backdrop);

    final glare = AsteroidExplosionGlare();
    await add(glare);

    final outerCore = AsteroidExplosionOuterCore();
    await add(outerCore);

    final core = AsteroidExplosionCore();
    await add(core);

    const duration = 2.5;

    final controller = EffectController(
      duration: duration / 2,
      reverseDuration: duration / 2,
      curve: Curves.easeOut,
      alternate: true,
    );

    await backdrop.add(OpacityEffect.to(1, controller));

    await glare.add(OpacityEffect.to(0.6, controller));
    await glare.add(ScaleEffect.to(Vector2.all(1.5), controller));

    await outerCore.add(OpacityEffect.to(0.5, controller));

    await core.add(
      OpacityEffect.to(
        1,
        controller,
        onComplete: removeFromParent,
      ),
    );
  }
}

class AsteroidExplosionCore extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidExplosionCore() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'explosion_core.png',
      srcSize: Vector2(76, 78),
    );
    size = Vector2(76, 78);
    opacity = 0.0;
  }
}

class AsteroidExplosionOuterCore extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidExplosionOuterCore() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'explosion_outer_core.png',
      srcSize: Vector2(108, 108),
    );
    size = Vector2(108, 108);
    opacity = 0.0;
  }

  @override
  Paint paint = Paint()..blendMode = BlendMode.hardLight;
}

class AsteroidExplosionGlare extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidExplosionGlare() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'explosion_glare.png',
      srcSize: Vector2(402, 408),
    );
    size = Vector2(402, 408);
    opacity = 0.0;
    scale = Vector2.all(0.1);
  }

  @override
  Paint paint = Paint()..blendMode = BlendMode.hardLight;
}

class AsteroidExplosionBackdrop extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidExplosionBackdrop() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'explosion_backdop.png',
      srcSize: Vector2(175, 180),
    );
    size = Vector2(175, 180);
    opacity = 0.0;
  }
}
