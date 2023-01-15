import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:watchsteroids/game/game.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

class RotaryInputController extends StatefulWidget {
  const RotaryInputController({super.key, required this.child});

  final Widget child;

  @override
  State<RotaryInputController> createState() => _RotaryInputControllerState();
}

class _RotaryInputControllerState extends State<RotaryInputController> {
  late final StreamSubscription<RotaryEvent> rotarySubscription;

  late final gameCubit = context.read<GameCubit>();

  @override
  void initState() {
    super.initState();

    rotarySubscription = rotaryEvents.listen((RotaryEvent event) {
      final double factor;
      if (event.direction == RotaryDirection.clockwise) {
        factor = 1;
      } else {
        factor = -1;
      }

      if (event.magnitude == 136.0) {
        gameCubit.rotateBy(1.72 * factor * (math.pi / 12));
      } else {
        final maxmag = math.max(event.magnitude ?? 10, 10);
        final magn = (math.pi / 12) * (maxmag / 136);

        gameCubit.rotateBy(factor * magn);
      }
    });
  }

  @override
  void dispose() {
    rotarySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
