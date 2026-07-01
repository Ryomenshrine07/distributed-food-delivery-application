import 'package:freezed_annotation/freezed_annotation.dart';

import 'menu_item_dto.dart';

part 'category_dto.freezed.dart';
part 'category_dto.g.dart';

/// Wire mirror of the restaurant-service `CategoryResponse` (Req 10).
///
/// `items` is nullable on the wire (absent on some payloads); the DTO keeps it
/// nullable to round-trip faithfully, and the DTO→entity mapper (task 7.2)
/// defaults a missing list to `[]`.
@freezed
abstract class CategoryDto with _$CategoryDto {
  /// Creates a [CategoryDto].
  const factory CategoryDto({
    required String id,
    required String name,
    List<MenuItemDto>? items,
  }) = _CategoryDto;

  /// Decodes a [CategoryDto] from a JSON map.
  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);
}
