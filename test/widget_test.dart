import 'package:flutter_test/flutter_test.dart';
import 'package:testzavi/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const DarazApp());
    expect(find.byType(DarazApp), findsOneWidget);
  });
}
