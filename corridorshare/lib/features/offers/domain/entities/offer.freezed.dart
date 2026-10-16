// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Offer {

 String get id; String get parcelId; String get tripId; String get senderId; String get senderName; String get travellerId; String get travellerName; String get parcelTitle; String get fromDistrict; String get toDistrict; double get price; OfferStatus get status; String get lastCounterBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCounterBy, lastCounterBy) || other.lastCounterBy == lastCounterBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,price,status,lastCounterBy,createdAt,updatedAt);

@override
String toString() {
  return 'Offer(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, price: $price, status: $status, lastCounterBy: $lastCounterBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double price, OfferStatus status, String lastCounterBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? price = null,Object? status = null,Object? lastCounterBy = null,Object? createdAt = null,Object? updatedAt = null,}) {
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
as OfferStatus,lastCounterBy: null == lastCounterBy ? _self.lastCounterBy : lastCounterBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Offer].
extension OfferPatterns on Offer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Offer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Offer value)  $default,){
final _that = this;
switch (_that) {
case _Offer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Offer value)?  $default,){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  OfferStatus status,  String lastCounterBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.status,_that.lastCounterBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  OfferStatus status,  String lastCounterBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.status,_that.lastCounterBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  OfferStatus status,  String lastCounterBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.status,_that.lastCounterBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Offer implements Offer {
  const _Offer({required this.id, required this.parcelId, required this.tripId, required this.senderId, required this.senderName, required this.travellerId, required this.travellerName, required this.parcelTitle, required this.fromDistrict, required this.toDistrict, required this.price, required this.status, required this.lastCounterBy, required this.createdAt, required this.updatedAt});
  

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
@override final  OfferStatus status;
@override final  String lastCounterBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.price, price) || other.price == price)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCounterBy, lastCounterBy) || other.lastCounterBy == lastCounterBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,price,status,lastCounterBy,createdAt,updatedAt);

@override
String toString() {
  return 'Offer(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, price: $price, status: $status, lastCounterBy: $lastCounterBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double price, OfferStatus status, String lastCounterBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? price = null,Object? status = null,Object? lastCounterBy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Offer(
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
as OfferStatus,lastCounterBy: null == lastCounterBy ? _self.lastCounterBy : lastCounterBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
