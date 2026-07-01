// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RestaurantDto {

 String get id; String get name; String? get description; String? get address; String? get city; bool? get open; int? get averageDeliveryTime; double? get rating; String? get imageUrl; String? get logoUrl; String? get coverImageUrl; String? get cuisine; double? get latitude; double? get longitude; bool get active; String? get openingTime; String? get closingTime; String? get createdAt; String? get updatedAt; List<CategoryDto>? get categories;
/// Create a copy of RestaurantDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantDtoCopyWith<RestaurantDto> get copyWith => _$RestaurantDtoCopyWithImpl<RestaurantDto>(this as RestaurantDto, _$identity);

  /// Serializes this RestaurantDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.open, open) || other.open == open)&&(identical(other.averageDeliveryTime, averageDeliveryTime) || other.averageDeliveryTime == averageDeliveryTime)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.active, active) || other.active == active)&&(identical(other.openingTime, openingTime) || other.openingTime == openingTime)&&(identical(other.closingTime, closingTime) || other.closingTime == closingTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,address,city,open,averageDeliveryTime,rating,imageUrl,logoUrl,coverImageUrl,cuisine,latitude,longitude,active,openingTime,closingTime,createdAt,updatedAt,const DeepCollectionEquality().hash(categories)]);

@override
String toString() {
  return 'RestaurantDto(id: $id, name: $name, description: $description, address: $address, city: $city, open: $open, averageDeliveryTime: $averageDeliveryTime, rating: $rating, imageUrl: $imageUrl, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, cuisine: $cuisine, latitude: $latitude, longitude: $longitude, active: $active, openingTime: $openingTime, closingTime: $closingTime, createdAt: $createdAt, updatedAt: $updatedAt, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $RestaurantDtoCopyWith<$Res>  {
  factory $RestaurantDtoCopyWith(RestaurantDto value, $Res Function(RestaurantDto) _then) = _$RestaurantDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? address, String? city, bool? open, int? averageDeliveryTime, double? rating, String? imageUrl, String? logoUrl, String? coverImageUrl, String? cuisine, double? latitude, double? longitude, bool active, String? openingTime, String? closingTime, String? createdAt, String? updatedAt, List<CategoryDto>? categories
});




}
/// @nodoc
class _$RestaurantDtoCopyWithImpl<$Res>
    implements $RestaurantDtoCopyWith<$Res> {
  _$RestaurantDtoCopyWithImpl(this._self, this._then);

  final RestaurantDto _self;
  final $Res Function(RestaurantDto) _then;

/// Create a copy of RestaurantDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? address = freezed,Object? city = freezed,Object? open = freezed,Object? averageDeliveryTime = freezed,Object? rating = freezed,Object? imageUrl = freezed,Object? logoUrl = freezed,Object? coverImageUrl = freezed,Object? cuisine = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? active = null,Object? openingTime = freezed,Object? closingTime = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? categories = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool?,averageDeliveryTime: freezed == averageDeliveryTime ? _self.averageDeliveryTime : averageDeliveryTime // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,openingTime: freezed == openingTime ? _self.openingTime : openingTime // ignore: cast_nullable_to_non_nullable
as String?,closingTime: freezed == closingTime ? _self.closingTime : closingTime // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>?,
  ));
}

}


