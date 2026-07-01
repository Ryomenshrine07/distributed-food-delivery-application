import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../restaurant/domain/entities/restaurant.dart';
import '../data/restaurant_remote_data_source.dart';
import '../data/restaurant_repository_impl.dart';
import '../domain/discovery_helpers.dart';
import '../domain/repositories/restaurant_repository.dart';

part 'home_controller.g.dart';

/// Provides the [RestaurantRepository] singleton.
@riverpod
RestaurantRepository restaurantRepository(Ref ref) {
  final apiClient = ApiClient();
  final dataSource = RestaurantRemoteDataSource(apiClient: apiClient);
  return RestaurantRepositoryImpl(dataSource: dataSource);
}

/// State for the home feed with accumulated restaurants and pagination metadata.
class HomeFeedState {
  const HomeFeedState({
    this.restaurants = const [],
    this.isLoadingMore = false,
    this.isLastPage = false,
    this.currentPage = 0,
    this.city,
    this.category,
  });

  final List<Restaurant> restaurants;
  final bool isLoadingMore;
  final bool isLastPage;
  final int currentPage;
  final String? city;
  final String? category;

  /// Recommended section = top restaurants sorted by rating desc.
  List<Restaurant> get recommended => sortByRatingDescending(
        restaurants.take(5).toList(),
      );

  HomeFeedState copyWith({
    List<Restaurant>? restaurants,
    bool? isLoadingMore,
    bool? isLastPage,
    int? currentPage,
    String? city,
    String? category,
    bool clearCity = false,
    bool clearCategory = false,
  }) {
    return HomeFeedState(
      restaurants: restaurants ?? this.restaurants,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLastPage: isLastPage ?? this.isLastPage,
      currentPage: currentPage ?? this.currentPage,
      city: clearCity ? null : (city ?? this.city),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

/// Controller for the home discovery feed.
///
/// Manages paginated restaurant loading, filter state, and recommended
/// section. Uses infinite scroll with prefetch threshold.
@riverpod
class HomeFeedController extends _$HomeFeedController {
  @override
  Future<HomeFeedState> build() async {
    final repo = ref.watch(restaurantRepositoryProvider);
    final result = await repo.getRestaurants(page: 0);
    return result.fold(
      (failure) => throw failure,
      (page) => HomeFeedState(
        restaurants: page.content,
        isLastPage: page.last,
        currentPage: page.number,
      ),
    );
  }

  /// Loads the next page and appends to the accumulated list.
  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || current.isLastPage) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final repo = ref.read(restaurantRepositoryProvider);
    final result = await repo.getRestaurants(
      page: current.currentPage + 1,
      city: current.city,
      category: current.category,
    );

    result.fold(
      (failure) => state = AsyncData(current.copyWith(isLoadingMore: false)),
      (page) => state = AsyncData(current.copyWith(
        restaurants: accumulatePages(current.restaurants, page.content),
        isLoadingMore: false,
        isLastPage: page.last,
        currentPage: page.number,
      )),
    );
  }

  /// Sets the city filter and reloads.
  void setCity(String? city) {
    state = const AsyncLoading();
    _reload(city: city);
  }

  /// Sets the category filter and reloads.
  void setCategory(String? category) {
    state = const AsyncLoading();
    _reload(category: category);
  }

  Future<void> _reload({String? city, String? category}) async {
    final repo = ref.read(restaurantRepositoryProvider);
    final result = await repo.getRestaurants(
      page: 0,
      city: city,
      category: category,
    );

    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (page) => state = AsyncData(HomeFeedState(
        restaurants: page.content,
        isLastPage: page.last,
        currentPage: page.number,
        city: city,
        category: category,
      )),
    );
  }
}

/// Controller for restaurant search with debounce and supersede-cancel.
@riverpod
class RestaurantSearchController extends _$RestaurantSearchController {
  Timer? _debounceTimer;

  @override
  AsyncValue<List<Restaurant>> build() => const AsyncData([]);

  /// Searches restaurants with a debounced query.
  void search(String keyword) {
    _debounceTimer?.cancel();

    if (keyword.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }

    _debounceTimer = Timer(AppConstants.debounceDuration, () async {
      state = const AsyncLoading();

      final repo = ref.read(restaurantRepositoryProvider);
      final result = await repo.search(keyword: keyword.trim());

      result.fold(
        (failure) => state = AsyncError(failure, StackTrace.current),
        (page) => state = AsyncData(page.content),
      );
    });
  }

  /// Clears the search results.
  void clear() {
    _debounceTimer?.cancel();
    state = const AsyncData([]);
  }
}
