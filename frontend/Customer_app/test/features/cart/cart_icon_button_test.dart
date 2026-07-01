// Widget tests for CartIconButton.
//
// Verifies the reactive cart badge behaviour and its accessibility label:
//  - hidden while the cart is empty            (Req 2.3 baseline / Req 2.2)
//  - shows the current item count              (Req 2.5 placement + count)
//  - updates when the cart changes             (Req 2.3)
//  - caps the display at "99+" beyond 99        (Req 2.4 rendering)
//  - announces "Cart, N items" to a11y          (Req 2.7)

import 'package:customer_app/features/cart/presentation/cart_controller.dart';
import 'package:customer_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Adds [quantity] units of a single line so `Cart.totalItems == <running
  // total>`. Called repeatedly on the same item to grow the count.
  void addUnits(ProviderContainer container, int quantity) {
    container.read(cartControllerProvider.notifier).addItem(
          restaurantId: 'r1',
          restaurantName: 'Test Diner',
          menuItemId: 'm1',
          itemName: 'Test Item',
          price: Decimal.fromInt(5),
          quantity: quantity,
        );
  }

  // Renders the button inside a realistic AppBar actions slot.
  Widget harness(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Discover'),
              actions: const [CartIconButton()],
            ),
          ),
        ),
      );

  testWidgets('hides the badge label while the cart is empty', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    await tester.pump();

    // The icon is present, the badge exists, but no numeric label is shown.
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.text('0'), findsNothing);
    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);
  });

  testWidgets('shows the exact item count when the cart is non-empty',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    addUnits(container, 3);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);
  });

  testWidgets('updates reactively when the cart count changes', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));

    addUnits(container, 2);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // Growing the same line to a total of 7 must re-render the badge.
    addUnits(container, 5);
    await tester.pump();
    expect(find.text('7'), findsOneWidget);
    expect(find.text('2'), findsNothing);

    // Clearing the cart hides the badge again.
    container.read(cartControllerProvider.notifier).clearCart();
    await tester.pump();
    expect(find.text('7'), findsNothing);
    expect(tester.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
  });

  testWidgets('caps the displayed label at "99+" above 99 items',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    addUnits(container, 150);
    await tester.pump();

    expect(find.text('99+'), findsOneWidget);
    expect(find.text('150'), findsNothing);
  });

  testWidgets('exposes the "Cart, N items" accessibility label',
      (tester) async {
    final handle = tester.ensureSemantics();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(harness(container));
    addUnits(container, 4);
    await tester.pump();

    final semantics = tester.getSemantics(find.byType(CartIconButton));
    expect(semantics.label, 'Cart, 4 items');

    handle.dispose();
  });
}
