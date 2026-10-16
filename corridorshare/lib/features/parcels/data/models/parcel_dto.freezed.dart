// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parcel_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParcelDto {

 String get id; String get senderId; String get senderName; String get title; String get fromDistrict; String get fromArea; String get toDistrict; String get toArea; List<String> get categoryTags; double get weightKg; String get size; String get deadline; double get offeredPrice; String get status; bool get hasProhibitedItemsDeclaration; String? get note; String get createdAt;
/// Create a copy of ParcelDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParcelDtoCopyWith<ParcelDto> get copyWith => _$ParcelDtoCopyWithImpl<ParcelDto>(this as ParcelDto, _$identity);

  /// Serializes this ParcelDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParcelDto&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.title, title) || other.title == title)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.fromArea, fromArea) || other.fromArea == fromArea)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.toArea, toArea) || other.toArea == toArea)&&const DeepCollectionEquality().equals(other.categoryTags, categoryTags)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.size, size) || other.size == size)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasProhibitedItemsDeclaration, hasProhibitedItemsDeclaration) || other.hasProhibitedItemsDeclaration == hasProhibitedItemsDeclaration)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderName,title,fromDistrict,fromArea,toDistrict,toArea,const DeepCollectionEquality().hash(categoryTags),weightKg,size,deadline,offeredPrice,status,hasProhibitedItemsDeclaration,note,createdAt);

