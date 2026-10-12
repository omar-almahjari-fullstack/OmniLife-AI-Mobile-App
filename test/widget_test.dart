import 'package:flutter_test/flutter_test.dart';
import 'package:chat_ai/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const OmniLifeAIApp());
    expect(find.byType(OmniLifeAIApp), findsOneWidget);
  });
}