/// Adds pattern-matching-related methods to [RestaurantDto].
extension RestaurantDtoPatterns on RestaurantDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantDto value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantDto value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? address,  String? city,  bool? open,  int? averageDeliveryTime,  double? rating,  String? imageUrl,  String? logoUrl,  String? coverImageUrl,  String? cuisine,  double? latitude,  double? longitude,  bool active,  String? openingTime,  String? closingTime,  String? createdAt,  String? updatedAt,  List<CategoryDto>? categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.address,_that.city,_that.open,_that.averageDeliveryTime,_that.rating,_that.imageUrl,_that.logoUrl,_that.coverImageUrl,_that.cuisine,_that.latitude,_that.longitude,_that.active,_that.openingTime,_that.closingTime,_that.createdAt,_that.updatedAt,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? address,  String? city,  bool? open,  int? averageDeliveryTime,  double? rating,  String? imageUrl,  String? logoUrl,  String? coverImageUrl,  String? cuisine,  double? latitude,  double? longitude,  bool active,  String? openingTime,  String? closingTime,  String? createdAt,  String? updatedAt,  List<CategoryDto>? categories)  $default,) {final _that = this;
switch (_that) {
case _RestaurantDto():
return $default(_that.id,_that.name,_that.description,_that.address,_that.city,_that.open,_that.averageDeliveryTime,_that.rating,_that.imageUrl,_that.logoUrl,_that.coverImageUrl,_that.cuisine,_that.latitude,_that.longitude,_that.active,_that.openingTime,_that.closingTime,_that.createdAt,_that.updatedAt,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? address,  String? city,  bool? open,  int? averageDeliveryTime,  double? rating,  String? imageUrl,  String? logoUrl,  String? coverImageUrl,  String? cuisine,  double? latitude,  double? longitude,  bool active,  String? openingTime,  String? closingTime,  String? createdAt,  String? updatedAt,  List<CategoryDto>? categories)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.address,_that.city,_that.open,_that.averageDeliveryTime,_that.rating,_that.imageUrl,_that.logoUrl,_that.coverImageUrl,_that.cuisine,_that.latitude,_that.longitude,_that.active,_that.openingTime,_that.closingTime,_that.createdAt,_that.updatedAt,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RestaurantDto implements RestaurantDto {
  const _RestaurantDto({required this.id, required this.name, this.description, this.address, this.city, this.open, this.averageDeliveryTime, this.rating, this.imageUrl, this.logoUrl, this.coverImageUrl, this.cuisine, this.latitude, this.longitude, required this.active, this.openingTime, this.closingTime, this.createdAt, this.updatedAt, final  List<CategoryDto>? categories}): _categories = categories;
  factory _RestaurantDto.fromJson(Map<String, dynamic> json) => _$RestaurantDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? address;
@override final  String? city;
@override final  bool? open;
@override final  int? averageDeliveryTime;
@override final  double? rating;
@override final  String? imageUrl;
@override final  String? logoUrl;
@override final  String? coverImageUrl;
@override final  String? cuisine;
@override final  double? latitude;
@override final  double? longitude;
@override final  bool active;
@override final  String? openingTime;
@override final  String? closingTime;
@override final  String? createdAt;
@override final  String? updatedAt;
 final  List<CategoryDto>? _categories;
@override List<CategoryDto>? get categories {
  final value = _categories;
  if (value == null) return null;
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of RestaurantDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantDtoCopyWith<_RestaurantDto> get copyWith => __$RestaurantDtoCopyWithImpl<_RestaurantDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestaurantDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.open, open) || other.open == open)&&(identical(other.averageDeliveryTime, averageDeliveryTime) || other.averageDeliveryTime == averageDeliveryTime)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.active, active) || other.active == active)&&(identical(other.openingTime, openingTime) || other.openingTime == openingTime)&&(identical(other.closingTime, closingTime) || other.closingTime == closingTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,address,city,open,averageDeliveryTime,rating,imageUrl,logoUrl,coverImageUrl,cuisine,latitude,longitude,active,openingTime,closingTime,createdAt,updatedAt,const DeepCollectionEquality().hash(_categories)]);

@override
String toString() {
  return 'RestaurantDto(id: $id, name: $name, description: $description, address: $address, city: $city, open: $open, averageDeliveryTime: $averageDeliveryTime, rating: $rating, imageUrl: $imageUrl, logoUrl: $logoUrl, coverImageUrl: $coverImageUrl, cuisine: $cuisine, latitude: $latitude, longitude: $longitude, active: $active, openingTime: $openingTime, closingTime: $closingTime, createdAt: $createdAt, updatedAt: $updatedAt, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$RestaurantDtoCopyWith<$Res> implements $RestaurantDtoCopyWith<$Res> {
  factory _$RestaurantDtoCopyWith(_RestaurantDto value, $Res Function(_RestaurantDto) _then) = __$RestaurantDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? address, String? city, bool? open, int? averageDeliveryTime, double? rating, String? imageUrl, String? logoUrl, String? coverImageUrl, String? cuisine, double? latitude, double? longitude, bool active, String? openingTime, String? closingTime, String? createdAt, String? updatedAt, List<CategoryDto>? categories
});




}
/// @nodoc
class __$RestaurantDtoCopyWithImpl<$Res>
    implements _$RestaurantDtoCopyWith<$Res> {
  __$RestaurantDtoCopyWithImpl(this._self, this._then);

  final _RestaurantDto _self;
  final $Res Function(_RestaurantDto) _then;

/// Create a copy of RestaurantDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? address = freezed,Object? city = freezed,Object? open = freezed,Object? averageDeliveryTime = freezed,Object? rating = freezed,Object? imageUrl = freezed,Object? logoUrl = freezed,Object? coverImageUrl = freezed,Object? cuisine = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? active = null,Object? openingTime = freezed,Object? closingTime = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? categories = freezed,}) {
  return _then(_RestaurantDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as bool?,averageDeliveryTime: freezed == averageDeliveryTime ? _self.averageDeliveryTime : averageDeliveryTime // ignore: cast_nullable_to_non_nullable
as int?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,openingTime: freezed == openingTime ? _self.openingTime : openingTime // ignore: cast_nullable_to_non_nullable
as String?,closingTime: freezed == closingTime ? _self.closingTime : closingTime // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,categories: freezed == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryDto>?,
  ));
}


}

// dart format on