@override
String toString() {
  return 'ParcelDto(id: $id, senderId: $senderId, senderName: $senderName, title: $title, fromDistrict: $fromDistrict, fromArea: $fromArea, toDistrict: $toDistrict, toArea: $toArea, categoryTags: $categoryTags, weightKg: $weightKg, size: $size, deadline: $deadline, offeredPrice: $offeredPrice, status: $status, hasProhibitedItemsDeclaration: $hasProhibitedItemsDeclaration, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ParcelDtoCopyWith<$Res>  {
  factory $ParcelDtoCopyWith(ParcelDto value, $Res Function(ParcelDto) _then) = _$ParcelDtoCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String senderName, String title, String fromDistrict, String fromArea, String toDistrict, String toArea, List<String> categoryTags, double weightKg, String size, String deadline, double offeredPrice, String status, bool hasProhibitedItemsDeclaration, String? note, String createdAt
});




}
/// @nodoc
class _$ParcelDtoCopyWithImpl<$Res>
    implements $ParcelDtoCopyWith<$Res> {
  _$ParcelDtoCopyWithImpl(this._self, this._then);

  final ParcelDto _self;
  final $Res Function(ParcelDto) _then;

/// Create a copy of ParcelDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? senderName = null,Object? title = null,Object? fromDistrict = null,Object? fromArea = null,Object? toDistrict = null,Object? toArea = null,Object? categoryTags = null,Object? weightKg = null,Object? size = null,Object? deadline = null,Object? offeredPrice = null,Object? status = null,Object? hasProhibitedItemsDeclaration = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,fromArea: null == fromArea ? _self.fromArea : fromArea // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,toArea: null == toArea ? _self.toArea : toArea // ignore: cast_nullable_to_non_nullable
as String,categoryTags: null == categoryTags ? _self.categoryTags : categoryTags // ignore: cast_nullable_to_non_nullable
as List<String>,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,hasProhibitedItemsDeclaration: null == hasProhibitedItemsDeclaration ? _self.hasProhibitedItemsDeclaration : hasProhibitedItemsDeclaration // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ParcelDto].
extension ParcelDtoPatterns on ParcelDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParcelDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParcelDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParcelDto value)  $default,){
final _that = this;
switch (_that) {
case _ParcelDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParcelDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParcelDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String senderName,  String title,  String fromDistrict,  String fromArea,  String toDistrict,  String toArea,  List<String> categoryTags,  double weightKg,  String size,  String deadline,  double offeredPrice,  String status,  bool hasProhibitedItemsDeclaration,  String? note,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParcelDto() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.title,_that.fromDistrict,_that.fromArea,_that.toDistrict,_that.toArea,_that.categoryTags,_that.weightKg,_that.size,_that.deadline,_that.offeredPrice,_that.status,_that.hasProhibitedItemsDeclaration,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String senderName,  String title,  String fromDistrict,  String fromArea,  String toDistrict,  String toArea,  List<String> categoryTags,  double weightKg,  String size,  String deadline,  double offeredPrice,  String status,  bool hasProhibitedItemsDeclaration,  String? note,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _ParcelDto():
return $default(_that.id,_that.senderId,_that.senderName,_that.title,_that.fromDistrict,_that.fromArea,_that.toDistrict,_that.toArea,_that.categoryTags,_that.weightKg,_that.size,_that.deadline,_that.offeredPrice,_that.status,_that.hasProhibitedItemsDeclaration,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String senderName,  String title,  String fromDistrict,  String fromArea,  String toDistrict,  String toArea,  List<String> categoryTags,  double weightKg,  String size,  String deadline,  double offeredPrice,  String status,  bool hasProhibitedItemsDeclaration,  String? note,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ParcelDto() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.title,_that.fromDistrict,_that.fromArea,_that.toDistrict,_that.toArea,_that.categoryTags,_that.weightKg,_that.size,_that.deadline,_that.offeredPrice,_that.status,_that.hasProhibitedItemsDeclaration,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParcelDto implements ParcelDto {
  const _ParcelDto({required this.id, required this.senderId, required this.senderName, required this.title, required this.fromDistrict, required this.fromArea, required this.toDistrict, required this.toArea, final  List<String> categoryTags = const <String>[], required this.weightKg, this.size = 'medium', required this.deadline, required this.offeredPrice, this.status = 'open', this.hasProhibitedItemsDeclaration = false, this.note, required this.createdAt}): _categoryTags = categoryTags;
  factory _ParcelDto.fromJson(Map<String, dynamic> json) => _$ParcelDtoFromJson(json);

@override final  String id;
@override final  String senderId;
@override final  String senderName;
@override final  String title;
@override final  String fromDistrict;
@override final  String fromArea;
@override final  String toDistrict;
@override final  String toArea;
 final  List<String> _categoryTags;
@override@JsonKey() List<String> get categoryTags {
  if (_categoryTags is EqualUnmodifiableListView) return _categoryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryTags);
}

@override final  double weightKg;
@override@JsonKey() final  String size;
@override final  String deadline;
@override final  double offeredPrice;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool hasProhibitedItemsDeclaration;
@override final  String? note;
@override final  String createdAt;

/// Create a copy of ParcelDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParcelDtoCopyWith<_ParcelDto> get copyWith => __$ParcelDtoCopyWithImpl<_ParcelDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParcelDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParcelDto&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.title, title) || other.title == title)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.fromArea, fromArea) || other.fromArea == fromArea)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.toArea, toArea) || other.toArea == toArea)&&const DeepCollectionEquality().equals(other._categoryTags, _categoryTags)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.size, size) || other.size == size)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.offeredPrice, offeredPrice) || other.offeredPrice == offeredPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasProhibitedItemsDeclaration, hasProhibitedItemsDeclaration) || other.hasProhibitedItemsDeclaration == hasProhibitedItemsDeclaration)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderName,title,fromDistrict,fromArea,toDistrict,toArea,const DeepCollectionEquality().hash(_categoryTags),weightKg,size,deadline,offeredPrice,status,hasProhibitedItemsDeclaration,note,createdAt);

@override
String toString() {
  return 'ParcelDto(id: $id, senderId: $senderId, senderName: $senderName, title: $title, fromDistrict: $fromDistrict, fromArea: $fromArea, toDistrict: $toDistrict, toArea: $toArea, categoryTags: $categoryTags, weightKg: $weightKg, size: $size, deadline: $deadline, offeredPrice: $offeredPrice, status: $status, hasProhibitedItemsDeclaration: $hasProhibitedItemsDeclaration, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ParcelDtoCopyWith<$Res> implements $ParcelDtoCopyWith<$Res> {
  factory _$ParcelDtoCopyWith(_ParcelDto value, $Res Function(_ParcelDto) _then) = __$ParcelDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String senderName, String title, String fromDistrict, String fromArea, String toDistrict, String toArea, List<String> categoryTags, double weightKg, String size, String deadline, double offeredPrice, String status, bool hasProhibitedItemsDeclaration, String? note, String createdAt
});




}
/// @nodoc
class __$ParcelDtoCopyWithImpl<$Res>
    implements _$ParcelDtoCopyWith<$Res> {
  __$ParcelDtoCopyWithImpl(this._self, this._then);

  final _ParcelDto _self;
  final $Res Function(_ParcelDto) _then;

/// Create a copy of ParcelDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? senderName = null,Object? title = null,Object? fromDistrict = null,Object? fromArea = null,Object? toDistrict = null,Object? toArea = null,Object? categoryTags = null,Object? weightKg = null,Object? size = null,Object? deadline = null,Object? offeredPrice = null,Object? status = null,Object? hasProhibitedItemsDeclaration = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_ParcelDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,fromArea: null == fromArea ? _self.fromArea : fromArea // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,toArea: null == toArea ? _self.toArea : toArea // ignore: cast_nullable_to_non_nullable
as String,categoryTags: null == categoryTags ? _self._categoryTags : categoryTags // ignore: cast_nullable_to_non_nullable
as List<String>,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String,offeredPrice: null == offeredPrice ? _self.offeredPrice : offeredPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,hasProhibitedItemsDeclaration: null == hasProhibitedItemsDeclaration ? _self.hasProhibitedItemsDeclaration : hasProhibitedItemsDeclaration // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
