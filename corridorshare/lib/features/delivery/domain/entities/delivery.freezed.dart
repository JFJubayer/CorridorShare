// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Delivery {

 String get id; String get parcelId; String get tripId; String get senderId; String get senderName; String get travellerId; String get travellerName; String get parcelTitle; String get fromDistrict; String get toDistrict; double get agreedPrice; DeliveryStatus get status; String get verificationPin; String? get pickupPhotoUrl; String? get pickupNotes; DateTime? get pickedUpAt; DateTime? get deliveredAt; bool get isDisputed; String? get disputeReason; DateTime? get disputedAt; String? get disputedBy; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryCopyWith<Delivery> get copyWith => _$DeliveryCopyWithImpl<Delivery>(this as Delivery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Delivery&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.agreedPrice, agreedPrice) || other.agreedPrice == agreedPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationPin, verificationPin) || other.verificationPin == verificationPin)&&(identical(other.pickupPhotoUrl, pickupPhotoUrl) || other.pickupPhotoUrl == pickupPhotoUrl)&&(identical(other.pickupNotes, pickupNotes) || other.pickupNotes == pickupNotes)&&(identical(other.pickedUpAt, pickedUpAt) || other.pickedUpAt == pickedUpAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.isDisputed, isDisputed) || other.isDisputed == isDisputed)&&(identical(other.disputeReason, disputeReason) || other.disputeReason == disputeReason)&&(identical(other.disputedAt, disputedAt) || other.disputedAt == disputedAt)&&(identical(other.disputedBy, disputedBy) || other.disputedBy == disputedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,agreedPrice,status,verificationPin,pickupPhotoUrl,pickupNotes,pickedUpAt,deliveredAt,isDisputed,disputeReason,disputedAt,disputedBy,createdAt,updatedAt]);

@override
String toString() {
  return 'Delivery(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, agreedPrice: $agreedPrice, status: $status, verificationPin: $verificationPin, pickupPhotoUrl: $pickupPhotoUrl, pickupNotes: $pickupNotes, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt, isDisputed: $isDisputed, disputeReason: $disputeReason, disputedAt: $disputedAt, disputedBy: $disputedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryCopyWith<$Res>  {
  factory $DeliveryCopyWith(Delivery value, $Res Function(Delivery) _then) = _$DeliveryCopyWithImpl;
@useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double agreedPrice, DeliveryStatus status, String verificationPin, String? pickupPhotoUrl, String? pickupNotes, DateTime? pickedUpAt, DateTime? deliveredAt, bool isDisputed, String? disputeReason, DateTime? disputedAt, String? disputedBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$DeliveryCopyWithImpl<$Res>
    implements $DeliveryCopyWith<$Res> {
  _$DeliveryCopyWithImpl(this._self, this._then);

  final Delivery _self;
  final $Res Function(Delivery) _then;

/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? agreedPrice = null,Object? status = null,Object? verificationPin = null,Object? pickupPhotoUrl = freezed,Object? pickupNotes = freezed,Object? pickedUpAt = freezed,Object? deliveredAt = freezed,Object? isDisputed = null,Object? disputeReason = freezed,Object? disputedAt = freezed,Object? disputedBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
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
as String,agreedPrice: null == agreedPrice ? _self.agreedPrice : agreedPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,verificationPin: null == verificationPin ? _self.verificationPin : verificationPin // ignore: cast_nullable_to_non_nullable
as String,pickupPhotoUrl: freezed == pickupPhotoUrl ? _self.pickupPhotoUrl : pickupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,pickupNotes: freezed == pickupNotes ? _self.pickupNotes : pickupNotes // ignore: cast_nullable_to_non_nullable
as String?,pickedUpAt: freezed == pickedUpAt ? _self.pickedUpAt : pickedUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDisputed: null == isDisputed ? _self.isDisputed : isDisputed // ignore: cast_nullable_to_non_nullable
as bool,disputeReason: freezed == disputeReason ? _self.disputeReason : disputeReason // ignore: cast_nullable_to_non_nullable
as String?,disputedAt: freezed == disputedAt ? _self.disputedAt : disputedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disputedBy: freezed == disputedBy ? _self.disputedBy : disputedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Delivery].
extension DeliveryPatterns on Delivery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Delivery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Delivery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Delivery value)  $default,){
final _that = this;
switch (_that) {
case _Delivery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Delivery value)?  $default,){
final _that = this;
switch (_that) {
case _Delivery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double agreedPrice,  DeliveryStatus status,  String verificationPin,  String? pickupPhotoUrl,  String? pickupNotes,  DateTime? pickedUpAt,  DateTime? deliveredAt,  bool isDisputed,  String? disputeReason,  DateTime? disputedAt,  String? disputedBy,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Delivery() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.agreedPrice,_that.status,_that.verificationPin,_that.pickupPhotoUrl,_that.pickupNotes,_that.pickedUpAt,_that.deliveredAt,_that.isDisputed,_that.disputeReason,_that.disputedAt,_that.disputedBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double agreedPrice,  DeliveryStatus status,  String verificationPin,  String? pickupPhotoUrl,  String? pickupNotes,  DateTime? pickedUpAt,  DateTime? deliveredAt,  bool isDisputed,  String? disputeReason,  DateTime? disputedAt,  String? disputedBy,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Delivery():
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.agreedPrice,_that.status,_that.verificationPin,_that.pickupPhotoUrl,_that.pickupNotes,_that.pickedUpAt,_that.deliveredAt,_that.isDisputed,_that.disputeReason,_that.disputedAt,_that.disputedBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double agreedPrice,  DeliveryStatus status,  String verificationPin,  String? pickupPhotoUrl,  String? pickupNotes,  DateTime? pickedUpAt,  DateTime? deliveredAt,  bool isDisputed,  String? disputeReason,  DateTime? disputedAt,  String? disputedBy,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Delivery() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.agreedPrice,_that.status,_that.verificationPin,_that.pickupPhotoUrl,_that.pickupNotes,_that.pickedUpAt,_that.deliveredAt,_that.isDisputed,_that.disputeReason,_that.disputedAt,_that.disputedBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Delivery implements Delivery {
  const _Delivery({required this.id, required this.parcelId, required this.tripId, required this.senderId, required this.senderName, required this.travellerId, required this.travellerName, required this.parcelTitle, required this.fromDistrict, required this.toDistrict, required this.agreedPrice, this.status = DeliveryStatus.matched, required this.verificationPin, this.pickupPhotoUrl, this.pickupNotes, this.pickedUpAt, this.deliveredAt, this.isDisputed = false, this.disputeReason, this.disputedAt, this.disputedBy, required this.createdAt, required this.updatedAt});
  

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
@override final  double agreedPrice;
@override@JsonKey() final  DeliveryStatus status;
@override final  String verificationPin;
@override final  String? pickupPhotoUrl;
@override final  String? pickupNotes;
@override final  DateTime? pickedUpAt;
@override final  DateTime? deliveredAt;
@override@JsonKey() final  bool isDisputed;
@override final  String? disputeReason;
@override final  DateTime? disputedAt;
@override final  String? disputedBy;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryCopyWith<_Delivery> get copyWith => __$DeliveryCopyWithImpl<_Delivery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Delivery&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.agreedPrice, agreedPrice) || other.agreedPrice == agreedPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationPin, verificationPin) || other.verificationPin == verificationPin)&&(identical(other.pickupPhotoUrl, pickupPhotoUrl) || other.pickupPhotoUrl == pickupPhotoUrl)&&(identical(other.pickupNotes, pickupNotes) || other.pickupNotes == pickupNotes)&&(identical(other.pickedUpAt, pickedUpAt) || other.pickedUpAt == pickedUpAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.isDisputed, isDisputed) || other.isDisputed == isDisputed)&&(identical(other.disputeReason, disputeReason) || other.disputeReason == disputeReason)&&(identical(other.disputedAt, disputedAt) || other.disputedAt == disputedAt)&&(identical(other.disputedBy, disputedBy) || other.disputedBy == disputedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,agreedPrice,status,verificationPin,pickupPhotoUrl,pickupNotes,pickedUpAt,deliveredAt,isDisputed,disputeReason,disputedAt,disputedBy,createdAt,updatedAt]);

