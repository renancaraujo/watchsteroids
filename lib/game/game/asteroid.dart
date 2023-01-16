import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:watchsteroids/game/game.dart';

enum AsteroidSpawnArea {
  northWest(-470, -470),
  north(-100, -470),
  northEast(270, -470),
  west(-470, -100),
  southEast(270, 270),
  south(-100, 270),
  southWest(-470, 270),
  east(270, -100);

  const AsteroidSpawnArea(this.originX, this.originY);

  final double originX;
  final double originY;

  AsteroidSpawnArea get opposite {
    switch (this) {
      case AsteroidSpawnArea.northWest:
        return AsteroidSpawnArea.southEast;
      case AsteroidSpawnArea.north:
        return AsteroidSpawnArea.south;
      case AsteroidSpawnArea.northEast:
        return AsteroidSpawnArea.southWest;
      case AsteroidSpawnArea.west:
        return AsteroidSpawnArea.east;
      case AsteroidSpawnArea.southEast:
        return AsteroidSpawnArea.northWest;
      case AsteroidSpawnArea.south:
        return AsteroidSpawnArea.north;
      case AsteroidSpawnArea.southWest:
        return AsteroidSpawnArea.northEast;
      case AsteroidSpawnArea.east:
        return AsteroidSpawnArea.west;
    }
  }

  AsteroidSpawnArea get curvedOpposite {
    switch (this) {
      case AsteroidSpawnArea.northWest:
        return random.nextBool()
            ? AsteroidSpawnArea.southWest
            : AsteroidSpawnArea.east;
      case AsteroidSpawnArea.north:
        return random.nextBool()
            ? AsteroidSpawnArea.southWest
            : AsteroidSpawnArea.southEast;

      case AsteroidSpawnArea.northEast:
        return random.nextBool()
            ? AsteroidSpawnArea.northWest
            : AsteroidSpawnArea.south;

      case AsteroidSpawnArea.west:
        return random.nextBool()
            ? AsteroidSpawnArea.northEast
            : AsteroidSpawnArea.north;

      case AsteroidSpawnArea.southEast:
        return random.nextBool()
            ? AsteroidSpawnArea.west
            : AsteroidSpawnArea.north;
      case AsteroidSpawnArea.south:
        return random.nextBool()
            ? AsteroidSpawnArea.northWest
            : AsteroidSpawnArea.northEast;
      case AsteroidSpawnArea.southWest:
        return random.nextBool()
            ? AsteroidSpawnArea.north
            : AsteroidSpawnArea.east;
      case AsteroidSpawnArea.east:
        return random.nextBool()
            ? AsteroidSpawnArea.northWest
            : AsteroidSpawnArea.southWest;
    }
  }

  Vector2 get origin => Vector2(originX, originY);
}

class AsteroidSpawner extends Component
    with
        HasGameRef<WatchsteroidsGame>,
        FlameBlocListenable<GameCubit, GameState> {
  AsteroidSpawner() {
    timer = initialTimer;
  }

  static const interval = 2.0;

  late Timer timer;

  Timer get initialTimer => Timer(
        0,
        onTick: onTick,
        autoStart: false,
      );

  void onTick() {
    final nextPeriod = random.nextDouble() * 0.5 + interval;
    timer = Timer(
      nextPeriod,
      onTick: onTick,
    );

    final path = generateAsteroidPath();
    gameRef.flameMultiBlocProvider.add(Asteroid(path));
    // gameRef.add(ProtoRenderPath(path));
  }

  Path generateAsteroidPath() {
    final path = Path();
    final random = Random();

    final spawnArea = AsteroidSpawnArea
        .values[random.nextInt(AsteroidSpawnArea.values.length)];

    final curved = random.nextBool();

    AsteroidSpawnArea destinationArea;
    if (curved) {
      destinationArea = spawnArea.curvedOpposite;
    } else {
      destinationArea = spawnArea.opposite;
    }

    final originPoint = Vector2.random(random)..multiply(Vector2(200, 200));
    final destinationPoint = Vector2.random(random)
      ..multiply(Vector2(200, 200));

    final origin = spawnArea.origin + originPoint;
    final destination = destinationArea.origin + destinationPoint;

    path.moveTo(origin.x, origin.y);

    if (curved) {
      path.conicTo(0, 0, destination.x, destination.y, 2);
    } else {
      path.lineTo(destination.x, destination.y);
    }

    return path;
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

class Asteroid extends PositionComponent
    with
        HasGameRef<WatchsteroidsGame>,
        FlameBlocListenable<GameCubit, GameState> {
  Asteroid(this.path)
      : super(
          position: Vector2(0, 0),
          priority: 90,
          anchor: Anchor.center,
        );

  final Path path;

  late int heath = random.nextInt(2) + 2;

  void takeHit(Set<Vector2> intersectionPoints, double angle) {
    heath--;

    if (heath <= 0) {
      removeFromParent();
      gameRef.flameMultiBlocProvider.add(
        AsteroidExplosion(position: absolutePositionOfAnchor(Anchor.center)),
      );
      gameRef.scoreCubit.point();
    } else {
      for (final intersectionPoint in intersectionPoints) {
        gameRef.flameMultiBlocProvider.add(
          AsteroidHit(
            position: intersectionPoint,
          ),
        );
      }
    }
  }

  RotateEffect? rotateEffect;
  MoveAlongPathEffect? moveAlongPathEffect;

  @override
  Future<void> onLoad() async {
    await add(AsteroidSprite());

    await add(
      rotateEffect = RotateEffect.by(
        pi * 2,
        InfiniteEffectController(
          LinearEffectController(random.nextDouble() * 5 + 4),
        ),
      ),
    );

    await add(
      moveAlongPathEffect = MoveAlongPathEffect(
        path,
        LinearEffectController(random.nextDouble() * 10 + 12),
        onComplete: removeFromParent,
      ),
    );
  }

  @override
  void onNewState(GameState state) {
    switch (state) {
      case GameState.initial:
      case GameState.playing:
        removeFromParent();
        break;
      case GameState.gameOver:
        rotateEffect?.pause();
        moveAlongPathEffect?.pause();
        break;
    }
  }
}

class AsteroidSprite extends SpriteComponent
    with HasGameRef<WatchsteroidsGame>, ParentIsA<Asteroid> {
  AsteroidSprite({super.position}) : super(anchor: Anchor.center);

  @override
  Paint paint = Paint()..blendMode = BlendMode.softLight;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'protoasteroid2.png',
      srcSize: Vector2(57, 68),
    );
    size = Vector2(57, 68);

    position = Vector2.zero();

    await add(
      PolygonHitbox(
        [
          Vector2(26.5, 0),
          Vector2(38.5, 20.5),
          Vector2(55.9, 27),
          Vector2(38.1, 57.4),
          Vector2(13.7, 67.9),
          Vector2(0, 31.9),
          Vector2(10.3, 12.3),
        ],
        isSolid: true,
      ),
    );
  }
}

class ProtoRenderPath extends Component {
  ProtoRenderPath(this.path);

  final Path path;

  static final paint = Paint()
    ..color = const Color(0xFF00FF00)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawPath(path, paint);
  }
}
