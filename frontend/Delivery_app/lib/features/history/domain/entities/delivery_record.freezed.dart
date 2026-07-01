// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryRecord {

 String get orderId; DateTime get deliveredAt; String get pickupAddress; String get dropAddress; double get distanceKm; double get payout;
/// Create a copy of DeliveryRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryRecordCopyWith<DeliveryRecord> get copyWith => _$DeliveryRecordCopyWithImpl<DeliveryRecord>(this as DeliveryRecord, _$identity);

  /// Serializes this DeliveryRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryRecord&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.dropAddress, dropAddress) || other.dropAddress == dropAddress)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.payout, payout) || other.payout == payout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,deliveredAt,pickupAddress,dropAddress,distanceKm,payout);

@override
String toString() {
  return 'DeliveryRecord(orderId: $orderId, deliveredAt: $deliveredAt, pickupAddress: $pickupAddress, dropAddress: $dropAddress, distanceKm: $distanceKm, payout: $payout)';
}


}

/// @nodoc
abstract mixin class $DeliveryRecordCopyWith<$Res>  {
  factory $DeliveryRecordCopyWith(DeliveryRecord value, $Res Function(DeliveryRecord) _then) = _$DeliveryRecordCopyWithImpl;
@useResult
$Res call({
 String orderId, DateTime deliveredAt, String pickupAddress, String dropAddress, double distanceKm, double payout
});




}
/// @nodoc
class _$DeliveryRecordCopyWithImpl<$Res>
    implements $DeliveryRecordCopyWith<$Res> {
  _$DeliveryRecordCopyWithImpl(this._self, this._then);

  final DeliveryRecord _self;
  final $Res Function(DeliveryRecord) _then;

/// Create a copy of DeliveryRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? deliveredAt = null,Object? pickupAddress = null,Object? dropAddress = null,Object? distanceKm = null,Object? payout = null,}) {
  return _then(_self.copyWith(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,deliveredAt: null == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,dropAddress: null == dropAddress ? _self.dropAddress : dropAddress // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,payout: null == payout ? _self.payout : payout // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryRecord].
extension DeliveryRecordPatterns on DeliveryRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryRecord value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryRecord value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderId,  DateTime deliveredAt,  String pickupAddress,  String dropAddress,  double distanceKm,  double payout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryRecord() when $default != null:
return $default(_that.orderId,_that.deliveredAt,_that.pickupAddress,_that.dropAddress,_that.distanceKm,_that.payout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderId,  DateTime deliveredAt,  String pickupAddress,  String dropAddress,  double distanceKm,  double payout)  $default,) {final _that = this;
switch (_that) {
case _DeliveryRecord():
return $default(_that.orderId,_that.deliveredAt,_that.pickupAddress,_that.dropAddress,_that.distanceKm,_that.payout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderId,  DateTime deliveredAt,  String pickupAddress,  String dropAddress,  double distanceKm,  double payout)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryRecord() when $default != null:
return $default(_that.orderId,_that.deliveredAt,_that.pickupAddress,_that.dropAddress,_that.distanceKm,_that.payout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryRecord implements DeliveryRecord {
  const _DeliveryRecord({required this.orderId, required this.deliveredAt, required this.pickupAddress, required this.dropAddress, required this.distanceKm, required this.payout});
  factory _DeliveryRecord.fromJson(Map<String, dynamic> json) => _$DeliveryRecordFromJson(json);

@override final  String orderId;
@override final  DateTime deliveredAt;
@override final  String pickupAddress;
@override final  String dropAddress;
@override final  double distanceKm;
@override final  double payout;

/// Create a copy of DeliveryRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryRecordCopyWith<_DeliveryRecord> get copyWith => __$DeliveryRecordCopyWithImpl<_DeliveryRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryRecord&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.dropAddress, dropAddress) || other.dropAddress == dropAddress)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.payout, payout) || other.payout == payout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,deliveredAt,pickupAddress,dropAddress,distanceKm,payout);

@override
String toString() {
  return 'DeliveryRecord(orderId: $orderId, deliveredAt: $deliveredAt, pickupAddress: $pickupAddress, dropAddress: $dropAddress, distanceKm: $distanceKm, payout: $payout)';
}


}

/// @nodoc
abstract mixin class _$DeliveryRecordCopyWith<$Res> implements $DeliveryRecordCopyWith<$Res> {
  factory _$DeliveryRecordCopyWith(_DeliveryRecord value, $Res Function(_DeliveryRecord) _then) = __$DeliveryRecordCopyWithImpl;
@override @useResult
$Res call({
 String orderId, DateTime deliveredAt, String pickupAddress, String dropAddress, double distanceKm, double payout
});




}
/// @nodoc
class __$DeliveryRecordCopyWithImpl<$Res>
    implements _$DeliveryRecordCopyWith<$Res> {
  __$DeliveryRecordCopyWithImpl(this._self, this._then);

  final _DeliveryRecord _self;
  final $Res Function(_DeliveryRecord) _then;

/// Create a copy of DeliveryRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? deliveredAt = null,Object? pickupAddress = null,Object? dropAddress = null,Object? distanceKm = null,Object? payout = null,}) {
  return _then(_DeliveryRecord(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,deliveredAt: null == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,dropAddress: null == dropAddress ? _self.dropAddress : dropAddress // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,payout: null == payout ? _self.payout : payout // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
