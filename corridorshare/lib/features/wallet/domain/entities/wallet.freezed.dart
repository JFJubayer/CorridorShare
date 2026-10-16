// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Wallet {

 String get userId; double get balance; double get escrowBalance; List<WalletTransaction> get transactions;
/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCopyWith<Wallet> get copyWith => _$WalletCopyWithImpl<Wallet>(this as Wallet, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wallet&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.escrowBalance, escrowBalance) || other.escrowBalance == escrowBalance)&&const DeepCollectionEquality().equals(other.transactions, transactions));
}


@override
int get hashCode => Object.hash(runtimeType,userId,balance,escrowBalance,const DeepCollectionEquality().hash(transactions));

@override
String toString() {
  return 'Wallet(userId: $userId, balance: $balance, escrowBalance: $escrowBalance, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class $WalletCopyWith<$Res>  {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) _then) = _$WalletCopyWithImpl;
@useResult
$Res call({
 String userId, double balance, double escrowBalance, List<WalletTransaction> transactions
});




}
/// @nodoc
class _$WalletCopyWithImpl<$Res>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._self, this._then);

  final Wallet _self;
  final $Res Function(Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? balance = null,Object? escrowBalance = null,Object? transactions = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,escrowBalance: null == escrowBalance ? _self.escrowBalance : escrowBalance // ignore: cast_nullable_to_non_nullable
as double,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<WalletTransaction>,
  ));
}

}


/// Adds pattern-matching-related methods to [Wallet].
extension WalletPatterns on Wallet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wallet value)  $default,){
final _that = this;
switch (_that) {
case _Wallet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wallet value)?  $default,){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  double balance,  double escrowBalance,  List<WalletTransaction> transactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.userId,_that.balance,_that.escrowBalance,_that.transactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  double balance,  double escrowBalance,  List<WalletTransaction> transactions)  $default,) {final _that = this;
switch (_that) {
case _Wallet():
return $default(_that.userId,_that.balance,_that.escrowBalance,_that.transactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  double balance,  double escrowBalance,  List<WalletTransaction> transactions)?  $default,) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.userId,_that.balance,_that.escrowBalance,_that.transactions);case _:
  return null;

}
}

}

/// @nodoc


class _Wallet implements Wallet {
  const _Wallet({required this.userId, required this.balance, required this.escrowBalance, final  List<WalletTransaction> transactions = const <WalletTransaction>[]}): _transactions = transactions;
  

@override final  String userId;
@override final  double balance;
@override final  double escrowBalance;
 final  List<WalletTransaction> _transactions;
@override@JsonKey() List<WalletTransaction> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}


/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCopyWith<_Wallet> get copyWith => __$WalletCopyWithImpl<_Wallet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wallet&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.escrowBalance, escrowBalance) || other.escrowBalance == escrowBalance)&&const DeepCollectionEquality().equals(other._transactions, _transactions));
}


@override
int get hashCode => Object.hash(runtimeType,userId,balance,escrowBalance,const DeepCollectionEquality().hash(_transactions));

@override
String toString() {
  return 'Wallet(userId: $userId, balance: $balance, escrowBalance: $escrowBalance, transactions: $transactions)';
}


}

/// @nodoc
abstract mixin class _$WalletCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$WalletCopyWith(_Wallet value, $Res Function(_Wallet) _then) = __$WalletCopyWithImpl;
@override @useResult
$Res call({
 String userId, double balance, double escrowBalance, List<WalletTransaction> transactions
});




}
/// @nodoc
class __$WalletCopyWithImpl<$Res>
    implements _$WalletCopyWith<$Res> {
  __$WalletCopyWithImpl(this._self, this._then);

  final _Wallet _self;
  final $Res Function(_Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? balance = null,Object? escrowBalance = null,Object? transactions = null,}) {
  return _then(_Wallet(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,escrowBalance: null == escrowBalance ? _self.escrowBalance : escrowBalance // ignore: cast_nullable_to_non_nullable
as double,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<WalletTransaction>,
  ));
}


}

// dart format on
