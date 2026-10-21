// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OfferDto {

 String get id; String get parcelId; String get tripId; String get senderId; String get senderName; String get travellerId; String get travellerName; String get parcelTitle; String get fromDistrict; String get toDistrict; double get price; String get status; String get lastCounterBy; double get travellerRating; int get travellerTripsCount; bool get isTravellerVerified; List<String> get noCarryTags; bool get senderAccepted; bool get travellerAccepted; String get createdAt; String get updatedAt;
/// Create a copy of OfferDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferDtoCopyWith<OfferDto> get copyWith => _$OfferDtoCopyWithImpl<OfferDto>(this as OfferDto, _$identity);

  /// Serializes this OfferDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfferDto&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCounterBy, lastCounterBy) || other.lastCounterBy == lastCounterBy)&&(identical(other.travellerRating, travellerRating) || other.travellerRating == travellerRating)&&(identical(other.travellerTripsCount, travellerTripsCount) || other.travellerTripsCount == travellerTripsCount)&&(identical(other.isTravellerVerified, isTravellerVerified) || other.isTravellerVerified == isTravellerVerified)&&const DeepCollectionEquality().equals(other.noCarryTags, noCarryTags)&&(identical(other.senderAccepted, senderAccepted) || other.senderAccepted == senderAccepted)&&(identical(other.travellerAccepted, travellerAccepted) || other.travellerAccepted == travellerAccepted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,price,status,lastCounterBy,travellerRating,travellerTripsCount,isTravellerVerified,const DeepCollectionEquality().hash(noCarryTags),senderAccepted,travellerAccepted,createdAt,updatedAt]);

@override
String toString() {
  return 'OfferDto(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, price: $price, status: $status, lastCounterBy: $lastCounterBy, travellerRating: $travellerRating, travellerTripsCount: $travellerTripsCount, isTravellerVerified: $isTravellerVerified, noCarryTags: $noCarryTags, senderAccepted: $senderAccepted, travellerAccepted: $travellerAccepted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OfferDtoCopyWith<$Res>  {
  factory $OfferDtoCopyWith(OfferDto value, $Res Function(OfferDto) _then) = _$OfferDtoCopyWithImpl;
@useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double price, String status, String lastCounterBy, double travellerRating, int travellerTripsCount, bool isTravellerVerified, List<String> noCarryTags, bool senderAccepted, bool travellerAccepted, String createdAt, String updatedAt
});




}
/// @nodoc
class _$OfferDtoCopyWithImpl<$Res>
    implements $OfferDtoCopyWith<$Res> {
  _$OfferDtoCopyWithImpl(this._self, this._then);

  final OfferDto _self;
  final $Res Function(OfferDto) _then;

/// Create a copy of OfferDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? price = null,Object? status = null,Object? lastCounterBy = null,Object? travellerRating = null,Object? travellerTripsCount = null,Object? isTravellerVerified = null,Object? noCarryTags = null,Object? senderAccepted = null,Object? travellerAccepted = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parcelId: null == parcelId ? _self.parcelId : parcelId // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,travellerId: null == travellerId ? _self.travellerId : travellerId // ignore: cast_nullable_to_non_nullable
as String,travellerName: null == travellerName ? _self.travellerName : travellerName // ignore: cast_nullable_to_non_nullable
as String,parcelTitle: null == parcelTitle ? _self.parcelTitle : parcelTitle // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastCounterBy: null == lastCounterBy ? _self.lastCounterBy : lastCounterBy // ignore: cast_nullable_to_non_nullable
as String,travellerRating: null == travellerRating ? _self.travellerRating : travellerRating // ignore: cast_nullable_to_non_nullable
as double,travellerTripsCount: null == travellerTripsCount ? _self.travellerTripsCount : travellerTripsCount // ignore: cast_nullable_to_non_nullable
as int,isTravellerVerified: null == isTravellerVerified ? _self.isTravellerVerified : isTravellerVerified // ignore: cast_nullable_to_non_nullable
as bool,noCarryTags: null == noCarryTags ? _self.noCarryTags : noCarryTags // ignore: cast_nullable_to_non_nullable
as List<String>,senderAccepted: null == senderAccepted ? _self.senderAccepted : senderAccepted // ignore: cast_nullable_to_non_nullable
as bool,travellerAccepted: null == travellerAccepted ? _self.travellerAccepted : travellerAccepted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OfferDto].
extension OfferDtoPatterns on OfferDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfferDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfferDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfferDto value)  $default,){
final _that = this;
switch (_that) {
case _OfferDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfferDto value)?  $default,){
final _that = this;
switch (_that) {
case _OfferDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  String status,  String lastCounterBy,  double travellerRating,  int travellerTripsCount,  bool isTravellerVerified,  List<String> noCarryTags,  bool senderAccepted,  bool travellerAccepted,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfferDto() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.status,_that.lastCounterBy,_that.travellerRating,_that.travellerTripsCount,_that.isTravellerVerified,_that.noCarryTags,_that.senderAccepted,_that.travellerAccepted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  String status,  String lastCounterBy,  double travellerRating,  int travellerTripsCount,  bool isTravellerVerified,  List<String> noCarryTags,  bool senderAccepted,  bool travellerAccepted,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OfferDto():
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.status,_that.lastCounterBy,_that.travellerRating,_that.travellerTripsCount,_that.isTravellerVerified,_that.noCarryTags,_that.senderAccepted,_that.travellerAccepted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  String status,  String lastCounterBy,  double travellerRating,  int travellerTripsCount,  bool isTravellerVerified,  List<String> noCarryTags,  bool senderAccepted,  bool travellerAccepted,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OfferDto() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.status,_that.lastCounterBy,_that.travellerRating,_that.travellerTripsCount,_that.isTravellerVerified,_that.noCarryTags,_that.senderAccepted,_that.travellerAccepted,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfferDto implements OfferDto {
  const _OfferDto({required this.id, required this.parcelId, required this.tripId, required this.senderId, required this.senderName, required this.travellerId, required this.travellerName, required this.parcelTitle, required this.fromDistrict, required this.toDistrict, required this.price, required this.status, required this.lastCounterBy, this.travellerRating = 5.0, this.travellerTripsCount = 0, this.isTravellerVerified = false, final  List<String> noCarryTags = const <String>[], this.senderAccepted = false, this.travellerAccepted = false, required this.createdAt, required this.updatedAt}): _noCarryTags = noCarryTags;
  factory _OfferDto.fromJson(Map<String, dynamic> json) => _$OfferDtoFromJson(json);

@override final  String id;
@override final  String parcelId;
@override final  String tripId;
@override final  String senderId;
@override final  String senderName;
@override final  String travellerId;
@override final  String travellerName;
@override final  String parcelTitle;
@override final  String fromDistrict;
@override final  String toDistrict;
@override final  double price;
@override final  String status;
@override final  String lastCounterBy;
@override@JsonKey() final  double travellerRating;
@override@JsonKey() final  int travellerTripsCount;
@override@JsonKey() final  bool isTravellerVerified;
 final  List<String> _noCarryTags;
@override@JsonKey() List<String> get noCarryTags {
  if (_noCarryTags is EqualUnmodifiableListView) return _noCarryTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_noCarryTags);
}

@override@JsonKey() final  bool senderAccepted;
@override@JsonKey() final  bool travellerAccepted;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of OfferDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferDtoCopyWith<_OfferDto> get copyWith => __$OfferDtoCopyWithImpl<_OfferDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfferDto&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCounterBy, lastCounterBy) || other.lastCounterBy == lastCounterBy)&&(identical(other.travellerRating, travellerRating) || other.travellerRating == travellerRating)&&(identical(other.travellerTripsCount, travellerTripsCount) || other.travellerTripsCount == travellerTripsCount)&&(identical(other.isTravellerVerified, isTravellerVerified) || other.isTravellerVerified == isTravellerVerified)&&const DeepCollectionEquality().equals(other._noCarryTags, _noCarryTags)&&(identical(other.senderAccepted, senderAccepted) || other.senderAccepted == senderAccepted)&&(identical(other.travellerAccepted, travellerAccepted) || other.travellerAccepted == travellerAccepted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,price,status,lastCounterBy,travellerRating,travellerTripsCount,isTravellerVerified,const DeepCollectionEquality().hash(_noCarryTags),senderAccepted,travellerAccepted,createdAt,updatedAt]);

