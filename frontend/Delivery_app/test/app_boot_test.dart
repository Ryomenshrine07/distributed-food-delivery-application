import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_app/app.dart';

void main() {
  testWidgets('App boots and renders without exceptions', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeliveryApp()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
