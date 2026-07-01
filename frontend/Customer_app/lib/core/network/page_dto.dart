import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_dto.freezed.dart';
part 'page_dto.g.dart';

/// Wire mirror of a Spring `Page<T>` response (Req 24.3).
///
/// Models exactly the pagination fields the client consumes — `content`,
/// `number`, `size`, `totalElements`, `totalPages`, `last`, `first` — so the
/// round-trip property holds over precisely those fields. The element decoder
/// is supplied at `fromJson` time via the generated generic-argument factory.
///
/// This is the freezed DTO counterpart to the hand-written `PageResult<T>`
/// decoder in `page_response.dart`; the DTO→entity mapper (task 7.2) bridges
/// the two.
@Freezed(genericArgumentFactories: true)
abstract class PageDto<T> with _$PageDto<T> {
  /// Creates a [PageDto].
  const factory PageDto({
    required List<T> content,
    required int number,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool last,
    required bool first,
  }) = _PageDto<T>;

  /// Decodes a [PageDto] from a JSON map, using [fromJsonT] for each element of
  /// the `content` array.
  factory PageDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PageDtoFromJson(json, fromJsonT);
}
