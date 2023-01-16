import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:watchsteroids/game/game.dart';

class TouchInputController extends SingleChildStatelessWidget {
  const TouchInputController({
    super.key,
    super.child,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _TouchInputControllerInner(
          constraints: constraints,
          child: child!,
        );
      },
    );
  }
}

class _TouchInputControllerInner extends StatefulWidget {
  const _TouchInputControllerInner({
    required this.child,
    required this.constraints,
  });

  final Widget child;

  final BoxConstraints constraints;

  @override
  State<_TouchInputControllerInner> createState() =>
      _TouchInputControllerInnerState();
}

class _TouchInputControllerInnerState
    extends State<_TouchInputControllerInner> {
  late final rotationCubit = context.read<RotationCubit>();
  late final gameCubit = context.read<GameCubit>();

  Size get size => widget.constraints.biggest;

  bool isDragging = false;

  double previousAngle = 0;
  double startShipAngle = 0;

  void handlePanStart(DragStartDetails details) {
    if (!gameCubit.isPlaying) {
      return;
    }

    final offsetToCenter = details.localPosition - size.center(Offset.zero);
    final distanceToCenter = offsetToCenter.distance;

    if (distanceToCenter < size.width * 0.1) {
      return;
    }

    previousAngle = offsetToCenter.direction;
    startShipAngle = rotationCubit.state.shipAngle;
    setState(() {
      isDragging = true;
    });
  }

  void handlePanUpdate(DragUpdateDetails details) {
    if (!isDragging || !gameCubit.isPlaying) {
      return;
    }

    final offsetToCenter = details.localPosition - size.center(Offset.zero);

    final currentAngle = offsetToCenter.direction;

    var angleDelta = currentAngle - previousAngle;

    final sign = angleDelta.sign;
    final angleDeltaAbs = angleDelta.abs();

    if (angleDeltaAbs > math.pi) {
      // It was past 3 AM when I wrote this.
      // I have no idea what is happening here.
      angleDelta = ((2 * math.pi) - angleDeltaAbs) * (sign * -1);
    }

    previousAngle = currentAngle;

    rotationCubit.rotateBy(angleDelta);
  }

  void handlePanEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
    });
  }

  void handlePanCancel() {
    setState(() {
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: handlePanStart,
      onPanUpdate: handlePanUpdate,
      onPanEnd: handlePanEnd,
      onPanCancel: handlePanCancel,
      child: widget.child,
    );
  }
}
