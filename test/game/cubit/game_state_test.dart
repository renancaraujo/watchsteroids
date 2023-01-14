// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:watchsteroids/game/cubit/cubit.dart';

void main() {
  group('GameState', () {
    test('supports value equality', () {
      expect(
        GameState(1),
        equals(
          const GameState(1),
        ),
      );
    });

    group('constructor', () {
      test('can be instantiated', () {
        expect(
          const GameState(1),
          isNotNull,
        );
      });
    });
  });
}
