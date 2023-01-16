import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:watchsteroids/game/game.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

class RotaryInputController extends SingleChildStatelessWidget {
  const RotaryInputController({
    super.key,
    super.child,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return _RotaryInputControllerInner(
      child: child!,
    );
  }
}

class _RotaryInputControllerInner extends StatefulWidget {
  const _RotaryInputControllerInner({required this.child});

  final Widget child;

  @override
  State<_RotaryInputControllerInner> createState() =>
      _RotaryInputControllerState();
}

class _RotaryInputControllerState extends State<_RotaryInputControllerInner> {
  late final StreamSubscription<RotaryEvent> rotarySubscription;

  late final rotationCubit = context.read<RotationCubit>();
  late final gameCubit = context.read<GameCubit>();

  @override
  void initState() {
    super.initState();

    // Maybe this shit work on Tizen??
    rotarySubscription = rotaryEvents.listen((RotaryEvent event) {
      if (gameCubit.state == GameState.gameOver) {
        return;
      }

      final double factor;
      if (event.direction == RotaryDirection.clockwise) {
        factor = 1;
      } else {
        factor = -1;
      }

      if (event.magnitude == 136.0) {
        rotationCubit.rotateBy(1.72 * factor * (math.pi / 12));
      } else {
        final maxmag = math.max(event.magnitude ?? 10, 10);
        final magn = (math.pi / 12) * (maxmag / 136);

        rotationCubit.rotateBy(factor * magn);
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
