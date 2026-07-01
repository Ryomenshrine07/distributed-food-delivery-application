// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderDto {

 String get id; String? get customerId; String? get customerName; String? get customerPhone; String? get customerEmail; String? get deliveryPartnerId; String? get deliveryPartnerName; String? get deliveryPartnerPhone; String get restaurantId; DeliveryLocationDto get deliveryLocation;@DecimalJsonConverter() Decimal get subtotal;@DecimalJsonConverter() Decimal get deliveryFee;@DecimalJsonConverter() Decimal get tax;@DecimalJsonConverter() Decimal get totalAmount;@OrderStatusConverter() OrderStatus get status; List<OrderItemDto> get items; String get createdAt;
/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDtoCopyWith<OrderDto> get copyWith => _$OrderDtoCopyWithImpl<OrderDto>(this as OrderDto, _$identity);

  /// Serializes this OrderDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.deliveryPartnerId, deliveryPartnerId) || other.deliveryPartnerId == deliveryPartnerId)&&(identical(other.deliveryPartnerName, deliveryPartnerName) || other.deliveryPartnerName == deliveryPartnerName)&&(identical(other.deliveryPartnerPhone, deliveryPartnerPhone) || other.deliveryPartnerPhone == deliveryPartnerPhone)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.deliveryLocation, deliveryLocation) || other.deliveryLocation == deliveryLocation)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerName,customerPhone,customerEmail,deliveryPartnerId,deliveryPartnerName,deliveryPartnerPhone,restaurantId,deliveryLocation,subtotal,deliveryFee,tax,totalAmount,status,const DeepCollectionEquality().hash(items),createdAt);

