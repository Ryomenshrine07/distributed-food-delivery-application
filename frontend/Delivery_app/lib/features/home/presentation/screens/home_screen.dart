import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../assignment/domain/entities/delivery_assignment.dart';
import '../../../assignment/domain/entities/delivery_status.dart';
import '../../../assignment/presentation/providers/assignment_providers.dart';
import '../../../assignment/presentation/widgets/active_assignment_card.dart';
import '../../../assignment/presentation/widgets/offer_card.dart';
import '../../../availability/presentation/controllers/availability_controller.dart';
import '../../../availability/presentation/widgets/availability_toggle.dart';
import '../providers/home_offers_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// The order id currently being accepted, if any, so the matching
  /// [OfferCard] can show inline progress (Req 7.6).
  String? _acceptingOrderId;

  /// Accepts [offer] via the unchanged `acceptOffer` flow. On success the
  /// controller state becomes the active assignment and the body switches to
  /// the [ActiveAssignmentCard]; on failure the card returns to an actionable
  /// state and an error message is shown (Req 7.5, 7.7).
  Future<void> _accept(DeliveryAssignment offer) async {
    setState(() => _acceptingOrderId = offer.orderId);
    final error = await ref
        .read(assignmentControllerProvider.notifier)
        .acceptOffer(offer);
    if (!mounted) return;
    setState(() => _acceptingOrderId = null);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  /// Session-dismisses [orderId] by adding it to the volatile dismissed set,
  /// hiding the offer for the remainder of the session (Req 7.8, 7.10).
  void _dismiss(String orderId) {
    ref
        .read(dismissedOfferIdsProvider.notifier)
        .update((dismissed) => {...dismissed, orderId});
  }

  /// Brings the rider online from the offline empty-state call-to-action.
  Future<void> _goOnline() async {
    final failure = await ref
        .read(availabilityControllerProvider.notifier)
        .toggleStatus();
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAssignment = ref.watch(assignmentControllerProvider).value;
    final isOnline = ref.watch(availabilityControllerProvider).value ?? false;
    // Watched unconditionally so polling keeps running exactly as before
    // (Req 11 — preserve existing polling behavior).
    final offersAsync = ref.watch(visibleOffersProvider);

    final hasActiveAssignment = activeAssignment != null &&
        activeAssignment.status != DeliveryStatus.pending;

    final Widget body;
    if (hasActiveAssignment) {
      body = _buildActiveAssignment(activeAssignment);
    } else if (!isOnline) {
      body = _buildOffline();
    } else {
      body = _buildOffers(offersAsync);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Partner')),
      body: Column(
        children: [
          const AvailabilityToggle(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAssignment(DeliveryAssignment assignment) {
    return SingleChildScrollView(
      key: const ValueKey('home-active-assignment'),
      child: ActiveAssignmentCard(
        assignment: assignment,
        onNavigate: () =>
            context.push(AppRoutes.assignment(assignment.orderId)),
      ),
    );
  }

  Widget _buildOffline() {
    return EmptyState(
      key: const ValueKey('home-offline'),
      icon: Icons.offline_bolt_outlined,
      title: "You're offline",
      message: 'Go online to start receiving delivery offers.',
      actionLabel: 'Go online',
      onAction: _goOnline,
    );
  }

  Widget _buildOffers(AsyncValue<List<DeliveryAssignment>> offersAsync) {
    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) {
          return const EmptyState(
            key: ValueKey('home-waiting'),
            icon: Icons.delivery_dining_outlined,
            title: "You're online",
            message: 'Waiting for nearby orders...',
          );
        }
        return _OffersList(
          key: const ValueKey('home-offers'),
          offers: offers,
          acceptingOrderId: _acceptingOrderId,
          onAccept: _accept,
          onDismiss: _dismiss,
        );
      },
      loading: () => const LoadingState(
        key: ValueKey('home-offers-loading'),
        message: 'Finding offers...',
      ),
      error: (error, _) => ErrorState(
        key: const ValueKey('home-offers-error'),
        message: '$error',
        onRetry: () => ref.invalidate(pendingOffersProvider),
      ),
    );
  }
}

/// The scrollable list of pending offers. Each offer animates in with a
/// slide+fade entrance (keyed by `orderId`) and can be session-dismissed by
/// swiping or tapping Dismiss (Req 7.4, 7.8).
class _OffersList extends StatelessWidget {
  const _OffersList({
    super.key,
    required this.offers,
    required this.acceptingOrderId,
    required this.onAccept,
    required this.onDismiss,
  });

  final List<DeliveryAssignment> offers;
  final String? acceptingOrderId;
  final void Function(DeliveryAssignment offer) onAccept;
  final void Function(String orderId) onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: tokens.space8),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final isAccepting = acceptingOrderId == offer.orderId;
        return _OfferEntrance(
          key: ValueKey('offer-entrance-${offer.orderId}'),
          child: Dismissible(
            key: ValueKey('offer-dismiss-${offer.orderId}'),
            direction: isAccepting
                ? DismissDirection.none
                : DismissDirection.horizontal,
            onDismissed: (_) => onDismiss(offer.orderId),
            background: const _DismissBackground(alignment: Alignment.centerLeft),
            secondaryBackground:
                const _DismissBackground(alignment: Alignment.centerRight),
            child: OfferCard(
              offer: offer,
              isAccepting: isAccepting,
              onAccept: () => onAccept(offer),
              onDismiss: () => onDismiss(offer.orderId),
            ),
          ),
        );
      },
    );
  }
}

/// Plays a one-shot slide-up + fade-in entrance when first inserted. Because
/// the list keys each entry by `orderId`, a freshly-polled offer gets a new
/// state and animates in, while persisting offers keep their state and do not
/// re-animate (Req 7.4).
class _OfferEntrance extends StatefulWidget {
  const _OfferEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<_OfferEntrance> createState() => _OfferEntranceState();
}

class _OfferEntranceState extends State<_OfferEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// The swipe-to-dismiss background shown behind an [OfferCard].
class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.alignment});

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = context.colors;
    return Container(
      alignment: alignment,
      margin: EdgeInsets.symmetric(
        horizontal: tokens.space16,
        vertical: tokens.space8,
      ),
      padding: EdgeInsets.symmetric(horizontal: tokens.space24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: Icon(Icons.close, color: colors.onSurfaceVariant),
    );
  }
}
