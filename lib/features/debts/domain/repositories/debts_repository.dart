import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/features/debts/domain/entities/outstanding_invoice_entity.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';

abstract class DebtsRepository {
  Future<ApiResponse<PosDebtSummaryEntity>> getReceivablesSummary({
    int? networkId,
    int? posId,
  });

  Future<ApiResponse<List<PosOutstandingInvoiceEntity>>> getOutstandingInvoices({
    required int networkId,
    required int posId,
  });

  Future<ApiResponse<List<PosRepaymentEntity>>> getRepayments({
    required int networkId,
    int? posId,
    int page = 1,
    int perPage = 20,
  });

  Future<ApiResponse<PosRepaymentEntity>> getRepaymentById(int repaymentId);

  Future<ApiResponse<PosRepaymentEntity>> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? idempotencyKey,
  });

  Future<ApiResponse<PosRepaymentEntity>> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
    String? idempotencyKey,
  });

  Future<ApiResponse<PosWalletEntity>> updateCreditLimit({
    required int walletId,
    double? creditLimit,
  });
}

