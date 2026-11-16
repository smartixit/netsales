import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/workspace/presentation/models/pos_wallet_summary_view_model.dart';

class PosWalletSummaryMapper {
  const PosWalletSummaryMapper._();

  static PosWalletSummaryViewModel? map(PosWalletEntity? wallet) {
    if (wallet == null) return null;
    return PosWalletSummaryViewModel(
      isOverdrawn: wallet.isOverdrawn,
      formattedBalance: AmountFormatter.format(wallet.walletBalance.toString()),
      creditLimitLabel: wallet.creditLimit == null
          ? 'غير محدد'
          : '${AmountFormatter.format(wallet.creditLimit.toString())} ر.ي',
      availableOverdraftLabel:
          '${AmountFormatter.format(wallet.availableOverdraftCapacity.toString())} ر.ي',
    );
  }
}
