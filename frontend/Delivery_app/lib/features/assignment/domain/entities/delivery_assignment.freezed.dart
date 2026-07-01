// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryAssignment {

 String get id; String get orderId; String get restaurantName; String get restaurantAddress; double get restaurantLatitude; double get restaurantLongitude; String get customerName; String get customerAddress; double get customerLatitude; double get customerLongitude; String? get customerPhone; int get itemCount; DeliveryStatus get status; DateTime? get assignedAt; DateTime? get pickedUpAt; DateTime? get deliveredAt;
/// Create a copy of DeliveryAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryAssignmentCopyWith<DeliveryAssignment> get copyWith => _$DeliveryAssignmentCopyWithImpl<DeliveryAssignment>(this as DeliveryAssignment, _$identity);

  /// Serializes this DeliveryAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&(identical(other.restaurantAddress, restaurantAddress) || other.restaurantAddress == restaurantAddress)&&(identical(other.restaurantLatitude, restaurantLatitude) || other.restaurantLatitude == restaurantLatitude)&&(identical(other.restaurantLongitude, restaurantLongitude) || other.restaurantLongitude == restaurantLongitude)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerAddress, customerAddress) || other.customerAddress == customerAddress)&&(identical(other.customerLatitude, customerLatitude) || other.customerLatitude == customerLatitude)&&(identical(other.customerLongitude, customerLongitude) || other.customerLongitude == customerLongitude)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.pickedUpAt, pickedUpAt) || other.pickedUpAt == pickedUpAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,restaurantName,restaurantAddress,restaurantLatitude,restaurantLongitude,customerName,customerAddress,customerLatitude,customerLongitude,customerPhone,itemCount,status,assignedAt,pickedUpAt,deliveredAt);

