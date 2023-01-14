// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchsteroids/game/game.dart';

void main() {
  group('GameBody', () {
    testWidgets('renders Text', (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (context) => GameCubit(),
          child: MaterialApp(home: GameBody()),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
