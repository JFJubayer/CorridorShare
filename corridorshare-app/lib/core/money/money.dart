/// An integer, minor-unit money value. CorridorShare currently uses BDT, where
/// the UI displays whole taka but the domain still retains exact minor units.
class Money implements Comparable<Money> {
  const Money._(this.minorUnits);

  factory Money.fromBdt(num amount) {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be a positive finite amount');
    }
    return Money._((amount * 100).round());
  }

  factory Money.fromMinorUnits(int minorUnits) {
    if (minorUnits < 0) {
      throw ArgumentError.value(minorUnits, 'minorUnits', 'cannot be negative');
    }
    return Money._(minorUnits);
  }

  static const zero = Money._(0);

  final int minorUnits;

  double get asBdt => minorUnits / 100;
  bool get isPositive => minorUnits > 0;

  Money operator +(Money other) => Money._(minorUnits + other.minorUnits);

  Money operator -(Money other) {
    if (other.minorUnits > minorUnits) {
      throw StateError('Money cannot become negative.');
    }
    return Money._(minorUnits - other.minorUnits);
  }

  @override
  int compareTo(Money other) => minorUnits.compareTo(other.minorUnits);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minorUnits == minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;
}
