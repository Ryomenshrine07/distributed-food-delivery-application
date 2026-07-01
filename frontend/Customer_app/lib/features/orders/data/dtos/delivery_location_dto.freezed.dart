// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryLocationDto {

 String get address; double get latitude; double get longitude;
/// Create a copy of DeliveryLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryLocationDtoCopyWith<DeliveryLocationDto> get copyWith => _$DeliveryLocationDtoCopyWithImpl<DeliveryLocationDto>(this as DeliveryLocationDto, _$identity);

  /// Serializes this DeliveryLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryLocationDto&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'DeliveryLocationDto(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $DeliveryLocationDtoCopyWith<$Res>  {
  factory $DeliveryLocationDtoCopyWith(DeliveryLocationDto value, $Res Function(DeliveryLocationDto) _then) = _$DeliveryLocationDtoCopyWithImpl;
@useResult
$Res call({
 String address, double latitude, double longitude
});




}
/// @nodoc
class _$DeliveryLocationDtoCopyWithImpl<$Res>
    implements $DeliveryLocationDtoCopyWith<$Res> {
  _$DeliveryLocationDtoCopyWithImpl(this._self, this._then);

  final DeliveryLocationDto _self;
  final $Res Function(DeliveryLocationDto) _then;

/// Create a copy of DeliveryLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryLocationDto].
extension DeliveryLocationDtoPatterns on DeliveryLocationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryLocationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryLocationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryLocationDto value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryLocationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryLocationDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryLocationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryLocationDto() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _DeliveryLocationDto():
return $default(_that.address,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryLocationDto() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryLocationDto implements DeliveryLocationDto {
  const _DeliveryLocationDto({required this.address, required this.latitude, required this.longitude});
  factory _DeliveryLocationDto.fromJson(Map<String, dynamic> json) => _$DeliveryLocationDtoFromJson(json);

@override final  String address;
@override final  double latitude;
@override final  double longitude;

/// Create a copy of DeliveryLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryLocationDtoCopyWith<_DeliveryLocationDto> get copyWith => __$DeliveryLocationDtoCopyWithImpl<_DeliveryLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryLocationDto&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude);

@override
String toString() {
  return 'DeliveryLocationDto(address: $address, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$DeliveryLocationDtoCopyWith<$Res> implements $DeliveryLocationDtoCopyWith<$Res> {
  factory _$DeliveryLocationDtoCopyWith(_DeliveryLocationDto value, $Res Function(_DeliveryLocationDto) _then) = __$DeliveryLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String address, double latitude, double longitude
});




}
/// @nodoc
class __$DeliveryLocationDtoCopyWithImpl<$Res>
    implements _$DeliveryLocationDtoCopyWith<$Res> {
  __$DeliveryLocationDtoCopyWithImpl(this._self, this._then);

  final _DeliveryLocationDto _self;
  final $Res Function(_DeliveryLocationDto) _then;

/// Create a copy of DeliveryLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,}) {
  return _then(_DeliveryLocationDto(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
