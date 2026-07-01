import 'package:flutter_riverpod/flutter_riverpod.dart';
// StateProvider is a legacy API in Riverpod 3.x and lives in the legacy library.
import 'package:flutter_riverpod/legacy.dart';

import '../../../assignment/domain/entities/delivery_assignment.dart';
import '../../../assignment/presentation/providers/assignment_providers.dart';

/// Session-local set of dismissed offer order ids.
///
/// There is no backend "decline" mechanism (Req 7.10): a dismissal is stored
/// only in this volatile, `autoDispose` state. When the delivery home is torn
/// down (session-local set is reset) a previously dismissed offer can reappear
/// on the next poll.
final dismissedOfferIdsProvider =
    StateProvider.autoDispose<Set<String>>((ref) => <String>{});

/// Pure filter for the offers the delivery home should display.
///
/// Returns exactly those [offers] whose [DeliveryAssignment.orderId] is **not**
/// in the [dismissed] set, preserving the original order (Req 7.8, 7.9).
/// Extracted as a pure, side-effect-free function so it can be property-tested
/// independently of any widget or provider (see Property 4).
List<DeliveryAssignment> visibleOffers(
  List<DeliveryAssignment> offers,
  Set<String> dismissed,
) =>
    offers.where((offer) => !dismissed.contains(offer.orderId)).toList();

/// The offers to render on the delivery home: the polled offers from
/// [pendingOffersProvider] with the session-local [dismissedOfferIdsProvider]
/// filtered out via [visibleOffers].
///
/// Recomputes whenever a new poll arrives or the dismissed set changes.
final visibleOffersProvider =
    Provider.autoDispose<AsyncValue<List<DeliveryAssignment>>>((ref) {
  final offersAsync = ref.watch(pendingOffersProvider);
  final dismissed = ref.watch(dismissedOfferIdsProvider);
  return offersAsync.whenData((offers) => visibleOffers(offers, dismissed));
});
