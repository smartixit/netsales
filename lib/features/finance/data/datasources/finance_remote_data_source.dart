import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/finance/data/models/network_wallet_models.dart';
import 'package:netsales/features/finance/data/models/pos_repayment_models.dart';
import 'package:netsales/features/finance/data/models/pos_wallet_models.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';

abstract interface class FinanceRemoteDataSource {
  Future<ApiResponse<List<PosWalletModel>>> getPosWallets({
    Map<String, dynamic>? query,
  });
  Future<ApiResponse<PosWalletModel>> getPosWalletByNetworkAndPos(
    int networkId,
    int posId,
  );
  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<List<NetworkWalletModel>>> getNetworkWallets({
    Map<String, dynamic>? query,
  });
  Future<ApiResponse<NetworkWalletModel>> getNetworkWalletById(int walletId);
  Future<ApiResponse<List<NetworkWalletLogModel>>> getNetworkWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<Map<String, dynamic>>> getDebtSummary({
    Map<String, dynamic>? query,
  });
  Future<ApiResponse<List<InvoiceModel>>> getOutstandingInvoices({
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<List<PosRepaymentModel>>> getRepayments({
    Map<String, dynamic>? query,
  });
  Future<ApiResponse<PosRepaymentModel>> getRepaymentById(int repaymentId);
  Future<ApiResponse<PosRepaymentModel>> collectRepayment(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });
  Future<ApiResponse<PosRepaymentModel>> reverseRepayment(
    int repaymentId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });

  Future<ApiResponse<dynamic>> transferFromNetworkToPos(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });

  Future<ApiResponse<dynamic>> transferPosToNetwork(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  });

  Future<ApiResponse<dynamic>> updatePosCreditLimit(
    int posWalletId, {
    required double? creditLimit,
  });

  Future<ApiResponse<dynamic>> depositToPosWallet(
    int posWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  });

  Future<ApiResponse<dynamic>> withdrawFromPosWallet(
    int posWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  });

  Future<ApiResponse<dynamic>> depositToNetworkWallet(
    int networkWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  });

  Future<ApiResponse<dynamic>> withdrawFromNetworkWallet(
    int networkWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  });
}
