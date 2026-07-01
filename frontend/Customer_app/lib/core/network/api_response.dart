import '../error/app_exception.dart';

/// Decodes the restaurant-service response envelope `{success, message, data}`.
///
/// When `success == false`, an [ApiEnvelopeException] is thrown immediately so
/// upper layers never receive an envelope in an error state.
///
/// Usage:
/// ```dart
/// final response = ApiResponse.fromJson(json, (data) => Restaurant.fromJson(data as Map<String, dynamic>));
/// ```
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final T data;

  /// Decodes a raw JSON map into a typed [ApiResponse].
  ///
  /// [fromJsonT] is the decoder for the `data` field's content.
  /// Throws [ApiEnvelopeException] when `success == false`.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String? ?? '';

    if (!success) {
      throw ApiEnvelopeException(message: message);
    }

    final data = fromJsonT(json['data']);

    return ApiResponse<T>(
      success: success,
      message: message,
      data: data,
    );
  }
}
