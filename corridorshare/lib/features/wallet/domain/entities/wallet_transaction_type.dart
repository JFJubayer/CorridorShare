enum WalletTransactionType {
  topUp,
  escrowHold,
  escrowRelease,
  refund;

  bool get isCredit =>
      this == WalletTransactionType.topUp ||
      this == WalletTransactionType.escrowRelease ||
      this == WalletTransactionType.refund;
}
