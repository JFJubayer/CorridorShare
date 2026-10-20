// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Trip {

 String get id; String get travellerId; String get travellerName; String get fromDistrict; String get fromArea; String get toDistrict; String get toArea; DateTime get departureDate; double get capacityKg; double get bookedKg; int get matchingParcelsCount; List<String> get noCarryTags; String? get note; TripStatus get status; DateTime get createdAt;
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCopyWith<Trip> get copyWith => _$TripCopyWithImpl<Trip>(this as Trip, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.fromArea, fromArea) || other.fromArea == fromArea)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.toArea, toArea) || other.toArea == toArea)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.capacityKg, capacityKg) || other.capacityKg == capacityKg)&&(identical(other.bookedKg, bookedKg) || other.bookedKg == bookedKg)&&(identical(other.matchingParcelsCount, matchingParcelsCount) || other.matchingParcelsCount == matchingParcelsCount)&&const DeepCollectionEquality().equals(other.noCarryTags, noCarryTags)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,travellerId,travellerName,fromDistrict,fromArea,toDistrict,toArea,departureDate,capacityKg,bookedKg,matchingParcelsCount,const DeepCollectionEquality().hash(noCarryTags),note,status,createdAt);

@override
String toString() {
  return 'Trip(id: $id, travellerId: $travellerId, travellerName: $travellerName, fromDistrict: $fromDistrict, fromArea: $fromArea, toDistrict: $toDistrict, toArea: $toArea, departureDate: $departureDate, capacityKg: $capacityKg, bookedKg: $bookedKg, matchingParcelsCount: $matchingParcelsCount, noCarryTags: $noCarryTags, note: $note, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TripCopyWith<$Res>  {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) = _$TripCopyWithImpl;
@useResult
$Res call({
 String id, String travellerId, String travellerName, String fromDistrict, String fromArea, String toDistrict, String toArea, DateTime departureDate, double capacityKg, double bookedKg, int matchingParcelsCount, List<String> noCarryTags, String? note, TripStatus status, DateTime createdAt
});




}
/// @nodoc
class _$TripCopyWithImpl<$Res>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? travellerId = null,Object? travellerName = null,Object? fromDistrict = null,Object? fromArea = null,Object? toDistrict = null,Object? toArea = null,Object? departureDate = null,Object? capacityKg = null,Object? bookedKg = null,Object? matchingParcelsCount = null,Object? noCarryTags = null,Object? note = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,travellerId: null == travellerId ? _self.travellerId : travellerId // ignore: cast_nullable_to_non_nullable
as String,travellerName: null == travellerName ? _self.travellerName : travellerName // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,fromArea: null == fromArea ? _self.fromArea : fromArea // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,toArea: null == toArea ? _self.toArea : toArea // ignore: cast_nullable_to_non_nullable
as String,departureDate: null == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime,capacityKg: null == capacityKg ? _self.capacityKg : capacityKg // ignore: cast_nullable_to_non_nullable
as double,bookedKg: null == bookedKg ? _self.bookedKg : bookedKg // ignore: cast_nullable_to_non_nullable
as double,matchingParcelsCount: null == matchingParcelsCount ? _self.matchingParcelsCount : matchingParcelsCount // ignore: cast_nullable_to_non_nullable
as int,noCarryTags: null == noCarryTags ? _self.noCarryTags : noCarryTags // ignore: cast_nullable_to_non_nullable
as List<String>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TripStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Trip].
extension TripPatterns on Trip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trip value)  $default,){
final _that = this;
switch (_that) {
case _Trip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trip value)?  $default,){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String travellerId,  String travellerName,  String fromDistrict,  String fromArea,  String toDistrict,  String toArea,  DateTime departureDate,  double capacityKg,  double bookedKg,  int matchingParcelsCount,  List<String> noCarryTags,  String? note,  TripStatus status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.travellerId,_that.travellerName,_that.fromDistrict,_that.fromArea,_that.toDistrict,_that.toArea,_that.departureDate,_that.capacityKg,_that.bookedKg,_that.matchingParcelsCount,_that.noCarryTags,_that.note,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String travellerId,  String travellerName,  String fromDistrict,  String fromArea,  String toDistrict,  String toArea,  DateTime departureDate,  double capacityKg,  double bookedKg,  int matchingParcelsCount,  List<String> noCarryTags,  String? note,  TripStatus status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Trip():
return $default(_that.id,_that.travellerId,_that.travellerName,_that.fromDistrict,_that.fromArea,_that.toDistrict,_that.toArea,_that.departureDate,_that.capacityKg,_that.bookedKg,_that.matchingParcelsCount,_that.noCarryTags,_that.note,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String travellerId,  String travellerName,  String fromDistrict,  String fromArea,  String toDistrict,  String toArea,  DateTime departureDate,  double capacityKg,  double bookedKg,  int matchingParcelsCount,  List<String> noCarryTags,  String? note,  TripStatus status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.travellerId,_that.travellerName,_that.fromDistrict,_that.fromArea,_that.toDistrict,_that.toArea,_that.departureDate,_that.capacityKg,_that.bookedKg,_that.matchingParcelsCount,_that.noCarryTags,_that.note,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _Trip implements Trip {
  const _Trip({required this.id, required this.travellerId, required this.travellerName, required this.fromDistrict, required this.fromArea, required this.toDistrict, required this.toArea, required this.departureDate, required this.capacityKg, this.bookedKg = 0.0, this.matchingParcelsCount = 0, final  List<String> noCarryTags = const <String>[], this.note, this.status = TripStatus.open, required this.createdAt}): _noCarryTags = noCarryTags;
  

@override final  String id;
@override final  String travellerId;
@override final  String travellerName;
@override final  String fromDistrict;
@override final  String fromArea;
@override final  String toDistrict;
@override final  String toArea;
@override final  DateTime departureDate;
@override final  double capacityKg;
@override@JsonKey() final  double bookedKg;
@override@JsonKey() final  int matchingParcelsCount;
 final  List<String> _noCarryTags;
@override@JsonKey() List<String> get noCarryTags {
  if (_noCarryTags is EqualUnmodifiableListView) return _noCarryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_noCarryTags);
}

@override final  String? note;
@override@JsonKey() final  TripStatus status;
@override final  DateTime createdAt;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCopyWith<_Trip> get copyWith => __$TripCopyWithImpl<_Trip>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.fromArea, fromArea) || other.fromArea == fromArea)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.toArea, toArea) || other.toArea == toArea)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.capacityKg, capacityKg) || other.capacityKg == capacityKg)&&(identical(other.bookedKg, bookedKg) || other.bookedKg == bookedKg)&&(identical(other.matchingParcelsCount, matchingParcelsCount) || other.matchingParcelsCount == matchingParcelsCount)&&const DeepCollectionEquality().equals(other._noCarryTags, _noCarryTags)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,travellerId,travellerName,fromDistrict,fromArea,toDistrict,toArea,departureDate,capacityKg,bookedKg,matchingParcelsCount,const DeepCollectionEquality().hash(_noCarryTags),note,status,createdAt);

