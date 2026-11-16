class PosWalletSummaryViewModel {
  const PosWalletSummaryViewModel({
    required this.isOverdrawn,
    required this.formattedBalance,
    required this.creditLimitLabel,
    required this.availableOverdraftLabel,
  });

  final bool isOverdrawn;
  final String formattedBalance;
  final String creditLimitLabel;
  final String availableOverdraftLabel;
}
