// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatConversation {

 String get offerId; String get counterpartId; String get counterpartName; String get parcelTitle; String get fromDistrict; String get toDistrict; double get price; OfferStatus get offerStatus; String get lastMessageText; DateTime get lastMessageTime; int get unreadCount; bool get isVerified; String? get customTag; String? get customTagType;
/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationCopyWith<ChatConversation> get copyWith => _$ChatConversationCopyWithImpl<ChatConversation>(this as ChatConversation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversation&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.counterpartId, counterpartId) || other.counterpartId == counterpartId)&&(identical(other.counterpartName, counterpartName) || other.counterpartName == counterpartName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.price, price) || other.price == price)&&(identical(other.offerStatus, offerStatus) || other.offerStatus == offerStatus)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageTime, lastMessageTime) || other.lastMessageTime == lastMessageTime)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.customTag, customTag) || other.customTag == customTag)&&(identical(other.customTagType, customTagType) || other.customTagType == customTagType));
}


@override
int get hashCode => Object.hash(runtimeType,offerId,counterpartId,counterpartName,parcelTitle,fromDistrict,toDistrict,price,offerStatus,lastMessageText,lastMessageTime,unreadCount,isVerified,customTag,customTagType);

@override
String toString() {
  return 'ChatConversation(offerId: $offerId, counterpartId: $counterpartId, counterpartName: $counterpartName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, price: $price, offerStatus: $offerStatus, lastMessageText: $lastMessageText, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, isVerified: $isVerified, customTag: $customTag, customTagType: $customTagType)';
}


}

/// @nodoc
abstract mixin class $ChatConversationCopyWith<$Res>  {
  factory $ChatConversationCopyWith(ChatConversation value, $Res Function(ChatConversation) _then) = _$ChatConversationCopyWithImpl;
@useResult
$Res call({
 String offerId, String counterpartId, String counterpartName, String parcelTitle, String fromDistrict, String toDistrict, double price, OfferStatus offerStatus, String lastMessageText, DateTime lastMessageTime, int unreadCount, bool isVerified, String? customTag, String? customTagType
});




}
/// @nodoc
class _$ChatConversationCopyWithImpl<$Res>
    implements $ChatConversationCopyWith<$Res> {
  _$ChatConversationCopyWithImpl(this._self, this._then);

  final ChatConversation _self;
  final $Res Function(ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offerId = null,Object? counterpartId = null,Object? counterpartName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? price = null,Object? offerStatus = null,Object? lastMessageText = null,Object? lastMessageTime = null,Object? unreadCount = null,Object? isVerified = null,Object? customTag = freezed,Object? customTagType = freezed,}) {
  return _then(_self.copyWith(
offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,counterpartId: null == counterpartId ? _self.counterpartId : counterpartId // ignore: cast_nullable_to_non_nullable
as String,counterpartName: null == counterpartName ? _self.counterpartName : counterpartName // ignore: cast_nullable_to_non_nullable
as String,parcelTitle: null == parcelTitle ? _self.parcelTitle : parcelTitle // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,offerStatus: null == offerStatus ? _self.offerStatus : offerStatus // ignore: cast_nullable_to_non_nullable
as OfferStatus,lastMessageText: null == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String,lastMessageTime: null == lastMessageTime ? _self.lastMessageTime : lastMessageTime // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,customTag: freezed == customTag ? _self.customTag : customTag // ignore: cast_nullable_to_non_nullable
as String?,customTagType: freezed == customTagType ? _self.customTagType : customTagType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversation].
extension ChatConversationPatterns on ChatConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversation value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversation value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String offerId,  String counterpartId,  String counterpartName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  OfferStatus offerStatus,  String lastMessageText,  DateTime lastMessageTime,  int unreadCount,  bool isVerified,  String? customTag,  String? customTagType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.offerId,_that.counterpartId,_that.counterpartName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.offerStatus,_that.lastMessageText,_that.lastMessageTime,_that.unreadCount,_that.isVerified,_that.customTag,_that.customTagType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String offerId,  String counterpartId,  String counterpartName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  OfferStatus offerStatus,  String lastMessageText,  DateTime lastMessageTime,  int unreadCount,  bool isVerified,  String? customTag,  String? customTagType)  $default,) {final _that = this;
switch (_that) {
case _ChatConversation():
return $default(_that.offerId,_that.counterpartId,_that.counterpartName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.offerStatus,_that.lastMessageText,_that.lastMessageTime,_that.unreadCount,_that.isVerified,_that.customTag,_that.customTagType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String offerId,  String counterpartId,  String counterpartName,  String parcelTitle,  String fromDistrict,  String toDistrict,  double price,  OfferStatus offerStatus,  String lastMessageText,  DateTime lastMessageTime,  int unreadCount,  bool isVerified,  String? customTag,  String? customTagType)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.offerId,_that.counterpartId,_that.counterpartName,_that.parcelTitle,_that.fromDistrict,_that.toDistrict,_that.price,_that.offerStatus,_that.lastMessageText,_that.lastMessageTime,_that.unreadCount,_that.isVerified,_that.customTag,_that.customTagType);case _:
  return null;

}
}

}

