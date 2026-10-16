// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeliveryDto {

 String get id; String get parcelId; String get tripId; String get senderId; String get senderName; String get travellerId; String get travellerName; String get parcelTitle; String get fromDistrict; String get toDistrict; double get agreedPrice; String get status; String get verificationPin; String? get pickupPhotoUrl; String? get pickupNotes; String? get pickedUpAt; String? get deliveredAt; bool get isDisputed; String? get disputeReason; String? get disputedAt; String? get disputedBy; String get createdAt; String get updatedAt;
/// Create a copy of DeliveryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryDtoCopyWith<DeliveryDto> get copyWith => _$DeliveryDtoCopyWithImpl<DeliveryDto>(this as DeliveryDto, _$identity);

  /// Serializes this DeliveryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.agreedPrice, agreedPrice) || other.agreedPrice == agreedPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationPin, verificationPin) || other.verificationPin == verificationPin)&&(identical(other.pickupPhotoUrl, pickupPhotoUrl) || other.pickupPhotoUrl == pickupPhotoUrl)&&(identical(other.pickupNotes, pickupNotes) || other.pickupNotes == pickupNotes)&&(identical(other.pickedUpAt, pickedUpAt) || other.pickedUpAt == pickedUpAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.isDisputed, isDisputed) || other.isDisputed == isDisputed)&&(identical(other.disputeReason, disputeReason) || other.disputeReason == disputeReason)&&(identical(other.disputedAt, disputedAt) || other.disputedAt == disputedAt)&&(identical(other.disputedBy, disputedBy) || other.disputedBy == disputedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,agreedPrice,status,verificationPin,pickupPhotoUrl,pickupNotes,pickedUpAt,deliveredAt,isDisputed,disputeReason,disputedAt,disputedBy,createdAt,updatedAt]);

@override
String toString() {
  return 'DeliveryDto(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, agreedPrice: $agreedPrice, status: $status, verificationPin: $verificationPin, pickupPhotoUrl: $pickupPhotoUrl, pickupNotes: $pickupNotes, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt, isDisputed: $isDisputed, disputeReason: $disputeReason, disputedAt: $disputedAt, disputedBy: $disputedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryDtoCopyWith<$Res>  {
  factory $DeliveryDtoCopyWith(DeliveryDto value, $Res Function(DeliveryDto) _then) = _$DeliveryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double agreedPrice, String status, String verificationPin, String? pickupPhotoUrl, String? pickupNotes, String? pickedUpAt, String? deliveredAt, bool isDisputed, String? disputeReason, String? disputedAt, String? disputedBy, String createdAt, String updatedAt
});




}
/// @nodoc
class _$DeliveryDtoCopyWithImpl<$Res>
    implements $DeliveryDtoCopyWith<$Res> {
  _$DeliveryDtoCopyWithImpl(this._self, this._then);

  final DeliveryDto _self;
  final $Res Function(DeliveryDto) _then;

/// Create a copy of DeliveryDto
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
as String,verificationPin: null == verificationPin ? _self.verificationPin : verificationPin // ignore: cast_nullable_to_non_nullable
as String,pickupPhotoUrl: freezed == pickupPhotoUrl ? _self.pickupPhotoUrl : pickupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,pickupNotes: freezed == pickupNotes ? _self.pickupNotes : pickupNotes // ignore: cast_nullable_to_non_nullable
as String?,pickedUpAt: freezed == pickedUpAt ? _self.pickedUpAt : pickedUpAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,isDisputed: null == isDisputed ? _self.isDisputed : isDisputed // ignore: cast_nullable_to_non_nullable
as bool,disputeReason: freezed == disputeReason ? _self.disputeReason : disputeReason // ignore: cast_nullable_to_non_nullable
as String?,disputedAt: freezed == disputedAt ? _self.disputedAt : disputedAt // ignore: cast_nullable_to_non_nullable
as String?,disputedBy: freezed == disputedBy ? _self.disputedBy : disputedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryDto].
extension DeliveryDtoPatterns on DeliveryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryDto value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryDto value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double agreedPrice,  String status,  String verificationPin,  String? pickupPhotoUrl,  String? pickupNotes,  String? pickedUpAt,  String? deliveredAt,  bool isDisputed,  String? disputeReason,  String? disputedAt,  String? disputedBy,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double agreedPrice,  String status,  String verificationPin,  String? pickupPhotoUrl,  String? pickupNotes,  String? pickedUpAt,  String? deliveredAt,  bool isDisputed,  String? disputeReason,  String? disputedAt,  String? disputedBy,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DeliveryDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parcelId,  String tripId,  String senderId,  String senderName,  String travellerId,  String travellerName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double agreedPrice,  String status,  String verificationPin,  String? pickupPhotoUrl,  String? pickupNotes,  String? pickedUpAt,  String? deliveredAt,  bool isDisputed,  String? disputeReason,  String? disputedAt,  String? disputedBy,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryDto() when $default != null:
return $default(_that.id,_that.parcelId,_that.tripId,_that.senderId,_that.senderName,_that.travellerId,_that.travellerName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.agreedPrice,_that.status,_that.verificationPin,_that.pickupPhotoUrl,_that.pickupNotes,_that.pickedUpAt,_that.deliveredAt,_that.isDisputed,_that.disputeReason,_that.disputedAt,_that.disputedBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeliveryDto implements DeliveryDto {
  const _DeliveryDto({required this.id, required this.parcelId, required this.tripId, required this.senderId, required this.senderName, required this.travellerId, required this.travellerName, required this.parcelTitle, required this.fromDistrict, required this.toDistrict, required this.agreedPrice, required this.status, required this.verificationPin, this.pickupPhotoUrl, this.pickupNotes, this.pickedUpAt, this.deliveredAt, this.isDisputed = false, this.disputeReason, this.disputedAt, this.disputedBy, required this.createdAt, required this.updatedAt});
  factory _DeliveryDto.fromJson(Map<String, dynamic> json) => _$DeliveryDtoFromJson(json);

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
@override final  String status;
@override final  String verificationPin;
@override final  String? pickupPhotoUrl;
@override final  String? pickupNotes;
@override final  String? pickedUpAt;
@override final  String? deliveredAt;
@override@JsonKey() final  bool isDisputed;
@override final  String? disputeReason;
@override final  String? disputedAt;
@override final  String? disputedBy;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of DeliveryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryDtoCopyWith<_DeliveryDto> get copyWith => __$DeliveryDtoCopyWithImpl<_DeliveryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.parcelId, parcelId) || other.parcelId == parcelId)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.travellerId, travellerId) || other.travellerId == travellerId)&&(identical(other.travellerName, travellerName) || other.travellerName == travellerName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.agreedPrice, agreedPrice) || other.agreedPrice == agreedPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.verificationPin, verificationPin) || other.verificationPin == verificationPin)&&(identical(other.pickupPhotoUrl, pickupPhotoUrl) || other.pickupPhotoUrl == pickupPhotoUrl)&&(identical(other.pickupNotes, pickupNotes) || other.pickupNotes == pickupNotes)&&(identical(other.pickedUpAt, pickedUpAt) || other.pickedUpAt == pickedUpAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.isDisputed, isDisputed) || other.isDisputed == isDisputed)&&(identical(other.disputeReason, disputeReason) || other.disputeReason == disputeReason)&&(identical(other.disputedAt, disputedAt) || other.disputedAt == disputedAt)&&(identical(other.disputedBy, disputedBy) || other.disputedBy == disputedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parcelId,tripId,senderId,senderName,travellerId,travellerName,parcelTitle,fromDistrict,toDistrict,agreedPrice,status,verificationPin,pickupPhotoUrl,pickupNotes,pickedUpAt,deliveredAt,isDisputed,disputeReason,disputedAt,disputedBy,createdAt,updatedAt]);

