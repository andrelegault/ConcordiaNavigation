import 'package:concordia_navigation/models/outdoor/campus.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_app_widget.dart';

void main() {
  group('MapWidget', () {
    testWidgets(
        'tries to create the map widget but fails because the initial camera location is null',
        (WidgetTester tester) async {
      List<dynamic> campusData = await Campus.loadJson();
      
      await tester.pumpWidget(testAppWidget);

      // Wait for LocalizationsDelegate's futures
      await tester.pumpAndSettle();

      expect(find.text('Loading Map'), findsOneWidget);
    });
  });
}