@override
String toString() {
  return 'Delivery(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, agreedPrice: $agreedPrice, status: $status, verificationPin: $verificationPin, pickupPhotoUrl: $pickupPhotoUrl, pickupNotes: $pickupNotes, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt, isDisputed: $isDisputed, disputeReason: $disputeReason, disputedAt: $disputedAt, disputedBy: $disputedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryCopyWith<$Res> implements $DeliveryCopyWith<$Res> {
  factory _$DeliveryCopyWith(_Delivery value, $Res Function(_Delivery) _then) = __$DeliveryCopyWithImpl;
@override @useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double agreedPrice, DeliveryStatus status, String verificationPin, String? pickupPhotoUrl, String? pickupNotes, DateTime? pickedUpAt, DateTime? deliveredAt, bool isDisputed, String? disputeReason, DateTime? disputedAt, String? disputedBy, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$DeliveryCopyWithImpl<$Res>
    implements _$DeliveryCopyWith<$Res> {
  __$DeliveryCopyWithImpl(this._self, this._then);

  final _Delivery _self;
  final $Res Function(_Delivery) _then;

/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? agreedPrice = null,Object? status = null,Object? verificationPin = null,Object? pickupPhotoUrl = freezed,Object? pickupNotes = freezed,Object? pickedUpAt = freezed,Object? deliveredAt = freezed,Object? isDisputed = null,Object? disputeReason = freezed,Object? disputedAt = freezed,Object? disputedBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Delivery(
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
as String,agreedPrice: null == agreedPrice ? _self.agreedPrice : agreedPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DeliveryStatus,verificationPin: null == verificationPin ? _self.verificationPin : verificationPin // ignore: cast_nullable_to_non_nullable
as String,pickupPhotoUrl: freezed == pickupPhotoUrl ? _self.pickupPhotoUrl : pickupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,pickupNotes: freezed == pickupNotes ? _self.pickupNotes : pickupNotes // ignore: cast_nullable_to_non_nullable
as String?,pickedUpAt: freezed == pickedUpAt ? _self.pickedUpAt : pickedUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDisputed: null == isDisputed ? _self.isDisputed : isDisputed // ignore: cast_nullable_to_non_nullable
as bool,disputeReason: freezed == disputeReason ? _self.disputeReason : disputeReason // ignore: cast_nullable_to_non_nullable
as String?,disputedAt: freezed == disputedAt ? _self.disputedAt : disputedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,disputedBy: freezed == disputedBy ? _self.disputedBy : disputedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
