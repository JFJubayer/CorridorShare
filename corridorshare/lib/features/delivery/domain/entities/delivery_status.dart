/// Status of an active delivery tracking lifecycle.
enum DeliveryStatus {
  matched,
  inTransit,
  delivered,
  disputed,
  cancelled;

  bool canTransitionTo(DeliveryStatus next) {
    if (this == next) return true;
    switch (this) {
      case DeliveryStatus.matched:
        return next == DeliveryStatus.inTransit ||
            next == DeliveryStatus.cancelled;
      case DeliveryStatus.inTransit:
        return next == DeliveryStatus.delivered ||
            next == DeliveryStatus.disputed;
      case DeliveryStatus.disputed:
        return next == DeliveryStatus.delivered ||
            next == DeliveryStatus.cancelled;
      case DeliveryStatus.delivered:
      case DeliveryStatus.cancelled:
        return false;
    }
  }

  bool get isTerminal =>
      this == DeliveryStatus.delivered || this == DeliveryStatus.cancelled;
}
