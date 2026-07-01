import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/result.dart';
import '../../../core/network/page_response.dart';
import '../../restaurant/data/mappers/restaurant_mapper.dart';
import '../../restaurant/domain/entities/restaurant.dart';
import '../domain/repositories/restaurant_repository.dart';
import 'restaurant_remote_data_source.dart';

/// Concrete implementation of [RestaurantRepository].
///
/// Maps DTO pages to domain entity pages via [RestaurantMapper].
class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl({required RestaurantRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final RestaurantRemoteDataSource _dataSource;

  @override
  Future<Result<PageResult<Restaurant>>> getRestaurants({
    int page = 0,
    int size = 10,
    String? city,
    String? category,
  }) async {
    try {
      final dtoPage = await _dataSource.getRestaurants(
        page: page,
        size: size,
        city: city,
        category: category,
      ) as PageResult;

      final mapped = PageResult<Restaurant>(
        content: dtoPage.content
            .map((dto) => RestaurantMapper.fromDto(dto))
            .toList(growable: false),
        number: dtoPage.number,
        size: dtoPage.size,
        totalElements: dtoPage.totalElements,
        totalPages: dtoPage.totalPages,
        last: dtoPage.last,
        first: dtoPage.first,
      );

      return Right(mapped);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(UnknownException(error: e)));
    }
  }

  @override
  Future<Result<PageResult<Restaurant>>> search({
    required String keyword,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final dtoPage = await _dataSource.searchRestaurants(
        keyword: keyword,
        page: page,
        size: size,
      ) as PageResult;

      final mapped = PageResult<Restaurant>(
        content: dtoPage.content
            .map((dto) => RestaurantMapper.fromDto(dto))
            .toList(growable: false),
        number: dtoPage.number,
        size: dtoPage.size,
        totalElements: dtoPage.totalElements,
        totalPages: dtoPage.totalPages,
        last: dtoPage.last,
        first: dtoPage.first,
      );

      return Right(mapped);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(UnknownException(error: e)));
    }
  }

  @override
  Future<Result<Restaurant>> getById(String id) async {
    try {
      final dto = await _dataSource.getRestaurantById(id);
      return Right(RestaurantMapper.fromDto(dto));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(UnknownException(error: e)));
    }
  }

  @override
  Future<Result<Restaurant>> getMenu(String restaurantId) async {
    try {
      final dto = await _dataSource.getRestaurantMenu(restaurantId);
      return Right(RestaurantMapper.fromDto(dto));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(UnknownException(error: e)));
    }
  }
}
