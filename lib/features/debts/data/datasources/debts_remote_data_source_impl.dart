import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:netsales/features/debts/data/models/debt_summary_model.dart';
import 'package:netsales/features/debts/data/models/outstanding_invoice_model.dart';
import 'package:netsales/features/debts/data/models/repayment_model.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';

class DebtsRemoteDataSourceImpl implements DebtsRemoteDataSource {
  const DebtsRemoteDataSourceImpl();

  @override
  Future<ApiResponse<PosDebtSummaryModel>> getReceivablesSummary({
    int? networkId,
    int? posId,
  }) {
    final queryParams = <String, dynamic>{
      ...?networkId != null ? {'network_id': networkId} : null,
      ...?posId != null ? {'pos_id': posId} : null,
    };

    return ApiService.instance.get<PosDebtSummaryModel>(
      ApiConstants.posDebtsSummary,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => PosDebtSummaryModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<PosOutstandingInvoiceModel>>> getOutstandingInvoices({
    required int networkId,
    required int posId,
  }) {
    return ApiService.instance.getList<PosOutstandingInvoiceModel>(
      ApiConstants.posDebtsInvoices,
      queryParameters: {
        'network_id': networkId,
        'pos_id': posId,
      },
      fromJson: (json) => PosOutstandingInvoiceModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<List<PosRepaymentModel>>> getRepayments({
    required int networkId,
    int? posId,
    int page = 1,
    int perPage = 20,
  }) {
    final queryParams = <String, dynamic>{
      'network_id': networkId,
      ...?posId != null ? {'pos_id': posId} : null,
      'page': page,
      'per_page': perPage,
    };

    return ApiService.instance.getList<PosRepaymentModel>(
      ApiConstants.posDebtsRepayments,
      queryParameters: queryParams,
      fromJson: (json) => PosRepaymentModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PosRepaymentModel>> getRepaymentById(int repaymentId) {
    return ApiService.instance.get<PosRepaymentModel>(
      ApiConstants.posDebtRepayment(repaymentId),
      fromJson: (json) => PosRepaymentModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PosRepaymentModel>> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? idempotencyKey,
  }) {
    final body = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      'amount': amount,
      'payment_method': paymentMethod,
      ...?referenceNumber != null && referenceNumber.isNotEmpty ? {'reference_number': referenceNumber} : null,
      ...?notes != null && notes.isNotEmpty ? {'notes': notes} : null,
    };

    return ApiService.instance.post<PosRepaymentModel>(
      ApiConstants.posDebtsRepayments,
      data: body,
      idempotencyKey: idempotencyKey,
      fromJson: (json) => PosRepaymentModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PosRepaymentModel>> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
    String? idempotencyKey,
  }) {
    final body = <String, dynamic>{
      'reversal_reason': reversalReason,
    };

    return ApiService.instance.post<PosRepaymentModel>(
      ApiConstants.posDebtRepaymentReverse(repaymentId),
      data: body,
      idempotencyKey: idempotencyKey,
      fromJson: (json) => PosRepaymentModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  @override
  Future<ApiResponse<PosWalletModel>> updateCreditLimit({
    required int walletId,
    double? creditLimit,
  }) {
    final body = <String, dynamic>{
      'credit_limit': creditLimit,
    };

    return ApiService.instance.put<PosWalletModel>(
      ApiConstants.posWalletCreditLimit(walletId),
      data: body,
      fromJson: (json) => PosWalletModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}
