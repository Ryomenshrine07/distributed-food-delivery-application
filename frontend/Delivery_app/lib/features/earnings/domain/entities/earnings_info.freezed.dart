// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EarningsInfo {

 double get totalEarnings; double get todayEarnings; double get weekEarnings; int get totalDeliveries; int get todayDeliveries; List<DeliveryRecord> get recentRecords;
/// Create a copy of EarningsInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsInfoCopyWith<EarningsInfo> get copyWith => _$EarningsInfoCopyWithImpl<EarningsInfo>(this as EarningsInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsInfo&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.todayEarnings, todayEarnings) || other.todayEarnings == todayEarnings)&&(identical(other.weekEarnings, weekEarnings) || other.weekEarnings == weekEarnings)&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries)&&(identical(other.todayDeliveries, todayDeliveries) || other.todayDeliveries == todayDeliveries)&&const DeepCollectionEquality().equals(other.recentRecords, recentRecords));
}


@override
int get hashCode => Object.hash(runtimeType,totalEarnings,todayEarnings,weekEarnings,totalDeliveries,todayDeliveries,const DeepCollectionEquality().hash(recentRecords));

@override
String toString() {
  return 'EarningsInfo(totalEarnings: $totalEarnings, todayEarnings: $todayEarnings, weekEarnings: $weekEarnings, totalDeliveries: $totalDeliveries, todayDeliveries: $todayDeliveries, recentRecords: $recentRecords)';
}


}

/// @nodoc
abstract mixin class $EarningsInfoCopyWith<$Res>  {
  factory $EarningsInfoCopyWith(EarningsInfo value, $Res Function(EarningsInfo) _then) = _$EarningsInfoCopyWithImpl;
@useResult
$Res call({
 double totalEarnings, double todayEarnings, double weekEarnings, int totalDeliveries, int todayDeliveries, List<DeliveryRecord> recentRecords
});




}
/// @nodoc
class _$EarningsInfoCopyWithImpl<$Res>
    implements $EarningsInfoCopyWith<$Res> {
  _$EarningsInfoCopyWithImpl(this._self, this._then);

  final EarningsInfo _self;
  final $Res Function(EarningsInfo) _then;

/// Create a copy of EarningsInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalEarnings = null,Object? todayEarnings = null,Object? weekEarnings = null,Object? totalDeliveries = null,Object? todayDeliveries = null,Object? recentRecords = null,}) {
  return _then(_self.copyWith(
totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,todayEarnings: null == todayEarnings ? _self.todayEarnings : todayEarnings // ignore: cast_nullable_to_non_nullable
as double,weekEarnings: null == weekEarnings ? _self.weekEarnings : weekEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as int,todayDeliveries: null == todayDeliveries ? _self.todayDeliveries : todayDeliveries // ignore: cast_nullable_to_non_nullable
as int,recentRecords: null == recentRecords ? _self.recentRecords : recentRecords // ignore: cast_nullable_to_non_nullable
as List<DeliveryRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsInfo].
extension EarningsInfoPatterns on EarningsInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsInfo value)  $default,){
final _that = this;
switch (_that) {
case _EarningsInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsInfo value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalEarnings,  double todayEarnings,  double weekEarnings,  int totalDeliveries,  int todayDeliveries,  List<DeliveryRecord> recentRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsInfo() when $default != null:
return $default(_that.totalEarnings,_that.todayEarnings,_that.weekEarnings,_that.totalDeliveries,_that.todayDeliveries,_that.recentRecords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalEarnings,  double todayEarnings,  double weekEarnings,  int totalDeliveries,  int todayDeliveries,  List<DeliveryRecord> recentRecords)  $default,) {final _that = this;
switch (_that) {
case _EarningsInfo():
return $default(_that.totalEarnings,_that.todayEarnings,_that.weekEarnings,_that.totalDeliveries,_that.todayDeliveries,_that.recentRecords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalEarnings,  double todayEarnings,  double weekEarnings,  int totalDeliveries,  int todayDeliveries,  List<DeliveryRecord> recentRecords)?  $default,) {final _that = this;
switch (_that) {
case _EarningsInfo() when $default != null:
return $default(_that.totalEarnings,_that.todayEarnings,_that.weekEarnings,_that.totalDeliveries,_that.todayDeliveries,_that.recentRecords);case _:
  return null;

}
}

}

/// @nodoc


class _EarningsInfo implements EarningsInfo {
  const _EarningsInfo({required this.totalEarnings, required this.todayEarnings, required this.weekEarnings, required this.totalDeliveries, required this.todayDeliveries, required final  List<DeliveryRecord> recentRecords}): _recentRecords = recentRecords;
  

@override final  double totalEarnings;
@override final  double todayEarnings;
@override final  double weekEarnings;
@override final  int totalDeliveries;
@override final  int todayDeliveries;
 final  List<DeliveryRecord> _recentRecords;
@override List<DeliveryRecord> get recentRecords {
  if (_recentRecords is EqualUnmodifiableListView) return _recentRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentRecords);
}


/// Create a copy of EarningsInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsInfoCopyWith<_EarningsInfo> get copyWith => __$EarningsInfoCopyWithImpl<_EarningsInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsInfo&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.todayEarnings, todayEarnings) || other.todayEarnings == todayEarnings)&&(identical(other.weekEarnings, weekEarnings) || other.weekEarnings == weekEarnings)&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries)&&(identical(other.todayDeliveries, todayDeliveries) || other.todayDeliveries == todayDeliveries)&&const DeepCollectionEquality().equals(other._recentRecords, _recentRecords));
}


@override
int get hashCode => Object.hash(runtimeType,totalEarnings,todayEarnings,weekEarnings,totalDeliveries,todayDeliveries,const DeepCollectionEquality().hash(_recentRecords));

@override
String toString() {
  return 'EarningsInfo(totalEarnings: $totalEarnings, todayEarnings: $todayEarnings, weekEarnings: $weekEarnings, totalDeliveries: $totalDeliveries, todayDeliveries: $todayDeliveries, recentRecords: $recentRecords)';
}


}

/// @nodoc
abstract mixin class _$EarningsInfoCopyWith<$Res> implements $EarningsInfoCopyWith<$Res> {
  factory _$EarningsInfoCopyWith(_EarningsInfo value, $Res Function(_EarningsInfo) _then) = __$EarningsInfoCopyWithImpl;
@override @useResult
$Res call({
 double totalEarnings, double todayEarnings, double weekEarnings, int totalDeliveries, int todayDeliveries, List<DeliveryRecord> recentRecords
});




}
/// @nodoc
class __$EarningsInfoCopyWithImpl<$Res>
    implements _$EarningsInfoCopyWith<$Res> {
  __$EarningsInfoCopyWithImpl(this._self, this._then);

  final _EarningsInfo _self;
  final $Res Function(_EarningsInfo) _then;

/// Create a copy of EarningsInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalEarnings = null,Object? todayEarnings = null,Object? weekEarnings = null,Object? totalDeliveries = null,Object? todayDeliveries = null,Object? recentRecords = null,}) {
  return _then(_EarningsInfo(
totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,todayEarnings: null == todayEarnings ? _self.todayEarnings : todayEarnings // ignore: cast_nullable_to_non_nullable
as double,weekEarnings: null == weekEarnings ? _self.weekEarnings : weekEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as int,todayDeliveries: null == todayDeliveries ? _self.todayDeliveries : todayDeliveries // ignore: cast_nullable_to_non_nullable
as int,recentRecords: null == recentRecords ? _self._recentRecords : recentRecords // ignore: cast_nullable_to_non_nullable
as List<DeliveryRecord>,
  ));
}


}

// dart format on
