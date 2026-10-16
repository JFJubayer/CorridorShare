// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlatformMetrics {

 int get totalUsers; int get totalTrips; int get totalParcels; int get activeDeliveries; int get completedDeliveries; double get totalVolumeBdt; int get openDisputesCount;
/// Create a copy of PlatformMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformMetricsCopyWith<PlatformMetrics> get copyWith => _$PlatformMetricsCopyWithImpl<PlatformMetrics>(this as PlatformMetrics, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformMetrics&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.totalParcels, totalParcels) || other.totalParcels == totalParcels)&&(identical(other.activeDeliveries, activeDeliveries) || other.activeDeliveries == activeDeliveries)&&(identical(other.completedDeliveries, completedDeliveries) || other.completedDeliveries == completedDeliveries)&&(identical(other.totalVolumeBdt, totalVolumeBdt) || other.totalVolumeBdt == totalVolumeBdt)&&(identical(other.openDisputesCount, openDisputesCount) || other.openDisputesCount == openDisputesCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalUsers,totalTrips,totalParcels,activeDeliveries,completedDeliveries,totalVolumeBdt,openDisputesCount);

@override
String toString() {
  return 'PlatformMetrics(totalUsers: $totalUsers, totalTrips: $totalTrips, totalParcels: $totalParcels, activeDeliveries: $activeDeliveries, completedDeliveries: $completedDeliveries, totalVolumeBdt: $totalVolumeBdt, openDisputesCount: $openDisputesCount)';
}


}

