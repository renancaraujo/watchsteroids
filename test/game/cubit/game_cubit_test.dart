// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:watchsteroids/game/cubit/cubit.dart';

void main() {
  group('GameCubit', () {
    group('constructor', () {
      test('can be instantiated', () {
        expect(
          RotationCubit(),
          isNotNull,
        );
      });
    });

    test('initial state has default value for customProperty', () {
      final gameCubit = RotationCubit();
      expect(gameCubit.state.shipAngle, equals(0));
    });
  });
}
