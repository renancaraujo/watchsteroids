import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/rendering.dart';
import 'package:watchsteroids/game/game.dart';

// class ProtoAsteroid extends RectangleComponent {
//   ProtoAsteroid()
//       : super(
//           size: Vector2(100, 49),
//           angle: pi / 4,
//           paint: Paint()
//
//             ..shader = Gradient.linear(
//               Offset.zero,
//               Offset(50, 50),
//               [
//                 Color(0xFF000000),
//                 Color(0xFFF4F2E9),
//
//               ],
//             )
//             ..blendMode = BlendMode.softLight,
//           position: Vector2(40, -180),
//           priority: 90,
//         );
// }

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

class AsteroidSpawner extends Component with HasGameRef<WatchsteroidsGame> {
  AsteroidSpawner() {
    timer = Timer(
      interval,
      onTick: onTick,
    );
  }

  static const interval = 4.0;

  late Timer timer;

  void onTick() {
    final nextPeriod = random.nextDouble() * 0.5 + interval;
    timer = Timer(
      nextPeriod,
      onTick: onTick,
    );

    final path = generateAsteroidPath();
    gameRef.add(AsteroidSprite(path));
    // gameRef.add(ProtoRenderPath(path));
  }

  /// Randomly generates elliptical paths that passes though the center of the screen
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
    timer.update(dt);
  }
}

class AsteroidSprite extends SpriteComponent
    with HasGameRef<WatchsteroidsGame> {
  AsteroidSprite(this.path)
      : super(
          position: Vector2(40, -10),
          priority: 90,
          anchor: Anchor.center,
        );

  final Path path;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(
      'protoasteroid2.png',
      srcSize: Vector2(57, 68),
    );
    size = Vector2(57, 68);

    await add(
      RotateEffect.by(
        pi * 2,
        InfiniteEffectController(
          LinearEffectController(random.nextDouble() * 5 + 5),
        ),
      ),
    );

    await add(
      MoveAlongPathEffect(
        path,
        LinearEffectController(random.nextDouble() * 10 + 12),
        onComplete: () {
          gameRef.remove(this);
        },
      ),
    );
  }

  @override
  Paint get paint => Paint()..blendMode = BlendMode.softLight;
}

class ProtoRenderPath extends Component {
  ProtoRenderPath(this.path);

  final Path path;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }
}
