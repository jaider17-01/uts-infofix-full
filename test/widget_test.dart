import 'package:flutter_test/flutter_test.dart';
import 'package:uts_infofix/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UTSInfoFixApp());
    expect(find.byType(UTSInfoFixApp), findsOneWidget);
  });
}