@override
String toString() {
  return 'OrderDto(id: $id, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, deliveryPartnerId: $deliveryPartnerId, deliveryPartnerName: $deliveryPartnerName, deliveryPartnerPhone: $deliveryPartnerPhone, restaurantId: $restaurantId, deliveryLocation: $deliveryLocation, subtotal: $subtotal, deliveryFee: $deliveryFee, tax: $tax, totalAmount: $totalAmount, status: $status, items: $items, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderDtoCopyWith<$Res>  {
  factory $OrderDtoCopyWith(OrderDto value, $Res Function(OrderDto) _then) = _$OrderDtoCopyWithImpl;
@useResult
$Res call({
 String id, String? customerId, String? customerName, String? customerPhone, String? customerEmail, String? deliveryPartnerId, String? deliveryPartnerName, String? deliveryPartnerPhone, String restaurantId, DeliveryLocationDto deliveryLocation,@DecimalJsonConverter() Decimal subtotal,@DecimalJsonConverter() Decimal deliveryFee,@DecimalJsonConverter() Decimal tax,@DecimalJsonConverter() Decimal totalAmount,@OrderStatusConverter() OrderStatus status, List<OrderItemDto> items, String createdAt
});


$DeliveryLocationDtoCopyWith<$Res> get deliveryLocation;

}
/// @nodoc
class _$OrderDtoCopyWithImpl<$Res>
    implements $OrderDtoCopyWith<$Res> {
  _$OrderDtoCopyWithImpl(this._self, this._then);

  final OrderDto _self;
  final $Res Function(OrderDto) _then;

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerId = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? customerEmail = freezed,Object? deliveryPartnerId = freezed,Object? deliveryPartnerName = freezed,Object? deliveryPartnerPhone = freezed,Object? restaurantId = null,Object? deliveryLocation = null,Object? subtotal = null,Object? deliveryFee = null,Object? tax = null,Object? totalAmount = null,Object? status = null,Object? items = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,deliveryPartnerId: freezed == deliveryPartnerId ? _self.deliveryPartnerId : deliveryPartnerId // ignore: cast_nullable_to_non_nullable
as String?,deliveryPartnerName: freezed == deliveryPartnerName ? _self.deliveryPartnerName : deliveryPartnerName // ignore: cast_nullable_to_non_nullable
as String?,deliveryPartnerPhone: freezed == deliveryPartnerPhone ? _self.deliveryPartnerPhone : deliveryPartnerPhone // ignore: cast_nullable_to_non_nullable
as String?,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,deliveryLocation: null == deliveryLocation ? _self.deliveryLocation : deliveryLocation // ignore: cast_nullable_to_non_nullable
as DeliveryLocationDto,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Decimal,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Decimal,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemDto>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeliveryLocationDtoCopyWith<$Res> get deliveryLocation {
  
  return $DeliveryLocationDtoCopyWith<$Res>(_self.deliveryLocation, (value) {
    return _then(_self.copyWith(deliveryLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderDto].
extension OrderDtoPatterns on OrderDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? customerId,  String? customerName,  String? customerPhone,  String? customerEmail,  String? deliveryPartnerId,  String? deliveryPartnerName,  String? deliveryPartnerPhone,  String restaurantId,  DeliveryLocationDto deliveryLocation, @DecimalJsonConverter()  Decimal subtotal, @DecimalJsonConverter()  Decimal deliveryFee, @DecimalJsonConverter()  Decimal tax, @DecimalJsonConverter()  Decimal totalAmount, @OrderStatusConverter()  OrderStatus status,  List<OrderItemDto> items,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
return $default(_that.id,_that.customerId,_that.customerName,_that.customerPhone,_that.customerEmail,_that.deliveryPartnerId,_that.deliveryPartnerName,_that.deliveryPartnerPhone,_that.restaurantId,_that.deliveryLocation,_that.subtotal,_that.deliveryFee,_that.tax,_that.totalAmount,_that.status,_that.items,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? customerId,  String? customerName,  String? customerPhone,  String? customerEmail,  String? deliveryPartnerId,  String? deliveryPartnerName,  String? deliveryPartnerPhone,  String restaurantId,  DeliveryLocationDto deliveryLocation, @DecimalJsonConverter()  Decimal subtotal, @DecimalJsonConverter()  Decimal deliveryFee, @DecimalJsonConverter()  Decimal tax, @DecimalJsonConverter()  Decimal totalAmount, @OrderStatusConverter()  OrderStatus status,  List<OrderItemDto> items,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderDto():
return $default(_that.id,_that.customerId,_that.customerName,_that.customerPhone,_that.customerEmail,_that.deliveryPartnerId,_that.deliveryPartnerName,_that.deliveryPartnerPhone,_that.restaurantId,_that.deliveryLocation,_that.subtotal,_that.deliveryFee,_that.tax,_that.totalAmount,_that.status,_that.items,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? customerId,  String? customerName,  String? customerPhone,  String? customerEmail,  String? deliveryPartnerId,  String? deliveryPartnerName,  String? deliveryPartnerPhone,  String restaurantId,  DeliveryLocationDto deliveryLocation, @DecimalJsonConverter()  Decimal subtotal, @DecimalJsonConverter()  Decimal deliveryFee, @DecimalJsonConverter()  Decimal tax, @DecimalJsonConverter()  Decimal totalAmount, @OrderStatusConverter()  OrderStatus status,  List<OrderItemDto> items,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
return $default(_that.id,_that.customerId,_that.customerName,_that.customerPhone,_that.customerEmail,_that.deliveryPartnerId,_that.deliveryPartnerName,_that.deliveryPartnerPhone,_that.restaurantId,_that.deliveryLocation,_that.subtotal,_that.deliveryFee,_that.tax,_that.totalAmount,_that.status,_that.items,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderDto implements OrderDto {
  const _OrderDto({required this.id, this.customerId, this.customerName, this.customerPhone, this.customerEmail, this.deliveryPartnerId, this.deliveryPartnerName, this.deliveryPartnerPhone, required this.restaurantId, required this.deliveryLocation, @DecimalJsonConverter() required this.subtotal, @DecimalJsonConverter() required this.deliveryFee, @DecimalJsonConverter() required this.tax, @DecimalJsonConverter() required this.totalAmount, @OrderStatusConverter() required this.status, required final  List<OrderItemDto> items, required this.createdAt}): _items = items;
  factory _OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);

@override final  String id;
@override final  String? customerId;
@override final  String? customerName;
@override final  String? customerPhone;
@override final  String? customerEmail;
@override final  String? deliveryPartnerId;
@override final  String? deliveryPartnerName;
@override final  String? deliveryPartnerPhone;
@override final  String restaurantId;
@override final  DeliveryLocationDto deliveryLocation;
@override@DecimalJsonConverter() final  Decimal subtotal;
@override@DecimalJsonConverter() final  Decimal deliveryFee;
@override@DecimalJsonConverter() final  Decimal tax;
@override@DecimalJsonConverter() final  Decimal totalAmount;
@override@OrderStatusConverter() final  OrderStatus status;
 final  List<OrderItemDto> _items;
@override List<OrderItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String createdAt;

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDtoCopyWith<_OrderDto> get copyWith => __$OrderDtoCopyWithImpl<_OrderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.customerEmail, customerEmail) || other.customerEmail == customerEmail)&&(identical(other.deliveryPartnerId, deliveryPartnerId) || other.deliveryPartnerId == deliveryPartnerId)&&(identical(other.deliveryPartnerName, deliveryPartnerName) || other.deliveryPartnerName == deliveryPartnerName)&&(identical(other.deliveryPartnerPhone, deliveryPartnerPhone) || other.deliveryPartnerPhone == deliveryPartnerPhone)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.deliveryLocation, deliveryLocation) || other.deliveryLocation == deliveryLocation)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,customerId,customerName,customerPhone,customerEmail,deliveryPartnerId,deliveryPartnerName,deliveryPartnerPhone,restaurantId,deliveryLocation,subtotal,deliveryFee,tax,totalAmount,status,const DeepCollectionEquality().hash(_items),createdAt);

@override
String toString() {
  return 'OrderDto(id: $id, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, deliveryPartnerId: $deliveryPartnerId, deliveryPartnerName: $deliveryPartnerName, deliveryPartnerPhone: $deliveryPartnerPhone, restaurantId: $restaurantId, deliveryLocation: $deliveryLocation, subtotal: $subtotal, deliveryFee: $deliveryFee, tax: $tax, totalAmount: $totalAmount, status: $status, items: $items, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderDtoCopyWith<$Res> implements $OrderDtoCopyWith<$Res> {
  factory _$OrderDtoCopyWith(_OrderDto value, $Res Function(_OrderDto) _then) = __$OrderDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? customerId, String? customerName, String? customerPhone, String? customerEmail, String? deliveryPartnerId, String? deliveryPartnerName, String? deliveryPartnerPhone, String restaurantId, DeliveryLocationDto deliveryLocation,@DecimalJsonConverter() Decimal subtotal,@DecimalJsonConverter() Decimal deliveryFee,@DecimalJsonConverter() Decimal tax,@DecimalJsonConverter() Decimal totalAmount,@OrderStatusConverter() OrderStatus status, List<OrderItemDto> items, String createdAt
});


@override $DeliveryLocationDtoCopyWith<$Res> get deliveryLocation;

}
/// @nodoc
class __$OrderDtoCopyWithImpl<$Res>
    implements _$OrderDtoCopyWith<$Res> {
  __$OrderDtoCopyWithImpl(this._self, this._then);

  final _OrderDto _self;
  final $Res Function(_OrderDto) _then;

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerId = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? customerEmail = freezed,Object? deliveryPartnerId = freezed,Object? deliveryPartnerName = freezed,Object? deliveryPartnerPhone = freezed,Object? restaurantId = null,Object? deliveryLocation = null,Object? subtotal = null,Object? deliveryFee = null,Object? tax = null,Object? totalAmount = null,Object? status = null,Object? items = null,Object? createdAt = null,}) {
  return _then(_OrderDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,customerEmail: freezed == customerEmail ? _self.customerEmail : customerEmail // ignore: cast_nullable_to_non_nullable
as String?,deliveryPartnerId: freezed == deliveryPartnerId ? _self.deliveryPartnerId : deliveryPartnerId // ignore: cast_nullable_to_non_nullable
as String?,deliveryPartnerName: freezed == deliveryPartnerName ? _self.deliveryPartnerName : deliveryPartnerName // ignore: cast_nullable_to_non_nullable
as String?,deliveryPartnerPhone: freezed == deliveryPartnerPhone ? _self.deliveryPartnerPhone : deliveryPartnerPhone // ignore: cast_nullable_to_non_nullable
as String?,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String,deliveryLocation: null == deliveryLocation ? _self.deliveryLocation : deliveryLocation // ignore: cast_nullable_to_non_nullable
as DeliveryLocationDto,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as Decimal,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as Decimal,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as Decimal,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as Decimal,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemDto>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of OrderDto
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
