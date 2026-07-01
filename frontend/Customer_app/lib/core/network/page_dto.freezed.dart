// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PageDto<T> {

 List<T> get content; int get number; int get size; int get totalElements; int get totalPages; bool get last; bool get first;
/// Create a copy of PageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageDtoCopyWith<T, PageDto<T>> get copyWith => _$PageDtoCopyWithImpl<T, PageDto<T>>(this as PageDto<T>, _$identity);

  /// Serializes this PageDto to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageDto<T>&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.number, number) || other.number == number)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalElements, totalElements) || other.totalElements == totalElements)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.last, last) || other.last == last)&&(identical(other.first, first) || other.first == first));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(content),number,size,totalElements,totalPages,last,first);

@override
String toString() {
  return 'PageDto<$T>(content: $content, number: $number, size: $size, totalElements: $totalElements, totalPages: $totalPages, last: $last, first: $first)';
}


}

/// @nodoc
abstract mixin class $PageDtoCopyWith<T,$Res>  {
  factory $PageDtoCopyWith(PageDto<T> value, $Res Function(PageDto<T>) _then) = _$PageDtoCopyWithImpl;
@useResult
$Res call({
 List<T> content, int number, int size, int totalElements, int totalPages, bool last, bool first
});




}
/// @nodoc
class _$PageDtoCopyWithImpl<T,$Res>
    implements $PageDtoCopyWith<T, $Res> {
  _$PageDtoCopyWithImpl(this._self, this._then);

  final PageDto<T> _self;
  final $Res Function(PageDto<T>) _then;

/// Create a copy of PageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? number = null,Object? size = null,Object? totalElements = null,Object? totalPages = null,Object? last = null,Object? first = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as List<T>,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalElements: null == totalElements ? _self.totalElements : totalElements // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,last: null == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as bool,first: null == first ? _self.first : first // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PageDto].
extension PageDtoPatterns<T> on PageDto<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageDto<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageDto<T> value)  $default,){
final _that = this;
switch (_that) {
case _PageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageDto<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> content,  int number,  int size,  int totalElements,  int totalPages,  bool last,  bool first)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageDto() when $default != null:
return $default(_that.content,_that.number,_that.size,_that.totalElements,_that.totalPages,_that.last,_that.first);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> content,  int number,  int size,  int totalElements,  int totalPages,  bool last,  bool first)  $default,) {final _that = this;
switch (_that) {
case _PageDto():
return $default(_that.content,_that.number,_that.size,_that.totalElements,_that.totalPages,_that.last,_that.first);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> content,  int number,  int size,  int totalElements,  int totalPages,  bool last,  bool first)?  $default,) {final _that = this;
switch (_that) {
case _PageDto() when $default != null:
return $default(_that.content,_that.number,_that.size,_that.totalElements,_that.totalPages,_that.last,_that.first);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _PageDto<T> implements PageDto<T> {
  const _PageDto({required final  List<T> content, required this.number, required this.size, required this.totalElements, required this.totalPages, required this.last, required this.first}): _content = content;
  factory _PageDto.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$PageDtoFromJson(json,fromJsonT);

 final  List<T> _content;
@override List<T> get content {
  if (_content is EqualUnmodifiableListView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_content);
}

@override final  int number;
@override final  int size;
@override final  int totalElements;
@override final  int totalPages;
@override final  bool last;
@override final  bool first;

/// Create a copy of PageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageDtoCopyWith<T, _PageDto<T>> get copyWith => __$PageDtoCopyWithImpl<T, _PageDto<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$PageDtoToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageDto<T>&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.number, number) || other.number == number)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalElements, totalElements) || other.totalElements == totalElements)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.last, last) || other.last == last)&&(identical(other.first, first) || other.first == first));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_content),number,size,totalElements,totalPages,last,first);

@override
String toString() {
  return 'PageDto<$T>(content: $content, number: $number, size: $size, totalElements: $totalElements, totalPages: $totalPages, last: $last, first: $first)';
}


}

/// @nodoc
abstract mixin class _$PageDtoCopyWith<T,$Res> implements $PageDtoCopyWith<T, $Res> {
  factory _$PageDtoCopyWith(_PageDto<T> value, $Res Function(_PageDto<T>) _then) = __$PageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<T> content, int number, int size, int totalElements, int totalPages, bool last, bool first
});




}
/// @nodoc
class __$PageDtoCopyWithImpl<T,$Res>
    implements _$PageDtoCopyWith<T, $Res> {
  __$PageDtoCopyWithImpl(this._self, this._then);

  final _PageDto<T> _self;
  final $Res Function(_PageDto<T>) _then;

/// Create a copy of PageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? number = null,Object? size = null,Object? totalElements = null,Object? totalPages = null,Object? last = null,Object? first = null,}) {
  return _then(_PageDto<T>(
content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as List<T>,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalElements: null == totalElements ? _self.totalElements : totalElements // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,last: null == last ? _self.last : last // ignore: cast_nullable_to_non_nullable
as bool,first: null == first ? _self.first : first // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
