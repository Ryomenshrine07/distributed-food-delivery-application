// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_confirmation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingConfirmation {

 String get id; String get orderId; ConfirmationType get type; DateTime get enqueuedAt; int get retryCount;
/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingConfirmationCopyWith<PendingConfirmation> get copyWith => _$PendingConfirmationCopyWithImpl<PendingConfirmation>(this as PendingConfirmation, _$identity);

  /// Serializes this PendingConfirmation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingConfirmation&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.type, type) || other.type == type)&&(identical(other.enqueuedAt, enqueuedAt) || other.enqueuedAt == enqueuedAt)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,type,enqueuedAt,retryCount);

@override
String toString() {
  return 'PendingConfirmation(id: $id, orderId: $orderId, type: $type, enqueuedAt: $enqueuedAt, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class $PendingConfirmationCopyWith<$Res>  {
  factory $PendingConfirmationCopyWith(PendingConfirmation value, $Res Function(PendingConfirmation) _then) = _$PendingConfirmationCopyWithImpl;
@useResult
$Res call({
 String id, String orderId, ConfirmationType type, DateTime enqueuedAt, int retryCount
});




}
/// @nodoc
class _$PendingConfirmationCopyWithImpl<$Res>
    implements $PendingConfirmationCopyWith<$Res> {
  _$PendingConfirmationCopyWithImpl(this._self, this._then);

  final PendingConfirmation _self;
  final $Res Function(PendingConfirmation) _then;

/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? type = null,Object? enqueuedAt = null,Object? retryCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfirmationType,enqueuedAt: null == enqueuedAt ? _self.enqueuedAt : enqueuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingConfirmation].
extension PendingConfirmationPatterns on PendingConfirmation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingConfirmation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingConfirmation value)  $default,){
final _that = this;
switch (_that) {
case _PendingConfirmation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingConfirmation value)?  $default,){
final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderId,  ConfirmationType type,  DateTime enqueuedAt,  int retryCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
return $default(_that.id,_that.orderId,_that.type,_that.enqueuedAt,_that.retryCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderId,  ConfirmationType type,  DateTime enqueuedAt,  int retryCount)  $default,) {final _that = this;
switch (_that) {
case _PendingConfirmation():
return $default(_that.id,_that.orderId,_that.type,_that.enqueuedAt,_that.retryCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderId,  ConfirmationType type,  DateTime enqueuedAt,  int retryCount)?  $default,) {final _that = this;
switch (_that) {
case _PendingConfirmation() when $default != null:
return $default(_that.id,_that.orderId,_that.type,_that.enqueuedAt,_that.retryCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingConfirmation implements PendingConfirmation {
  const _PendingConfirmation({required this.id, required this.orderId, required this.type, required this.enqueuedAt, this.retryCount = 0});
  factory _PendingConfirmation.fromJson(Map<String, dynamic> json) => _$PendingConfirmationFromJson(json);

@override final  String id;
@override final  String orderId;
@override final  ConfirmationType type;
@override final  DateTime enqueuedAt;
@override@JsonKey() final  int retryCount;

/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingConfirmationCopyWith<_PendingConfirmation> get copyWith => __$PendingConfirmationCopyWithImpl<_PendingConfirmation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingConfirmationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingConfirmation&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.type, type) || other.type == type)&&(identical(other.enqueuedAt, enqueuedAt) || other.enqueuedAt == enqueuedAt)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,orderId,type,enqueuedAt,retryCount);

@override
String toString() {
  return 'PendingConfirmation(id: $id, orderId: $orderId, type: $type, enqueuedAt: $enqueuedAt, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class _$PendingConfirmationCopyWith<$Res> implements $PendingConfirmationCopyWith<$Res> {
  factory _$PendingConfirmationCopyWith(_PendingConfirmation value, $Res Function(_PendingConfirmation) _then) = __$PendingConfirmationCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderId, ConfirmationType type, DateTime enqueuedAt, int retryCount
});




}
/// @nodoc
class __$PendingConfirmationCopyWithImpl<$Res>
    implements _$PendingConfirmationCopyWith<$Res> {
  __$PendingConfirmationCopyWithImpl(this._self, this._then);

  final _PendingConfirmation _self;
  final $Res Function(_PendingConfirmation) _then;

/// Create a copy of PendingConfirmation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? type = null,Object? enqueuedAt = null,Object? retryCount = null,}) {
  return _then(_PendingConfirmation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ConfirmationType,enqueuedAt: null == enqueuedAt ? _self.enqueuedAt : enqueuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
