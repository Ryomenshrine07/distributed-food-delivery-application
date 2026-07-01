import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response_dto.freezed.dart';
part 'api_response_dto.g.dart';

/// Wire mirror of the restaurant-service `ApiResponse<T>` envelope
/// (`{success, message, data}`) (Req 24.1, 24.2).
///
/// This is the freezed DTO counterpart to the hand-written [ApiResponse]
/// decoder in `api_response.dart`. Where that decoder throws on
/// `success == false` to drive error mapping at the network boundary, this DTO
/// is a faithful value mirror used where the full envelope is round-tripped or
/// inspected. The payload decoder is supplied at `fromJson` time via the
/// generated generic-argument factory.
@Freezed(genericArgumentFactories: true)
abstract class ApiResponseDto<T> with _$ApiResponseDto<T> {
  /// Creates an [ApiResponseDto].
  const factory ApiResponseDto({
    required bool success,
    required String message,
    required T data,
  }) = _ApiResponseDto<T>;

  /// Decodes an [ApiResponseDto] from a JSON map, using [fromJsonT] for the
  /// `data` payload.
  factory ApiResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseDtoFromJson(json, fromJsonT);
}
