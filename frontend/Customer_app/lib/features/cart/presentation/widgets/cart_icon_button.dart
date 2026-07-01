import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../cart_controller.dart';

/// The largest item count shown as an exact number on the cart badge. Counts
/// above this are rendered as [_overflowLabel] so the badge never overflows.
const int kCartBadgeMaxCount = 99;

/// The label shown when the item count exceeds [kCartBadgeMaxCount].
const String _overflowLabel = '99+';

/// Whether the cart badge should be shown for a given item [count].
///
/// Pure function (no widget or provider dependencies) so the visibility rule is
/// unit- and property-testable. The badge is visible if and only if the cart
/// holds at least one item.
bool cartBadgeVisible(int count) => count > 0;

/// The label text painted on the cart badge for a given item [count].
///
/// Pure function: returns the exact count for 1–[kCartBadgeMaxCount] and the
/// capped [_overflowLabel] ("99+") for counts above the cap. The value is only
/// meaningful while [cartBadgeVisible] is true.
String cartBadgeLabel(int count) =>
    count > kCartBadgeMaxCount ? _overflowLabel : '$count';

/// The accessibility label announced for the cart control at a given [count].
///
/// Pure function: always announces the exact count N (never the capped label),
/// e.g. `"Cart, 3 items"`, so assistive technology reads the true cart size.
String cartBadgeSemanticLabel(int count) => 'Cart, $count items';

/// A cart icon button carrying a reactive Material 3 item-count [Badge].
///
/// Reads only the cart's `totalItems` (via `select`) so it rebuilds only when
/// the count changes. It hides the badge at zero, shows the exact count for
/// 1–99, and caps at "99+" beyond that. The existing navigation to the cart
/// screen and the "Cart" tooltip are preserved, and it exposes a
/// "Cart, N items" accessibility label. Reused across every AppBar that shows
/// the cart icon (home, restaurant detail).
class CartIconButton extends ConsumerWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `select` narrows the watch to the item count, so unrelated cart mutations
    // (e.g. restaurant name) do not rebuild this button.
    final count = ref.watch(
      cartControllerProvider.select((cart) => cart.totalItems),
    );

    // A single semantics node carries the button role, the "Cart, N items"
    // label, and a tap action; descendant semantics (the numeric badge and the
    // visual "Cart" tooltip) are excluded so the announcement stays clean and
    // unambiguous. Pointer taps still reach the IconButton, and the visual
    // tooltip still renders — excludeSemantics only affects the semantics tree.
    return Semantics(
      container: true,
      button: true,
      label: cartBadgeSemanticLabel(count),
      onTap: () => context.push(AppRoutes.cart),
      excludeSemantics: true,
      // IconButton's default constraints are >=48x48 logical pixels, so the tap
      // target already satisfies the accessibility minimum.
      child: IconButton(
        tooltip: 'Cart',
        onPressed: () => context.push(AppRoutes.cart),
        icon: Badge(
          isLabelVisible: cartBadgeVisible(count),
          label: Text(cartBadgeLabel(count)),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
