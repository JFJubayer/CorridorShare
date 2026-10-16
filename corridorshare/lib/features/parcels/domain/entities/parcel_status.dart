/// Lifecycle status of a sender's parcel.
enum ParcelStatus {
  open,
  matched,
  inTransit,
  delivered,
  cancelled,
  disputed;

  bool canTransitionTo(ParcelStatus next) {
    if (this == next) return true;
    switch (this) {
      case ParcelStatus.open:
        return next == ParcelStatus.matched || next == ParcelStatus.cancelled;
      case ParcelStatus.matched:
        return next == ParcelStatus.inTransit ||
            next == ParcelStatus.cancelled;
      case ParcelStatus.inTransit:
        return next == ParcelStatus.delivered || next == ParcelStatus.disputed;
      case ParcelStatus.disputed:
        return next == ParcelStatus.delivered || next == ParcelStatus.cancelled;
      case ParcelStatus.delivered:
      case ParcelStatus.cancelled:
        return false;
    }
  }
}
