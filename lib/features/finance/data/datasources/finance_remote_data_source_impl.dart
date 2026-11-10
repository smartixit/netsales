import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:netsales/features/finance/data/models/network_wallet_models.dart';
import 'package:netsales/features/finance/data/models/pos_repayment_models.dart';
import 'package:netsales/features/finance/data/models/pos_wallet_models.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  const FinanceRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<PosWalletModel>>> getPosWallets({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<PosWalletModel>>(
      ApiConstants.posWallets,
      queryParameters: query,
      fromJson: (data) => (data as List)
          .map((i) => PosWalletModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<PosWalletModel>> getPosWalletByNetworkAndPos(
    int networkId,
    int posId,
  ) {
    return ApiService.instance.get<PosWalletModel>(
      ApiConstants.posWalletByNetworkPos(networkId, posId),
      fromJson: (data) => PosWalletModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<PosWalletLogModel>>> getPosWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<PosWalletLogModel>>(
      ApiConstants.posWalletLogs(walletId),
      queryParameters: query,
      fromJson: (data) => (data as List)
          .map((i) => PosWalletLogModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<List<NetworkWalletModel>>> getNetworkWallets({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<NetworkWalletModel>>(
      ApiConstants.networkWallets,
      queryParameters: query,
      fromJson: (data) => (data as List)
          .map((i) => NetworkWalletModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<NetworkWalletModel>> getNetworkWalletById(int walletId) {
    return ApiService.instance.get<NetworkWalletModel>(
      ApiConstants.networkWallet(walletId),
      fromJson: (data) =>
          NetworkWalletModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<NetworkWalletLogModel>>> getNetworkWalletLogs(
    int walletId, {
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<NetworkWalletLogModel>>(
      ApiConstants.networkWalletLogs(walletId),
      queryParameters: query,
      fromJson: (data) => (data as List)
          .map((i) => NetworkWalletLogModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getDebtSummary({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<Map<String, dynamic>>(
      ApiConstants.posDebtsSummary,
      queryParameters: query,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  @override
  Future<ApiResponse<List<InvoiceModel>>> getOutstandingInvoices({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<InvoiceModel>>(
      ApiConstants.posDebtsInvoices,
      queryParameters: query,
      fromJson: (data) => (data as List)
          .map((i) => InvoiceModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<List<PosRepaymentModel>>> getRepayments({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<PosRepaymentModel>>(
      ApiConstants.posDebtsRepayments,
      queryParameters: query,
      fromJson: (data) => (data as List)
          .map((i) => PosRepaymentModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<PosRepaymentModel>> getRepaymentById(int repaymentId) {
    return ApiService.instance.get<PosRepaymentModel>(
      ApiConstants.posDebtRepayment(repaymentId),
      fromJson: (data) =>
          PosRepaymentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PosRepaymentModel>> collectRepayment(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<PosRepaymentModel>(
      ApiConstants.posDebtsRepayments,
      data: data,
      idempotencyKey: idempotencyKey,
      fromJson: (resData) =>
          PosRepaymentModel.fromJson(resData as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<PosRepaymentModel>> reverseRepayment(
    int repaymentId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<PosRepaymentModel>(
      ApiConstants.posDebtRepaymentReverse(repaymentId),
      data: data,
      idempotencyKey: idempotencyKey,
      fromJson: (resData) =>
          PosRepaymentModel.fromJson(resData as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<dynamic>> transferFromNetworkToPos(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.posWalletTransferFromNetwork,
      data: data,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<dynamic>> transferPosToNetwork(
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.posWalletTransferToNetwork,
      data: data,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<dynamic>> updatePosCreditLimit(
    int posWalletId, {
    required double? creditLimit,
  }) {
    return ApiService.instance.put<dynamic>(
      ApiConstants.posWalletCreditLimit(posWalletId),
      data: {'credit_limit': creditLimit},
    );
  }

  @override
  Future<ApiResponse<dynamic>> depositToPosWallet(
    int posWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.posWalletDeposit(posWalletId),
      data: {
        'amount': amount,
        'statement': statement,
        if (logDate != null && logDate.isNotEmpty) 'log_date': logDate,
      },
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<dynamic>> withdrawFromPosWallet(
    int posWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.posWalletWithdraw(posWalletId),
      data: {
        'amount': amount,
        'statement': statement,
        if (logDate != null && logDate.isNotEmpty) 'log_date': logDate,
      },
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<dynamic>> depositToNetworkWallet(
    int networkWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.networkWalletDeposit(networkWalletId),
      data: {
        'amount': amount,
        'statement': statement,
        if (logDate != null && logDate.isNotEmpty) 'log_date': logDate,
      },
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<dynamic>> withdrawFromNetworkWallet(
    int networkWalletId, {
    required double amount,
    required String statement,
    String? logDate,
    required String idempotencyKey,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.networkWalletWithdraw(networkWalletId),
      data: {
        'amount': amount,
        'statement': statement,
        if (logDate != null && logDate.isNotEmpty) 'log_date': logDate,
      },
      idempotencyKey: idempotencyKey,
    );
  }
}