@override
String toString() {
  return 'DeliveryDto(id: $id, parcelId: $parcelId, tripId: $tripId, senderId: $senderId, senderName: $senderName, travellerId: $travellerId, travellerName: $travellerName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, agreedPrice: $agreedPrice, status: $status, verificationPin: $verificationPin, pickupPhotoUrl: $pickupPhotoUrl, pickupNotes: $pickupNotes, pickedUpAt: $pickedUpAt, deliveredAt: $deliveredAt, isDisputed: $isDisputed, disputeReason: $disputeReason, disputedAt: $disputedAt, disputedBy: $disputedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryDtoCopyWith<$Res> implements $DeliveryDtoCopyWith<$Res> {
  factory _$DeliveryDtoCopyWith(_DeliveryDto value, $Res Function(_DeliveryDto) _then) = __$DeliveryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String parcelId, String tripId, String senderId, String senderName, String travellerId, String travellerName, String parcelTitle, String fromDistrict, String toDistrict, double agreedPrice, String status, String verificationPin, String? pickupPhotoUrl, String? pickupNotes, String? pickedUpAt, String? deliveredAt, bool isDisputed, String? disputeReason, String? disputedAt, String? disputedBy, String createdAt, String updatedAt
});




}
/// @nodoc
class __$DeliveryDtoCopyWithImpl<$Res>
    implements _$DeliveryDtoCopyWith<$Res> {
  __$DeliveryDtoCopyWithImpl(this._self, this._then);

  final _DeliveryDto _self;
  final $Res Function(_DeliveryDto) _then;

/// Create a copy of DeliveryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parcelId = null,Object? tripId = null,Object? senderId = null,Object? senderName = null,Object? travellerId = null,Object? travellerName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? agreedPrice = null,Object? status = null,Object? verificationPin = null,Object? pickupPhotoUrl = freezed,Object? pickupNotes = freezed,Object? pickedUpAt = freezed,Object? deliveredAt = freezed,Object? isDisputed = null,Object? disputeReason = freezed,Object? disputedAt = freezed,Object? disputedBy = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DeliveryDto(
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
as String,verificationPin: null == verificationPin ? _self.verificationPin : verificationPin // ignore: cast_nullable_to_non_nullable
as String,pickupPhotoUrl: freezed == pickupPhotoUrl ? _self.pickupPhotoUrl : pickupPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,pickupNotes: freezed == pickupNotes ? _self.pickupNotes : pickupNotes // ignore: cast_nullable_to_non_nullable
as String?,pickedUpAt: freezed == pickedUpAt ? _self.pickedUpAt : pickedUpAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,isDisputed: null == isDisputed ? _self.isDisputed : isDisputed // ignore: cast_nullable_to_non_nullable
as bool,disputeReason: freezed == disputeReason ? _self.disputeReason : disputeReason // ignore: cast_nullable_to_non_nullable
as String?,disputedAt: freezed == disputedAt ? _self.disputedAt : disputedAt // ignore: cast_nullable_to_non_nullable
as String?,disputedBy: freezed == disputedBy ? _self.disputedBy : disputedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
