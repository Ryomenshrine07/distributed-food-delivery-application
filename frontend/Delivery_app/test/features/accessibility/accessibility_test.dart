// Cross-cutting accessibility tests for the Delivery app (Task 10.2).
//
// Covers, for the controls introduced/modified by this feature:
//  - >=48x48 tap targets AND accessibility labels on call / accept / dismiss /
//    navigation actions                                          (Req 9.1, 9.2)
//  - redesigned text rows stay readable (no overflow/clipping) at a 200% OS
//    text scale                                                   (Req 9.4)
//  - the documented brand-on-surface token pairs meet the WCAG AA contrast
//    ratio (computed against the BrandPalette constants)          (Req 9.3)
//
// Note (Req 9.3): automated contrast checks cover the documented token pairs
// only. Full WCAG conformance still requires manual assistive-technology
// testing and expert review, which is out of scope for an automated suite.

import 'dart:math' as math;

import 'package:delivery_app/core/theme/app_theme.dart';
import 'package:delivery_app/core/theme/brand_palette.dart';
import 'package:delivery_app/core/widgets/call_button.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/assignment/presentation/widgets/active_assignment_card.dart';
import 'package:delivery_app/features/assignment/presentation/widgets/offer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// WCAG relative-luminance / contrast-ratio helper (small, self-contained).
// ---------------------------------------------------------------------------

/// Relative luminance of [color] per WCAG 2.1
/// (https://www.w3.org/TR/WCAG21/#dfn-relative-luminance). Channel accessors
/// `.r/.g/.b` are already normalized doubles in [0, 1].
double _relativeLuminance(Color color) {
  double linearize(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

/// WCAG contrast ratio between [foreground] and [background] (>= 1.0).
double _contrastRatio(Color foreground, Color background) {
  final lumFg = _relativeLuminance(foreground);
  final lumBg = _relativeLuminance(background);
  final lighter = math.max(lumFg, lumBg);
  final darker = math.min(lumFg, lumBg);
  return (lighter + 0.05) / (darker + 0.05);
}

/// A documented brand-on-surface color pair and the WCAG AA ratio it must meet.
/// `minRatio` is 4.5:1 for normal text and 3.0:1 for large text / UI components.
class _BrandPair {
  const _BrandPair(this.name, this.foreground, this.background, this.minRatio);
  final String name;
  final Color foreground;
  final Color background;
  final double minRatio;
}

DeliveryAssignment _offer(
  String orderId, {
  int itemCount = 2,
  DeliveryStatus status = DeliveryStatus.pending,
}) =>
    DeliveryAssignment(
      id: 'assign-$orderId',
      orderId: orderId,
      restaurantName: 'Pizza Palace',
      restaurantAddress: '1 Oven Street',
      restaurantLatitude: 1,
      restaurantLongitude: 2,
      customerName: 'Jane Customer',
      customerAddress: '2 Home Road',
      customerLatitude: 3,
      customerLongitude: 4,
      itemCount: itemCount,
      status: status,
    );

void main() {
  const white = Color(0xFFFFFFFF);

  /// Themed harness; renders [child] at [textScaler] when provided.
  Widget harness(Widget child, {double? textScaler}) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Center(child: child)),
        builder: textScaler == null
            ? null
            : (context, built) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(textScaler)),
                  child: built!,
                ),
      );

  // A Semantics widget carrying the given accessible [label] exists under [of].
  Finder semanticsLabel(Finder of, String label) => find.descendant(
        of: of,
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == label,
        ),
      );

  group('Tap targets and labels (Req 9.1, 9.2)', () {
    testWidgets('call control has a >=48x48 target and a "Call" label',
        (tester) async {
      await tester.pumpWidget(harness(const CallButton(phoneNumber: '5550102020')));

      expect(find.byTooltip('Call'), findsOneWidget);
      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('offer Accept/Dismiss have >=48 tall targets and labels',
        (tester) async {
      await tester.pumpWidget(
        harness(OfferCard(offer: _offer('o1'), onAccept: () {}, onDismiss: () {})),
      );

      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byType(OutlinedButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(semanticsLabel(find.byType(OfferCard), 'Accept offer'),
          findsOneWidget);
      expect(semanticsLabel(find.byType(OfferCard), 'Dismiss offer'),
          findsOneWidget);
    });

    testWidgets('active-assignment navigation action has a >=48 target + label',
        (tester) async {
      await tester.pumpWidget(
        harness(ActiveAssignmentCard(
          assignment: _offer('o1', status: DeliveryStatus.assigned),
          onNavigate: () {},
        )),
      );

      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      // The next-action label ("Navigate to Restaurant") is the accessible name.
      expect(
        semanticsLabel(find.byType(ActiveAssignmentCard), 'Navigate to Restaurant'),
        findsOneWidget,
      );
    });
  });

  group('200% text scale readability (Req 9.4)', () {
    testWidgets('OfferCard does not clip at a 2.0 text scale', (tester) async {
      await tester.pumpWidget(
        harness(
          OfferCard(offer: _offer('o1', itemCount: 3), onAccept: () {}, onDismiss: () {}),
          textScaler: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pizza Palace'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Accept'), findsOneWidget);
    });

    testWidgets('ActiveAssignmentCard does not clip at a 2.0 text scale',
        (tester) async {
      await tester.pumpWidget(
        harness(
          ActiveAssignmentCard(
            assignment: _offer('o1', status: DeliveryStatus.assigned),
            onNavigate: () {},
          ),
          textScaler: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Navigate to Restaurant'), findsOneWidget);
    });
  });

  group('Brand-on-surface contrast meets WCAG AA (Req 9.3)', () {
    test('documented BrandPalette pairs meet their AA threshold', () {
      const pairs = <_BrandPair>[
        // Req 5.5 header: title/status/icons (large text + UI) on brand green.
        _BrandPair('white on brandPrimary (header)', white,
            BrandPalette.brandPrimary, 3.0),
        // Pressed/scrim brand shade carries readable white text (normal text).
        _BrandPair('white on brandPrimaryDark', white,
            BrandPalette.brandPrimaryDark, 4.5),
        // Semantic status fills with their documented white on-color.
        _BrandPair(
            'onSuccess on success', white, BrandPalette.successLight, 4.5),
        // Orange warning fill reads at AA for large text / UI components.
        _BrandPair('onWarning on warning', white, BrandPalette.warningLight, 3.0),
        _BrandPair('onError on error', white, BrandPalette.errorLight, 4.5),
        _BrandPair('onInfo on info', white, BrandPalette.infoLight, 4.5),
      ];

      for (final pair in pairs) {
        final ratio = _contrastRatio(pair.foreground, pair.background);
        expect(
          ratio,
          greaterThanOrEqualTo(pair.minRatio),
          reason: '${pair.name}: ${ratio.toStringAsFixed(2)}:1 '
              '(min ${pair.minRatio}:1)',
        );
      }
    });

    test('the rendered header pair (onPrimary on primary) meets normal-text AA',
        () {
      for (final scheme in [
        AppTheme.light.colorScheme,
        AppTheme.dark.colorScheme,
      ]) {
        expect(
          _contrastRatio(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
      }
    });
  });
}
