// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchsteroids/game/game.dart';

import '../../helpers/helpers.dart';

void main() {
  initHydratedBloc();

  group('GamePage', () {
    group('route', () {
      test('is routable', () {
        expect(GamePage.route(), isA<MaterialPageRoute<dynamic>>());
      });
    });

    testWidgets('renders GameView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: GamePage()));
      expect(find.byType(GameView), findsOneWidget);
    });
  });
}
