import 'package:flutter_test/flutter_test.dart';
import '../app_widget.dart';

void main() {
  group('MapWidget', () {
    testWidgets(
        'tries to create the map widget but fails because the initial camera location is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(appWidget());

      // Wait for LocalizationsDelegate's futures
      await tester.pumpAndSettle();

      expect(find.text('Loading Map'), findsOneWidget);
    });
  });
}
