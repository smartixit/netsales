import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/debts/domain/entities/outstanding_invoice_entity.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/debts/domain/repositories/debts_repository.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  final DebtsRemoteDataSource remoteDataSource;

  const DebtsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<PosDebtSummaryEntity>> getReceivablesSummary({
    int? networkId,
    int? posId,
  }) {
    return remoteDataSource.getReceivablesSummary(networkId: networkId, posId: posId);
  }

  @override
  Future<ApiResponse<List<PosOutstandingInvoiceEntity>>> getOutstandingInvoices({
    required int networkId,
    required int posId,
  }) {
    return remoteDataSource.getOutstandingInvoices(networkId: networkId, posId: posId);
  }

  @override
  Future<ApiResponse<List<PosRepaymentEntity>>> getRepayments({
    required int networkId,
    int? posId,
    int page = 1,
    int perPage = 20,
  }) {
    return remoteDataSource.getRepayments(networkId: networkId, posId: posId, page: page, perPage: perPage);
  }

  @override
  Future<ApiResponse<PosRepaymentEntity>> getRepaymentById(int repaymentId) {
    return remoteDataSource.getRepaymentById(repaymentId);
  }

  @override
  Future<ApiResponse<PosRepaymentEntity>> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? idempotencyKey,
  }) {
    return remoteDataSource.collectRepayment(
      networkId: networkId,
      posId: posId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<PosRepaymentEntity>> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
    String? idempotencyKey,
  }) {
    return remoteDataSource.reverseRepayment(
      repaymentId: repaymentId,
      reversalReason: reversalReason,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<ApiResponse<PosWalletEntity>> updateCreditLimit({
    required int walletId,
    double? creditLimit,
  }) {
    return remoteDataSource.updateCreditLimit(
      walletId: walletId,
      creditLimit: creditLimit,
    );
  }
}

