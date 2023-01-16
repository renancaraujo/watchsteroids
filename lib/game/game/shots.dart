import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/animation.dart';
import 'package:watchsteroids/game/game.dart';

final random = math.Random();

class Cannon extends Component
    with
        HasGameRef<WatchsteroidsGame>,
        ParentIsA<Ship>,
        FlameBlocListenable<GameCubit, GameState> {
  Cannon() {
    timer = initialTimer;
  }

  static const interval = 0.2;

  Timer get initialTimer => Timer(1, onTick: onTick);

  late Timer timer;

  void onTick() {
    final shotPosition = parent.absolutePositionOfAnchor(Anchor.topCenter);
    final nextPeriod = random.nextDouble() * 0.2 + interval;
    timer = Timer(
      nextPeriod,
      onTick: onTick,
    );

    // if (parent.canShoot) {}
    gameRef.flameMultiBlocProvider.add(
      Shot(
        angle: parent.angle,
        position: shotPosition,
      ),
    );
  }

  @override
  void update(double dt) {
    if (!bloc.isPlaying) {
      return;
    }
    timer.update(dt);
  }

  @override
  void onNewState(GameState state) {
    switch (state) {
      case GameState.playing:
        timer = initialTimer;
        timer.start();
        break;
      case GameState.initial:
      case GameState.gameOver:
        timer.stop();
        break;
    }
  }
}

class Shot extends PositionComponent {
  Shot({
    required super.angle,
    required super.position,
  }) : super(
          anchor: Anchor.center,
          priority: 50,
        );

  @override
  Future<void> onLoad() async {
    await add(ShotGlow());
    await add(ShotSprite());

    final angle = this.angle;

    const distance = 250;

    final destinationAngle = Vector2(
      math.sin(angle) * distance,
      -math.cos(angle) * distance,
    );

    await add(
      MoveToEffect(
        destinationAngle,
        LinearEffectController(0.35 + (random.nextDouble() * 0.2)),
        onComplete: removeFromParent,
      ),
    );
  }
}

class ShotSprite extends SpriteComponent
    with HasGameRef<WatchsteroidsGame>, CollisionCallbacks, ParentIsA<Shot> {
  ShotSprite() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final shotSprite = random.nextInt(3);
    sprite = await gameRef.loadSprite(
      'shots.png',
      srcSize: Vector2(3, 60),
      srcPosition: Vector2(shotSprite * 3, 0),
    );
    size = Vector2(3, 60);

    await add(
      RectangleHitbox(
        size: Vector2(3, 40),
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is AsteroidSprite) {
      parent.removeFromParent();
      other.parent.takeHit(
        intersectionPoints,
        parent.angle,
      );
    }
  }
}

class ShotGlow extends SpriteComponent with HasGameRef<WatchsteroidsGame> {
  ShotGlow() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'shotglow.png',
      srcSize: Vector2(117, 171),
    );
    size = Vector2(117, 171) * 0.8;

    await add(
      ScaleEffect.by(
        Vector2(10, 4),
        CurvedEffectController(1, Curves.easeInCirc),
      ),
    );
  }
}
