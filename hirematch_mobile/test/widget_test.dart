import 'package:flutter_test/flutter_test.dart';
import 'package:hirematch_mobile/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HireMatchApp());

    expect(find.text('HireMatch'), findsOneWidget);
  });
}
