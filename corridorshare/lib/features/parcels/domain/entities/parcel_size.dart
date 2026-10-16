enum ParcelSize {
  small,
  medium,
  large;

  String get displayName {
    switch (this) {
      case ParcelSize.small:
        return 'Small (fits in pocket/pouch)';
      case ParcelSize.medium:
        return 'Medium (fits in backpack)';
      case ParcelSize.large:
        return 'Large (luggage / box)';
    }
  }
}
