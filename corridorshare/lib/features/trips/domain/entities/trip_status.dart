/// Lifecycle status of a traveller's trip.
enum TripStatus {
  open,
  full,
  completed,
  cancelled;

  bool canTransitionTo(TripStatus next) {
    if (this == next) return true;
    switch (this) {
      case TripStatus.open:
        return next == TripStatus.full ||
            next == TripStatus.completed ||
            next == TripStatus.cancelled;
      case TripStatus.full:
        return next == TripStatus.open ||
            next == TripStatus.completed ||
            next == TripStatus.cancelled;
      case TripStatus.completed:
      case TripStatus.cancelled:
        return false;
    }
  }
}
