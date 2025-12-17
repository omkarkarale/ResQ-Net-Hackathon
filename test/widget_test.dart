import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resq_net/main.dart';

void main() {
  testWidgets('ResQNetApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ResQNetApp()));
    await tester.pump();

    // Basic sanity: app builds a widget tree.
    expect(find.byType(ResQNetApp), findsOneWidget);
  });
}
