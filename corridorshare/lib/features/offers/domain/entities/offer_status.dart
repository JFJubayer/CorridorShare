/// Status lifecycle for an Offer negotiated between sender and traveller.
enum OfferStatus {
  pendingTraveller,
  pendingSender,
  accepted,
  rejected,
  cancelled;

  bool canTransitionTo(OfferStatus next) {
    if (this == next) return true;
    switch (this) {
      case OfferStatus.pendingTraveller:
        return next == OfferStatus.pendingSender ||
            next == OfferStatus.accepted ||
            next == OfferStatus.rejected ||
            next == OfferStatus.cancelled;
      case OfferStatus.pendingSender:
        return next == OfferStatus.pendingTraveller ||
            next == OfferStatus.accepted ||
            next == OfferStatus.rejected ||
            next == OfferStatus.cancelled;
      case OfferStatus.accepted:
      case OfferStatus.rejected:
      case OfferStatus.cancelled:
        return false;
    }
  }

  bool get isTerminal =>
      this == OfferStatus.accepted ||
      this == OfferStatus.rejected ||
      this == OfferStatus.cancelled;
}
