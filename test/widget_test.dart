import 'package:flutter_test/flutter_test.dart';
import 'package:bitacora_busmen/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));

    // Verify that the login screen title or something unique exists
    expect(find.text('Bitácora Busmen'), findsOneWidget);
  });
}
