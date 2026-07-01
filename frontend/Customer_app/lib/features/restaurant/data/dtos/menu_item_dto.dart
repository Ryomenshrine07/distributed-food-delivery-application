import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'menu_item_dto.freezed.dart';
part 'menu_item_dto.g.dart';

/// Wire mirror of the restaurant-service `MenuItemResponse` (Req 10).
///
/// `price` is monetary and decoded via [DecimalJsonConverter] for exactness.
/// `available` and `vegetarian` are nullable on the wire; the DTO keeps them
/// nullable so the round-trip stays faithful, and the DTO→entity mapper
/// (task 7.2) applies the `false`/`false` defaults.
@freezed
abstract class MenuItemDto with _$MenuItemDto {
  /// Creates a [MenuItemDto].
  const factory MenuItemDto({
    required String id,
    required String name,
    String? description,
    @DecimalJsonConverter() required Decimal price,
    bool? available,
    bool? vegetarian,
    String? imageUrl,
  }) = _MenuItemDto;

  /// Decodes a [MenuItemDto] from a JSON map.
  factory MenuItemDto.fromJson(Map<String, dynamic> json) =>
      _$MenuItemDtoFromJson(json);
}
