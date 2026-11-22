import 'package:equatable/equatable.dart';

/// مؤشرات المحفظة المالية المعتمدة لمزود الشبكة
class NetworkWalletMetricsEntity extends Equatable {
  const NetworkWalletMetricsEntity({
    required this.walletId,
    required this.balance,
    required this.isActive,
    required this.todayCashCollected,
  });

  final int walletId;
  final String balance;
  final bool isActive;
  final String todayCashCollected;

  @override
  List<Object?> get props => [
    walletId,
    balance,
    isActive,
    todayCashCollected,
  ];
}
