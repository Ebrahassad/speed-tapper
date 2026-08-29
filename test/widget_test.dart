import 'package:flutter_test/flutter_test.dart';
import 'package:speed_tapper/main.dart';

void main() {
  testWidgets('Neon Breaker Pro starts correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NeonBreakerApp());

    expect(find.text('NEON'), findsOneWidget);
    expect(find.text('BREAKER PRO'), findsOneWidget);
    expect(find.text('ابدأ اللعب'), findsOneWidget);
  });
}
