// Feature: ui-modernization, Property 1: Cart badge visibility and label mapping
//
// Property 1: Cart badge visibility and label mapping
// For any total item count, the cart badge is visible if and only if the count
// is greater than zero; its rendered label is the exact count for 1–99 and the
// capped "99+" for counts above 99.
//
// The oracle is derived directly from the specification (visible iff count > 0;
// exact label for 1..99; "99+" above 99) rather than from the implementation,
// so the test exercises the pure mapping across the whole non-negative input
// space including the boundaries 0, 1, 99 and 100.
//
// **Validates: Requirements 2.1, 2.2, 2.4**

import 'package:customer_app/features/cart/presentation/widgets/cart_icon_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/generators.dart';
import '../../support/pbt.dart';

void main() {
  group(propertyTag(1, 'Cart badge visibility and label mapping'), () {
    test('visibility and label hold across generated counts (>=100 iterations)',
        () {
      // Counts spanning empty, single-digit, the 99 boundary, and well past the
      // cap so both the exact-count and overflow branches are exercised.
      forAll<int>(
        Gen.intInRange(0, 250),
        (count) {
          // Req 2.2: hidden at zero. Req 2.1: shown for at least one item.
          expect(
            cartBadgeVisible(count),
            count > 0,
            reason: 'visibility must be (count > 0) for count=$count',
          );

          // Req 2.1 / 2.4: exact count for 1–99, "99+" above 99.
          if (count > kCartBadgeMaxCount) {
            expect(
              cartBadgeLabel(count),
              '99+',
              reason: 'counts above $kCartBadgeMaxCount cap to "99+"',
            );
          } else {
            expect(
              cartBadgeLabel(count),
              '$count',
              reason: 'counts 0..$kCartBadgeMaxCount render the exact number',
            );
          }
        },
        describe: (count) => 'count=$count',
      );
    });
  });
}
