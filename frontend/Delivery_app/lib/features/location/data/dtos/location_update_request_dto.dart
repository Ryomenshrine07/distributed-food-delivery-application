import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_update_request_dto.freezed.dart';
part 'location_update_request_dto.g.dart';

@freezed
abstract class LocationUpdateRequestDto with _$LocationUpdateRequestDto {
  const factory LocationUpdateRequestDto({
    required double latitude,
    required double longitude,
  }) = _LocationUpdateRequestDto;

  factory LocationUpdateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateRequestDtoFromJson(json);
}