/// @nodoc
abstract mixin class $PlatformMetricsCopyWith<$Res>  {
  factory $PlatformMetricsCopyWith(PlatformMetrics value, $Res Function(PlatformMetrics) _then) = _$PlatformMetricsCopyWithImpl;
@useResult
$Res call({
 int totalUsers, int totalTrips, int totalParcels, int activeDeliveries, int completedDeliveries, double totalVolumeBdt, int openDisputesCount
});




}
/// @nodoc
class _$PlatformMetricsCopyWithImpl<$Res>
    implements $PlatformMetricsCopyWith<$Res> {
  _$PlatformMetricsCopyWithImpl(this._self, this._then);

  final PlatformMetrics _self;
  final $Res Function(PlatformMetrics) _then;

/// Create a copy of PlatformMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = null,Object? totalTrips = null,Object? totalParcels = null,Object? activeDeliveries = null,Object? completedDeliveries = null,Object? totalVolumeBdt = null,Object? openDisputesCount = null,}) {
  return _then(_self.copyWith(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,totalParcels: null == totalParcels ? _self.totalParcels : totalParcels // ignore: cast_nullable_to_non_nullable
as int,activeDeliveries: null == activeDeliveries ? _self.activeDeliveries : activeDeliveries // ignore: cast_nullable_to_non_nullable
as int,completedDeliveries: null == completedDeliveries ? _self.completedDeliveries : completedDeliveries // ignore: cast_nullable_to_non_nullable
as int,totalVolumeBdt: null == totalVolumeBdt ? _self.totalVolumeBdt : totalVolumeBdt // ignore: cast_nullable_to_non_nullable
as double,openDisputesCount: null == openDisputesCount ? _self.openDisputesCount : openDisputesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformMetrics].
extension PlatformMetricsPatterns on PlatformMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformMetrics value)  $default,){
final _that = this;
switch (_that) {
case _PlatformMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUsers,  int totalTrips,  int totalParcels,  int activeDeliveries,  int completedDeliveries,  double totalVolumeBdt,  int openDisputesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformMetrics() when $default != null:
return $default(_that.totalUsers,_that.totalTrips,_that.totalParcels,_that.activeDeliveries,_that.completedDeliveries,_that.totalVolumeBdt,_that.openDisputesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUsers,  int totalTrips,  int totalParcels,  int activeDeliveries,  int completedDeliveries,  double totalVolumeBdt,  int openDisputesCount)  $default,) {final _that = this;
switch (_that) {
case _PlatformMetrics():
return $default(_that.totalUsers,_that.totalTrips,_that.totalParcels,_that.activeDeliveries,_that.completedDeliveries,_that.totalVolumeBdt,_that.openDisputesCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUsers,  int totalTrips,  int totalParcels,  int activeDeliveries,  int completedDeliveries,  double totalVolumeBdt,  int openDisputesCount)?  $default,) {final _that = this;
switch (_that) {
case _PlatformMetrics() when $default != null:
return $default(_that.totalUsers,_that.totalTrips,_that.totalParcels,_that.activeDeliveries,_that.completedDeliveries,_that.totalVolumeBdt,_that.openDisputesCount);case _:
  return null;

}
}

}

/// @nodoc


class _PlatformMetrics implements PlatformMetrics {
  const _PlatformMetrics({required this.totalUsers, required this.totalTrips, required this.totalParcels, required this.activeDeliveries, required this.completedDeliveries, required this.totalVolumeBdt, required this.openDisputesCount});
  

@override final  int totalUsers;
@override final  int totalTrips;
@override final  int totalParcels;
@override final  int activeDeliveries;
@override final  int completedDeliveries;
@override final  double totalVolumeBdt;
@override final  int openDisputesCount;

/// Create a copy of PlatformMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformMetricsCopyWith<_PlatformMetrics> get copyWith => __$PlatformMetricsCopyWithImpl<_PlatformMetrics>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformMetrics&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.totalParcels, totalParcels) || other.totalParcels == totalParcels)&&(identical(other.activeDeliveries, activeDeliveries) || other.activeDeliveries == activeDeliveries)&&(identical(other.completedDeliveries, completedDeliveries) || other.completedDeliveries == completedDeliveries)&&(identical(other.totalVolumeBdt, totalVolumeBdt) || other.totalVolumeBdt == totalVolumeBdt)&&(identical(other.openDisputesCount, openDisputesCount) || other.openDisputesCount == openDisputesCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalUsers,totalTrips,totalParcels,activeDeliveries,completedDeliveries,totalVolumeBdt,openDisputesCount);

@override
String toString() {
  return 'PlatformMetrics(totalUsers: $totalUsers, totalTrips: $totalTrips, totalParcels: $totalParcels, activeDeliveries: $activeDeliveries, completedDeliveries: $completedDeliveries, totalVolumeBdt: $totalVolumeBdt, openDisputesCount: $openDisputesCount)';
}


}

/// @nodoc
abstract mixin class _$PlatformMetricsCopyWith<$Res> implements $PlatformMetricsCopyWith<$Res> {
  factory _$PlatformMetricsCopyWith(_PlatformMetrics value, $Res Function(_PlatformMetrics) _then) = __$PlatformMetricsCopyWithImpl;
@override @useResult
$Res call({
 int totalUsers, int totalTrips, int totalParcels, int activeDeliveries, int completedDeliveries, double totalVolumeBdt, int openDisputesCount
});




}
/// @nodoc
class __$PlatformMetricsCopyWithImpl<$Res>
    implements _$PlatformMetricsCopyWith<$Res> {
  __$PlatformMetricsCopyWithImpl(this._self, this._then);

  final _PlatformMetrics _self;
  final $Res Function(_PlatformMetrics) _then;

/// Create a copy of PlatformMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = null,Object? totalTrips = null,Object? totalParcels = null,Object? activeDeliveries = null,Object? completedDeliveries = null,Object? totalVolumeBdt = null,Object? openDisputesCount = null,}) {
  return _then(_PlatformMetrics(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,totalParcels: null == totalParcels ? _self.totalParcels : totalParcels // ignore: cast_nullable_to_non_nullable
as int,activeDeliveries: null == activeDeliveries ? _self.activeDeliveries : activeDeliveries // ignore: cast_nullable_to_non_nullable
as int,completedDeliveries: null == completedDeliveries ? _self.completedDeliveries : completedDeliveries // ignore: cast_nullable_to_non_nullable
as int,totalVolumeBdt: null == totalVolumeBdt ? _self.totalVolumeBdt : totalVolumeBdt // ignore: cast_nullable_to_non_nullable
as double,openDisputesCount: null == openDisputesCount ? _self.openDisputesCount : openDisputesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
