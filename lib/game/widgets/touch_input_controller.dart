import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:watchsteroids/game/game.dart';

class TouchInputController extends StatelessWidget {
  const TouchInputController({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _TouchInputControllerInner(
          constraints: constraints,
          child: child,
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
  late final gameCubit = context.read<GameCubit>();

  Size get size => widget.constraints.biggest;

  bool isDragging = false;

  double previousAngle = 0;
  double startShipAngle = 0;

  void handlePanStart(DragStartDetails details) {
    final offsetToCenter = details.localPosition - size.center(Offset.zero);
    final distanceToCenter = offsetToCenter.distance;

    if (distanceToCenter < size.width * 0.3) {
      return;
    }

    previousAngle = offsetToCenter.direction;
    startShipAngle = gameCubit.state.shipAngle;
    setState(() {
      isDragging = true;
    });
  }

  void handlePanUpdate(DragUpdateDetails details) {
    if (!isDragging) {
      return;
    }

    final offsetToCenter = details.localPosition - size.center(Offset.zero);
    final distanceToCenter = offsetToCenter.distance;

    if (distanceToCenter < size.width * 0.25) {
      setState(() {
        isDragging = false;
      });
      return;
    }

    final currentAngle = offsetToCenter.direction;

    var angleDelta = currentAngle - previousAngle;

    final sign = angleDelta.sign;
    final angleDeltaAbs = angleDelta.abs();

    if (angleDeltaAbs > math.pi) {
      angleDelta = ((2 * math.pi) - angleDeltaAbs) * (sign * -1);
    }

    previousAngle = currentAngle;

    gameCubit.rotateBy(angleDelta);
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
