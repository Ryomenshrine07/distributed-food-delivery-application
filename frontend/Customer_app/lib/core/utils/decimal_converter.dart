import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

/// JSON converter for monetary values backed by [Decimal].
///
/// The backend models money with `BigDecimal`, which can serialize either as a
/// JSON number (`12.5`) or a JSON string (`"12.50"`) depending on Jackson
/// configuration. Dart's `double` cannot represent decimal money exactly, so
/// every money field (`price`, `subtotal`, `deliveryFee`, `tax`, `totalAmount`,
/// `totalPrice`) is decoded into a [Decimal].
///
/// Reading is tolerant of number-or-string input; writing always produces the
/// canonical [Decimal.toString] representation so the value round-trips exactly
/// (`Decimal.parse(d.toString()) == d`) and compares by value (Req 24.3/24.4).
///
/// Apply to a freezed field with `@DecimalJsonConverter()`.
class DecimalJsonConverter implements JsonConverter<Decimal, Object?> {
  /// Creates a const converter instance for annotation use.
  const DecimalJsonConverter();

  @override
  Decimal fromJson(Object? json) {
    if (json is String) {
      return Decimal.parse(json);
    }
    if (json is num) {
      // Route through the string form so the full precision of the wire value
      // is preserved (avoids any intermediate binary-floating-point rounding).
      return Decimal.parse(json.toString());
    }
    throw FormatException(
      'Expected a number or numeric string for a money value, got: $json',
    );
  }

  @override
  Object? toJson(Decimal object) => object.toString();
}
