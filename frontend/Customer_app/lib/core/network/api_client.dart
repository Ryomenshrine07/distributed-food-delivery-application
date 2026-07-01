import 'package:dio/dio.dart';

import 'api_response.dart';
import 'dio_provider.dart';
import 'page_response.dart';

/// Generic API client wrapping [Dio] with typed helpers that hide envelope
/// and pagination decoding from data sources.
///
/// Two families of methods:
/// - `getEnvelope` / `getEnvelopePage` — for the restaurant service which wraps
///   responses in `ApiResponse<T>` (`{success, message, data}`).
/// - `getJson` / `postJson` / `patchJson` — for the order service which returns
///   bare JSON bodies without an envelope.
///
/// All methods accept an optional [CancelToken] for request cancellation.
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? DioProvider.instance();

  final Dio _dio;

  // ---------------------------------------------------------------------------
  // Restaurant service: envelope-wrapped responses
  // ---------------------------------------------------------------------------

  /// GET request expecting an `ApiResponse<T>` envelope.
  ///
  /// Returns the unwrapped `T` from `ApiResponse.data`.
  /// Throws [ApiEnvelopeException] when the envelope reports `success == false`.
  Future<T> getEnvelope<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    final envelope = ApiResponse<T>.fromJson(response.data!, fromJsonT);
    return envelope.data;
  }

  /// GET request expecting an `ApiResponse` envelope whose `data` field
  /// is a Spring Page shape.
  ///
  /// Returns a [PageResult<T>] with decoded content and pagination metadata.
  /// Throws [ApiEnvelopeException] when the envelope reports `success == false`.
  Future<PageResult<T>> getEnvelopePage<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    // Decode the outer envelope; the `data` field is the Page object.
    final envelope = ApiResponse<PageResult<T>>.fromJson(
      response.data!,
      (data) => PageResult<T>.fromJson(
        data as Map<String, dynamic>,
        fromJsonT,
      ),
    );

    return envelope.data;
  }
  /// GET request expecting an `ApiResponse` envelope whose `data` field
  /// is a JSON array.
  Future<List<T>> getEnvelopeList<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    final envelope = ApiResponse<List<T>>.fromJson(
      response.data!,
      (data) => (data as List<dynamic>).map((item) => fromJsonT(item)).toList(),
    );

    return envelope.data;
  }

  // ---------------------------------------------------------------------------
  // Order service: bare JSON bodies (no envelope)
  // ---------------------------------------------------------------------------

  /// GET request returning a bare JSON body decoded by [fromJsonT].
  Future<T> getJson<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );

    return fromJsonT(response.data);
  }

  /// POST request returning a bare JSON body decoded by [fromJsonT].
  Future<T> postJson<T>(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: body,
      cancelToken: cancelToken,
    );

    return fromJsonT(response.data);
  }

  /// PATCH request returning a bare JSON body decoded by [fromJsonT].
  Future<T> patchJson<T>(
    String path, {
    Object? body,
    CancelToken? cancelToken,
    required T Function(Object? json) fromJsonT,
  }) async {
    final response = await _dio.patch<dynamic>(
      path,
      data: body,
      cancelToken: cancelToken,
    );

    return fromJsonT(response.data);
  }
}