@override
String toString() {
  return 'DeliveryAssignment(id: $id, orderId: $orderId, restaurantName: $restaurantName, restaurantAddress: $restaurantAddress, restaurantLatitude: $restaurantLatitude, restaurantLongitude: $restaurantLongitude, customerName: $customerName, customerAddress: $customerAddress, customerLatitude: $customerLatitude, customerLongitude: $customerLongitude, customerPhone: $customerPhone, itemCount: $itemCount, status: $status, assignedAt: $assignedAt, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryAssignmentCopyWith<$Res>  {
  factory $DeliveryAssignmentCopyWith(DeliveryAssignment value, $Res Function(DeliveryAssignment) _then) = _$DeliveryAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String orderId, String restaurantName, String restaurantAddress, double restaurantLatitude, double restaurantLongitude, String customerName, String customerAddress, double customerLatitude, double customerLongitude, String? customerPhone, int itemCount, DeliveryStatus status, DateTime? assignedAt, DateTime? pickedUpAt, DateTime? deliveredAt
});




}
/// @nodoc
class _$DeliveryAssignmentCopyWithImpl<$Res>
    implements $DeliveryAssignmentCopyWith<$Res> {
  _$DeliveryAssignmentCopyWithImpl(this._self, this._then);

  final DeliveryAssignment _self;
  final $Res Function(DeliveryAssignment) _then;

/// Create a copy of DeliveryAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? restaurantName = null,Object? restaurantAddress = null,Object? restaurantLatitude = null,Object? restaurantLongitude = null,Object? customerName = null,Object? customerAddress = null,Object? customerLatitude = null,Object? customerLongitude = null,Object? customerPhone = freezed,Object? itemCount = null,Object? status = null,Object? assignedAt = freezed,Object? pickedUpAt = freezed,Object? deliveredAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,restaurantName: null == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String,restaurantAddress: null == restaurantAddress ? _self.restaurantAddress : restaurantAddress // ignore: cast_nullable_to_non_nullable
as String,restaurantLatitude: null == restaurantLatitude ? _self.restaurantLatitude : restaurantLatitude // ignore: cast_nullable_to_non_nullable
as double,restaurantLongitude: null == restaurantLongitude ? _self.restaurantLongitude : restaurantLongitude // ignore: cast_nullable_to_non_nullable
as double,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerAddress: null == customerAddress ? _self.customerAddress : customerAddress // ignore: cast_nullable_to_non_nullable
as String,customerLatitude: null == customerLatitude ? _self.customerLatitude : customerLatitude // ignore: cast_nullable_to_non_nullable
as double,customerLongitude: null == customerLongitude ? _self.customerLongitude : customerLongitude // ignore: cast_nullable_to_non_nullable
as double,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pickedUpAt: freezed == pickedUpAt ? _self.pickedUpAt : pickedUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryAssignment].
extension DeliveryAssignmentPatterns on DeliveryAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryAssignment value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderId,  String restaurantName,  String restaurantAddress,  double restaurantLatitude,  double restaurantLongitude,  String customerName,  String customerAddress,  double customerLatitude,  double customerLongitude,  String? customerPhone,  int itemCount,  DeliveryStatus status,  DateTime? assignedAt,  DateTime? pickedUpAt,  DateTime? deliveredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryAssignment() when $default != null:
return $default(_that.id,_that.orderId,_that.restaurantName,_that.restaurantAddress,_that.restaurantLatitude,_that.restaurantLongitude,_that.customerName,_that.customerAddress,_that.customerLatitude,_that.customerLongitude,_that.customerPhone,_that.itemCount,_that.status,_that.assignedAt,_that.pickedUpAt,_that.deliveredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderId,  String restaurantName,  String restaurantAddress,  double restaurantLatitude,  double restaurantLongitude,  String customerName,  String customerAddress,  double customerLatitude,  double customerLongitude,  String? customerPhone,  int itemCount,  DeliveryStatus status,  DateTime? assignedAt,  DateTime? pickedUpAt,  DateTime? deliveredAt)  $default,) {final _that = this;
switch (_that) {
case _DeliveryAssignment():
return $default(_that.id,_that.orderId,_that.restaurantName,_that.restaurantAddress,_that.restaurantLatitude,_that.restaurantLongitude,_that.customerName,_that.customerAddress,_that.customerLatitude,_that.customerLongitude,_that.customerPhone,_that.itemCount,_that.status,_that.assignedAt,_that.pickedUpAt,_that.deliveredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderId,  String restaurantName,  String restaurantAddress,  double restaurantLatitude,  double restaurantLongitude,  String customerName,  String customerAddress,  double customerLatitude,  double customerLongitude,  String? customerPhone,  int itemCount,  DeliveryStatus status,  DateTime? assignedAt,  DateTime? pickedUpAt,  DateTime? deliveredAt)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryAssignment() when $default != null:
return $default(_that.id,_that.orderId,_that.restaurantName,_that.restaurantAddress,_that.restaurantLatitude,_that.restaurantLongitude,_that.customerName,_that.customerAddress,_that.customerLatitude,_that.customerLongitude,_that.customerPhone,_that.itemCount,_that.status,_that.assignedAt,_that.pickedUpAt,_that.deliveredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryAssignment implements DeliveryAssignment {
  const _DeliveryAssignment({required this.id, required this.orderId, this.restaurantName = 'Unknown Restaurant', this.restaurantAddress = 'Unknown Address', required this.restaurantLatitude, required this.restaurantLongitude, this.customerName = 'Unknown Customer', this.customerAddress = 'Unknown Address', this.customerLatitude = 0.0, this.customerLongitude = 0.0, this.customerPhone, this.itemCount = 0, required this.status, this.assignedAt, this.pickedUpAt, this.deliveredAt});
  factory _DeliveryAssignment.fromJson(Map<String, dynamic> json) => _$DeliveryAssignmentFromJson(json);

@override final  String id;
@override final  String orderId;
@override@JsonKey() final  String restaurantName;
@override@JsonKey() final  String restaurantAddress;
@override final  double restaurantLatitude;
@override final  double restaurantLongitude;
@override@JsonKey() final  String customerName;
@override@JsonKey() final  String customerAddress;
@override@JsonKey() final  double customerLatitude;
@override@JsonKey() final  double customerLongitude;
@override final  String? customerPhone;
@override@JsonKey() final  int itemCount;
@override final  DeliveryStatus status;
@override final  DateTime? assignedAt;
@override final  DateTime? pickedUpAt;
@override final  DateTime? deliveredAt;

/// Create a copy of DeliveryAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryAssignmentCopyWith<_DeliveryAssignment> get copyWith => __$DeliveryAssignmentCopyWithImpl<_DeliveryAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&(identical(other.restaurantAddress, restaurantAddress) || other.restaurantAddress == restaurantAddress)&&(identical(other.restaurantLatitude, restaurantLatitude) || other.restaurantLatitude == restaurantLatitude)&&(identical(other.restaurantLongitude, restaurantLongitude) || other.restaurantLongitude == restaurantLongitude)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerAddress, customerAddress) || other.customerAddress == customerAddress)&&(identical(other.customerLatitude, customerLatitude) || other.customerLatitude == customerLatitude)&&(identical(other.customerLongitude, customerLongitude) || other.customerLongitude == customerLongitude)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedAt, assignedAt) || other.assignedAt == assignedAt)&&(identical(other.pickedUpAt, pickedUpAt) || other.pickedUpAt == pickedUpAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,restaurantName,restaurantAddress,restaurantLatitude,restaurantLongitude,customerName,customerAddress,customerLatitude,customerLongitude,customerPhone,itemCount,status,assignedAt,pickedUpAt,deliveredAt);

@override
String toString() {
  return 'DeliveryAssignment(id: $id, orderId: $orderId, restaurantName: $restaurantName, restaurantAddress: $restaurantAddress, restaurantLatitude: $restaurantLatitude, restaurantLongitude: $restaurantLongitude, customerName: $customerName, customerAddress: $customerAddress, customerLatitude: $customerLatitude, customerLongitude: $customerLongitude, customerPhone: $customerPhone, itemCount: $itemCount, status: $status, assignedAt: $assignedAt, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryAssignmentCopyWith<$Res> implements $DeliveryAssignmentCopyWith<$Res> {
  factory _$DeliveryAssignmentCopyWith(_DeliveryAssignment value, $Res Function(_DeliveryAssignment) _then) = __$DeliveryAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderId, String restaurantName, String restaurantAddress, double restaurantLatitude, double restaurantLongitude, String customerName, String customerAddress, double customerLatitude, double customerLongitude, String? customerPhone, int itemCount, DeliveryStatus status, DateTime? assignedAt, DateTime? pickedUpAt, DateTime? deliveredAt
});




}
/// @nodoc
class __$DeliveryAssignmentCopyWithImpl<$Res>
    implements _$DeliveryAssignmentCopyWith<$Res> {
  __$DeliveryAssignmentCopyWithImpl(this._self, this._then);

  final _DeliveryAssignment _self;
  final $Res Function(_DeliveryAssignment) _then;

/// Create a copy of DeliveryAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? restaurantName = null,Object? restaurantAddress = null,Object? restaurantLatitude = null,Object? restaurantLongitude = null,Object? customerName = null,Object? customerAddress = null,Object? customerLatitude = null,Object? customerLongitude = null,Object? customerPhone = freezed,Object? itemCount = null,Object? status = null,Object? assignedAt = freezed,Object? pickedUpAt = freezed,Object? deliveredAt = freezed,}) {
  return _then(_DeliveryAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,restaurantName: null == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String,restaurantAddress: null == restaurantAddress ? _self.restaurantAddress : restaurantAddress // ignore: cast_nullable_to_non_nullable
as String,restaurantLatitude: null == restaurantLatitude ? _self.restaurantLatitude : restaurantLatitude // ignore: cast_nullable_to_non_nullable
as double,restaurantLongitude: null == restaurantLongitude ? _self.restaurantLongitude : restaurantLongitude // ignore: cast_nullable_to_non_nullable
as double,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerAddress: null == customerAddress ? _self.customerAddress : customerAddress // ignore: cast_nullable_to_non_nullable
as String,customerLatitude: null == customerLatitude ? _self.customerLatitude : customerLatitude // ignore: cast_nullable_to_non_nullable
as double,customerLongitude: null == customerLongitude ? _self.customerLongitude : customerLongitude // ignore: cast_nullable_to_non_nullable
as double,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,assignedAt: freezed == assignedAt ? _self.assignedAt : assignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pickedUpAt: freezed == pickedUpAt ? _self.pickedUpAt : pickedUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