@override
String toString() {
  return 'Trip(id: $id, travellerId: $travellerId, travellerName: $travellerName, fromDistrict: $fromDistrict, fromArea: $fromArea, toDistrict: $toDistrict, toArea: $toArea, departureDate: $departureDate, capacityKg: $capacityKg, bookedKg: $bookedKg, matchingParcelsCount: $matchingParcelsCount, noCarryTags: $noCarryTags, note: $note, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) = __$TripCopyWithImpl;
@override @useResult
$Res call({
 String id, String travellerId, String travellerName, String fromDistrict, String fromArea, String toDistrict, String toArea, DateTime departureDate, double capacityKg, double bookedKg, int matchingParcelsCount, List<String> noCarryTags, String? note, TripStatus status, DateTime createdAt
});




}
/// @nodoc
class __$TripCopyWithImpl<$Res>
    implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? travellerId = null,Object? travellerName = null,Object? fromDistrict = null,Object? fromArea = null,Object? toDistrict = null,Object? toArea = null,Object? departureDate = null,Object? capacityKg = null,Object? bookedKg = null,Object? matchingParcelsCount = null,Object? noCarryTags = null,Object? note = freezed,Object? status = null,Object? createdAt = null,}) {
  return _then(_Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,travellerId: null == travellerId ? _self.travellerId : travellerId // ignore: cast_nullable_to_non_nullable
as String,travellerName: null == travellerName ? _self.travellerName : travellerName // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,fromArea: null == fromArea ? _self.fromArea : fromArea // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,toArea: null == toArea ? _self.toArea : toArea // ignore: cast_nullable_to_non_nullable
as String,departureDate: null == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime,capacityKg: null == capacityKg ? _self.capacityKg : capacityKg // ignore: cast_nullable_to_non_nullable
as double,bookedKg: null == bookedKg ? _self.bookedKg : bookedKg // ignore: cast_nullable_to_non_nullable
as double,matchingParcelsCount: null == matchingParcelsCount ? _self.matchingParcelsCount : matchingParcelsCount // ignore: cast_nullable_to_non_nullable
as int,noCarryTags: null == noCarryTags ? _self._noCarryTags : noCarryTags // ignore: cast_nullable_to_non_nullable
as List<String>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TripStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