/// @nodoc


class _ChatConversation implements ChatConversation {
  const _ChatConversation({required this.offerId, required this.counterpartId, required this.counterpartName, required this.parcelTitle, required this.fromDistrict, required this.toDistrict, required this.price, required this.offerStatus, required this.lastMessageText, required this.lastMessageTime, this.unreadCount = 0, this.isVerified = true, this.customTag = null, this.customTagType = null});
  

@override final  String offerId;
@override final  String counterpartId;
@override final  String counterpartName;
@override final  String parcelTitle;
@override final  String fromDistrict;
@override final  String toDistrict;
@override final  double price;
@override final  OfferStatus offerStatus;
@override final  String lastMessageText;
@override final  DateTime lastMessageTime;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  String? customTag;
@override@JsonKey() final  String? customTagType;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationCopyWith<_ChatConversation> get copyWith => __$ChatConversationCopyWithImpl<_ChatConversation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversation&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.counterpartId, counterpartId) || other.counterpartId == counterpartId)&&(identical(other.counterpartName, counterpartName) || other.counterpartName == counterpartName)&&(identical(other.parcelTitle, parcelTitle) || other.parcelTitle == parcelTitle)&&(identical(other.fromDistrict, fromDistrict) || other.fromDistrict == fromDistrict)&&(identical(other.toDistrict, toDistrict) || other.toDistrict == toDistrict)&&(identical(other.price, price) || other.price == price)&&(identical(other.offerStatus, offerStatus) || other.offerStatus == offerStatus)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageTime, lastMessageTime) || other.lastMessageTime == lastMessageTime)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.customTag, customTag) || other.customTag == customTag)&&(identical(other.customTagType, customTagType) || other.customTagType == customTagType));
}


@override
int get hashCode => Object.hash(runtimeType,offerId,counterpartId,counterpartName,parcelTitle,fromDistrict,toDistrict,price,offerStatus,lastMessageText,lastMessageTime,unreadCount,isVerified,customTag,customTagType);

@override
String toString() {
  return 'ChatConversation(offerId: $offerId, counterpartId: $counterpartId, counterpartName: $counterpartName, parcelTitle: $parcelTitle, fromDistrict: $fromDistrict, toDistrict: $toDistrict, price: $price, offerStatus: $offerStatus, lastMessageText: $lastMessageText, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, isVerified: $isVerified, customTag: $customTag, customTagType: $customTagType)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationCopyWith<$Res> implements $ChatConversationCopyWith<$Res> {
  factory _$ChatConversationCopyWith(_ChatConversation value, $Res Function(_ChatConversation) _then) = __$ChatConversationCopyWithImpl;
@override @useResult
$Res call({
 String offerId, String counterpartId, String counterpartName, String parcelTitle, String fromDistrict, String toDistrict, double price, OfferStatus offerStatus, String lastMessageText, DateTime lastMessageTime, int unreadCount, bool isVerified, String? customTag, String? customTagType
});




}
/// @nodoc
class __$ChatConversationCopyWithImpl<$Res>
    implements _$ChatConversationCopyWith<$Res> {
  __$ChatConversationCopyWithImpl(this._self, this._then);

  final _ChatConversation _self;
  final $Res Function(_ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offerId = null,Object? counterpartId = null,Object? counterpartName = null,Object? parcelTitle = null,Object? fromDistrict = null,Object? toDistrict = null,Object? price = null,Object? offerStatus = null,Object? lastMessageText = null,Object? lastMessageTime = null,Object? unreadCount = null,Object? isVerified = null,Object? customTag = freezed,Object? customTagType = freezed,}) {
  return _then(_ChatConversation(
offerId: null == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String,counterpartId: null == counterpartId ? _self.counterpartId : counterpartId // ignore: cast_nullable_to_non_nullable
as String,counterpartName: null == counterpartName ? _self.counterpartName : counterpartName // ignore: cast_nullable_to_non_nullable
as String,parcelTitle: null == parcelTitle ? _self.parcelTitle : parcelTitle // ignore: cast_nullable_to_non_nullable
as String,fromDistrict: null == fromDistrict ? _self.fromDistrict : fromDistrict // ignore: cast_nullable_to_non_nullable
as String,toDistrict: null == toDistrict ? _self.toDistrict : toDistrict // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,offerStatus: null == offerStatus ? _self.offerStatus : offerStatus // ignore: cast_nullable_to_non_nullable
as OfferStatus,lastMessageText: null == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String,lastMessageTime: null == lastMessageTime ? _self.lastMessageTime : lastMessageTime // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,customTag: freezed == customTag ? _self.customTag : customTag // ignore: cast_nullable_to_non_nullable
as String?,customTagType: freezed == customTagType ? _self.customTagType : customTagType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
