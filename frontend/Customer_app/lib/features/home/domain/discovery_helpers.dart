import '../../restaurant/domain/entities/restaurant.dart';

/// Pure helper: sorts restaurants by rating descending for the "Recommended"
/// section. Restaurants with null ratings are placed at the end (stable).
List<Restaurant> sortByRatingDescending(List<Restaurant> restaurants) {
  final sorted = List<Restaurant>.from(restaurants);
  sorted.sort((a, b) {
    // Both null → preserve order; one null → non-null first.
    if (a.rating == null && b.rating == null) return 0;
    if (a.rating == null) return 1;
    if (b.rating == null) return -1;
    return b.rating!.compareTo(a.rating!); // Descending.
  });
  return sorted;
}

/// Pure helper: returns `true` when a prefetch should be triggered.
///
/// Triggers when the visible index is within [threshold] of the end
/// of the accumulated list and the last page has not been reached.
bool shouldPrefetch({
  required int visibleIndex,
  required int totalLoaded,
  required bool isLastPage,
  int threshold = 3,
}) {
  if (isLastPage) return false;
  return visibleIndex >= totalLoaded - threshold;
}

/// Pure helper: accumulates pages by concatenating content in order.
///
/// Stops accumulation when [isLastPage] is true.
List<Restaurant> accumulatePages(
  List<Restaurant> current,
  List<Restaurant> nextPageContent,
) {
  return [...current, ...nextPageContent];
}
