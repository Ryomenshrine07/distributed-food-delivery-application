// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateOrderDto {

 String get restaurantId; DeliveryLocationDto get deliveryLocation; String get deliveryAddress; List<CreateOrderItemDto> get items;
/// Create a copy of CreateOrderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOrderDtoCopyWith<CreateOrderDto> get copyWith => _$CreateOrderDtoCopyWithImpl<CreateOrderDto>(this as CreateOrderDto, _$identity);

  /// Serializes this CreateOrderDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOrderDto&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.deliveryLocation, deliveryLocation) || other.deliveryLocation == deliveryLocation)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurantId,deliveryLocation,deliveryAddress,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'CreateOrderDto(restaurantId: $restaurantId, deliveryLocation: $deliveryLocation, deliveryAddress: $deliveryAddress, items: $items)';
}


}

/// @nodoc
abstract mixin class $CreateOrderDtoCopyWith<$Res>  {
  factory $CreateOrderDtoCopyWith(CreateOrderDto value, $Res Function(CreateOrderDto) _then) = _$CreateOrderDtoCopyWithImpl;
@useResult
$Res call({
 String restaurantId, DeliveryLocationDto deliveryLocation, String deliveryAddress, List<CreateOrderItemDto> items
});


$DeliveryLocationDtoCopyWith<$Res> get deliveryLocation;

}
/// @nodoc
class _$CreateOrderDtoCopyWithImpl<$Res>
    implements $CreateOrderDtoCopyWith<$Res> {
  _$CreateOrderDtoCopyWithImpl(this._self, this._then);

  final CreateOrderDto _self;
  final $Res Function(CreateOrderDto) _then;

/// Create a copy of CreateOrderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? restaurantId = null,Object? deliveryLocation = null,Object? deliveryAddress = null,Object? items = null,}) {
  return _then(_self.copyWith(
restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,deliveryLocation: null == deliveryLocation ? _self.deliveryLocation : deliveryLocation // ignore: cast_nullable_to_non_nullable
as DeliveryLocationDto,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CreateOrderItemDto>,
  ));
}
/// Create a copy of CreateOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryLocationDtoCopyWith<$Res> get deliveryLocation {
  
  return $DeliveryLocationDtoCopyWith<$Res>(_self.deliveryLocation, (value) {
    return _then(_self.copyWith(deliveryLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateOrderDto].
extension CreateOrderDtoPatterns on CreateOrderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOrderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOrderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOrderDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateOrderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOrderDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOrderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String restaurantId,  DeliveryLocationDto deliveryLocation,  String deliveryAddress,  List<CreateOrderItemDto> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOrderDto() when $default != null:
return $default(_that.restaurantId,_that.deliveryLocation,_that.deliveryAddress,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String restaurantId,  DeliveryLocationDto deliveryLocation,  String deliveryAddress,  List<CreateOrderItemDto> items)  $default,) {final _that = this;
switch (_that) {
case _CreateOrderDto():
return $default(_that.restaurantId,_that.deliveryLocation,_that.deliveryAddress,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String restaurantId,  DeliveryLocationDto deliveryLocation,  String deliveryAddress,  List<CreateOrderItemDto> items)?  $default,) {final _that = this;
switch (_that) {
case _CreateOrderDto() when $default != null:
return $default(_that.restaurantId,_that.deliveryLocation,_that.deliveryAddress,_that.items);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CreateOrderDto implements CreateOrderDto {
  const _CreateOrderDto({required this.restaurantId, required this.deliveryLocation, required this.deliveryAddress, required final  List<CreateOrderItemDto> items}): _items = items;
  factory _CreateOrderDto.fromJson(Map<String, dynamic> json) => _$CreateOrderDtoFromJson(json);

@override final  String restaurantId;
@override final  DeliveryLocationDto deliveryLocation;
@override final  String deliveryAddress;
 final  List<CreateOrderItemDto> _items;
@override List<CreateOrderItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of CreateOrderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOrderDtoCopyWith<_CreateOrderDto> get copyWith => __$CreateOrderDtoCopyWithImpl<_CreateOrderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOrderDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOrderDto&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.deliveryLocation, deliveryLocation) || other.deliveryLocation == deliveryLocation)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurantId,deliveryLocation,deliveryAddress,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'CreateOrderDto(restaurantId: $restaurantId, deliveryLocation: $deliveryLocation, deliveryAddress: $deliveryAddress, items: $items)';
}


}

/// @nodoc
abstract mixin class _$CreateOrderDtoCopyWith<$Res> implements $CreateOrderDtoCopyWith<$Res> {
  factory _$CreateOrderDtoCopyWith(_CreateOrderDto value, $Res Function(_CreateOrderDto) _then) = __$CreateOrderDtoCopyWithImpl;
@override @useResult
$Res call({
 String restaurantId, DeliveryLocationDto deliveryLocation, String deliveryAddress, List<CreateOrderItemDto> items
});


@override $DeliveryLocationDtoCopyWith<$Res> get deliveryLocation;

}
/// @nodoc
class __$CreateOrderDtoCopyWithImpl<$Res>
    implements _$CreateOrderDtoCopyWith<$Res> {
  __$CreateOrderDtoCopyWithImpl(this._self, this._then);

  final _CreateOrderDto _self;
  final $Res Function(_CreateOrderDto) _then;

/// Create a copy of CreateOrderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? restaurantId = null,Object? deliveryLocation = null,Object? deliveryAddress = null,Object? items = null,}) {
  return _then(_CreateOrderDto(
restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,deliveryLocation: null == deliveryLocation ? _self.deliveryLocation : deliveryLocation // ignore: cast_nullable_to_non_nullable
as DeliveryLocationDto,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CreateOrderItemDto>,
  ));
}

/// Create a copy of CreateOrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryLocationDtoCopyWith<$Res> get deliveryLocation {
  
  return $DeliveryLocationDtoCopyWith<$Res>(_self.deliveryLocation, (value) {
    return _then(_self.copyWith(deliveryLocation: value));
  });
}
}

// dart format on
