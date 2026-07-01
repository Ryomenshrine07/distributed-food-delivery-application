// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateOrderItemDto {

 String get menuItemId; String get itemName; int get quantity;
/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOrderItemDtoCopyWith<CreateOrderItemDto> get copyWith => _$CreateOrderItemDtoCopyWithImpl<CreateOrderItemDto>(this as CreateOrderItemDto, _$identity);

  /// Serializes this CreateOrderItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOrderItemDto&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuItemId,itemName,quantity);

@override
String toString() {
  return 'CreateOrderItemDto(menuItemId: $menuItemId, itemName: $itemName, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CreateOrderItemDtoCopyWith<$Res>  {
  factory $CreateOrderItemDtoCopyWith(CreateOrderItemDto value, $Res Function(CreateOrderItemDto) _then) = _$CreateOrderItemDtoCopyWithImpl;
@useResult
$Res call({
 String menuItemId, String itemName, int quantity
});




}
/// @nodoc
class _$CreateOrderItemDtoCopyWithImpl<$Res>
    implements $CreateOrderItemDtoCopyWith<$Res> {
  _$CreateOrderItemDtoCopyWithImpl(this._self, this._then);

  final CreateOrderItemDto _self;
  final $Res Function(CreateOrderItemDto) _then;

/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuItemId = null,Object? itemName = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateOrderItemDto].
extension CreateOrderItemDtoPatterns on CreateOrderItemDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOrderItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOrderItemDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateOrderItemDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOrderItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String menuItemId,  String itemName,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
return $default(_that.menuItemId,_that.itemName,_that.quantity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String menuItemId,  String itemName,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _CreateOrderItemDto():
return $default(_that.menuItemId,_that.itemName,_that.quantity);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String menuItemId,  String itemName,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
return $default(_that.menuItemId,_that.itemName,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateOrderItemDto implements CreateOrderItemDto {
  const _CreateOrderItemDto({required this.menuItemId, required this.itemName, required this.quantity});
  factory _CreateOrderItemDto.fromJson(Map<String, dynamic> json) => _$CreateOrderItemDtoFromJson(json);

@override final  String menuItemId;
@override final  String itemName;
@override final  int quantity;

/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOrderItemDtoCopyWith<_CreateOrderItemDto> get copyWith => __$CreateOrderItemDtoCopyWithImpl<_CreateOrderItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOrderItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOrderItemDto&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuItemId,itemName,quantity);

@override
String toString() {
  return 'CreateOrderItemDto(menuItemId: $menuItemId, itemName: $itemName, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CreateOrderItemDtoCopyWith<$Res> implements $CreateOrderItemDtoCopyWith<$Res> {
  factory _$CreateOrderItemDtoCopyWith(_CreateOrderItemDto value, $Res Function(_CreateOrderItemDto) _then) = __$CreateOrderItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String menuItemId, String itemName, int quantity
});




}
/// @nodoc
class __$CreateOrderItemDtoCopyWithImpl<$Res>
    implements _$CreateOrderItemDtoCopyWith<$Res> {
  __$CreateOrderItemDtoCopyWithImpl(this._self, this._then);

  final _CreateOrderItemDto _self;
  final $Res Function(_CreateOrderItemDto) _then;

/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuItemId = null,Object? itemName = null,Object? quantity = null,}) {
  return _then(_CreateOrderItemDto(
menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
