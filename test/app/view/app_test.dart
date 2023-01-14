import 'package:flutter_test/flutter_test.dart';
import 'package:watchsteroids/app/app.dart';
import 'package:watchsteroids/game/game.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(GamePage), findsOneWidget);
    });
  });
}