@override
String toString() {
  return 'OfferDto(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, price: $price, status: $status, lastCounterBy: $lastCounterBy, travellerRating: $travellerRating, travellerTripsCount: $travellerTripsCount, isTravellerVerified: $isTravellerVerified, noCarryTags: $noCarryTags, senderAccepted: $senderAccepted, travellerAccepted: $travellerAccepted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OfferDtoCopyWith<$Res> implements $OfferDtoCopyWith<$Res> {
  factory _$OfferDtoCopyWith(_OfferDto value, $Res Function(_OfferDto) _then) = __$OfferDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double price, String status, String lastCounterBy, double travellerRating, int travellerTripsCount, bool isTravellerVerified, List<String> noCarryTags, bool senderAccepted, bool travellerAccepted, String createdAt, String updatedAt
});




}
/// @nodoc
class __$OfferDtoCopyWithImpl<$Res>
    implements _$OfferDtoCopyWith<$Res> {
  __$OfferDtoCopyWithImpl(this._self, this._then);

  final _OfferDto _self;
  final $Res Function(_OfferDto) _then;

/// Create a copy of OfferDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? price = null,Object? status = null,Object? lastCounterBy = null,Object? travellerRating = null,Object? travellerTripsCount = null,Object? isTravellerVerified = null,Object? noCarryTags = null,Object? senderAccepted = null,Object? travellerAccepted = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_OfferDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parcelId: null == parcelId ? _self.parcelId : parcelId // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,travellerId: null == travellerId ? _self.travellerId : travellerId // ignore: cast_nullable_to_non_nullable
as String,travellerName: null == travellerName ? _self.travellerName : travellerName // ignore: cast_nullable_to_non_nullable
as String,parcelTitle: null == parcelTitle ? _self.parcelTitle : parcelTitle // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastCounterBy: null == lastCounterBy ? _self.lastCounterBy : lastCounterBy // ignore: cast_nullable_to_non_nullable
as String,travellerRating: null == travellerRating ? _self.travellerRating : travellerRating // ignore: cast_nullable_to_non_nullable
as double,travellerTripsCount: null == travellerTripsCount ? _self.travellerTripsCount : travellerTripsCount // ignore: cast_nullable_to_non_nullable
as int,isTravellerVerified: null == isTravellerVerified ? _self.isTravellerVerified : isTravellerVerified // ignore: cast_nullable_to_non_nullable
as bool,noCarryTags: null == noCarryTags ? _self._noCarryTags : noCarryTags // ignore: cast_nullable_to_non_nullable
as List<String>,senderAccepted: null == senderAccepted ? _self.senderAccepted : senderAccepted // ignore: cast_nullable_to_non_nullable
as bool,travellerAccepted: null == travellerAccepted ? _self.travellerAccepted : travellerAccepted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
