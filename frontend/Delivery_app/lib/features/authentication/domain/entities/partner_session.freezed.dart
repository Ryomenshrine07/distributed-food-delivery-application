// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PartnerSession {

 String get partnerId; String get email; String get role; String get name; String get phone; DateTime get exp;
/// Create a copy of PartnerSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerSessionCopyWith<PartnerSession> get copyWith => _$PartnerSessionCopyWithImpl<PartnerSession>(this as PartnerSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerSession&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.exp, exp) || other.exp == exp));
}


@override
int get hashCode => Object.hash(runtimeType,partnerId,email,role,name,phone,exp);

@override
String toString() {
  return 'PartnerSession(partnerId: $partnerId, email: $email, role: $role, name: $name, phone: $phone, exp: $exp)';
}


}

/// @nodoc
abstract mixin class $PartnerSessionCopyWith<$Res>  {
  factory $PartnerSessionCopyWith(PartnerSession value, $Res Function(PartnerSession) _then) = _$PartnerSessionCopyWithImpl;
@useResult
$Res call({
 String partnerId, String email, String role, String name, String phone, DateTime exp
});




}
/// @nodoc
class _$PartnerSessionCopyWithImpl<$Res>
    implements $PartnerSessionCopyWith<$Res> {
  _$PartnerSessionCopyWithImpl(this._self, this._then);

  final PartnerSession _self;
  final $Res Function(PartnerSession) _then;

/// Create a copy of PartnerSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partnerId = null,Object? email = null,Object? role = null,Object? name = null,Object? phone = null,Object? exp = null,}) {
  return _then(_self.copyWith(
partnerId: null == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,exp: null == exp ? _self.exp : exp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerSession].
extension PartnerSessionPatterns on PartnerSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerSession value)  $default,){
final _that = this;
switch (_that) {
case _PartnerSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerSession value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String partnerId,  String email,  String role,  String name,  String phone,  DateTime exp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerSession() when $default != null:
return $default(_that.partnerId,_that.email,_that.role,_that.name,_that.phone,_that.exp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String partnerId,  String email,  String role,  String name,  String phone,  DateTime exp)  $default,) {final _that = this;
switch (_that) {
case _PartnerSession():
return $default(_that.partnerId,_that.email,_that.role,_that.name,_that.phone,_that.exp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String partnerId,  String email,  String role,  String name,  String phone,  DateTime exp)?  $default,) {final _that = this;
switch (_that) {
case _PartnerSession() when $default != null:
return $default(_that.partnerId,_that.email,_that.role,_that.name,_that.phone,_that.exp);case _:
  return null;

}
}

}

/// @nodoc


class _PartnerSession extends PartnerSession {
  const _PartnerSession({required this.partnerId, required this.email, required this.role, required this.name, required this.phone, required this.exp}): super._();
  

@override final  String partnerId;
@override final  String email;
@override final  String role;
@override final  String name;
@override final  String phone;
@override final  DateTime exp;

/// Create a copy of PartnerSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerSessionCopyWith<_PartnerSession> get copyWith => __$PartnerSessionCopyWithImpl<_PartnerSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerSession&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.exp, exp) || other.exp == exp));
}


@override
int get hashCode => Object.hash(runtimeType,partnerId,email,role,name,phone,exp);

@override
String toString() {
  return 'PartnerSession(partnerId: $partnerId, email: $email, role: $role, name: $name, phone: $phone, exp: $exp)';
}


}

/// @nodoc
abstract mixin class _$PartnerSessionCopyWith<$Res> implements $PartnerSessionCopyWith<$Res> {
  factory _$PartnerSessionCopyWith(_PartnerSession value, $Res Function(_PartnerSession) _then) = __$PartnerSessionCopyWithImpl;
@override @useResult
$Res call({
 String partnerId, String email, String role, String name, String phone, DateTime exp
});




}
/// @nodoc
class __$PartnerSessionCopyWithImpl<$Res>
    implements _$PartnerSessionCopyWith<$Res> {
  __$PartnerSessionCopyWithImpl(this._self, this._then);

  final _PartnerSession _self;
  final $Res Function(_PartnerSession) _then;

/// Create a copy of PartnerSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partnerId = null,Object? email = null,Object? role = null,Object? name = null,Object? phone = null,Object? exp = null,}) {
  return _then(_PartnerSession(
partnerId: null == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,exp: null == exp ? _self.exp : exp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
