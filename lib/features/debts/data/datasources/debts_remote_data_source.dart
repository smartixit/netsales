import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/debts/data/models/debt_summary_model.dart';
import 'package:netsales/features/debts/data/models/outstanding_invoice_model.dart';
import 'package:netsales/features/debts/data/models/repayment_model.dart';
import 'package:netsales/features/partners/data/models/pos_wallet_model.dart';

abstract class DebtsRemoteDataSource {
  /// جلب ملخص الذمم المدينة وتحليل أعمار الديون
  Future<ApiResponse<PosDebtSummaryModel>> getReceivablesSummary({
    int? networkId,
    int? posId,
  });

  /// جلب فواتير البيع الآجل المستحقة السداد مرتبة FIFO
  Future<ApiResponse<List<PosOutstandingInvoiceModel>>> getOutstandingInvoices({
    required int networkId,
    required int posId,
  });

  /// جلب سجل سندات السداد
  Future<ApiResponse<List<PosRepaymentModel>>> getRepayments({
    required int networkId,
    int? posId,
    int page = 1,
    int perPage = 20,
  });

  /// جلب تفاصيل سند سداد محدد مع توزيعاته
  Future<ApiResponse<PosRepaymentModel>> getRepaymentById(int repaymentId);

  /// تحصيل سداد مديونية نقطة بيع مع التوزيع الحتمي
  Future<ApiResponse<PosRepaymentModel>> collectRepayment({
    required int networkId,
    required int posId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    String? idempotencyKey,
  });

  /// عكس سند سداد مديونية وإعادة قيد المديونية
  Future<ApiResponse<PosRepaymentModel>> reverseRepayment({
    required int repaymentId,
    required String reversalReason,
    String? idempotencyKey,
  });

  /// تحديث السقف الائتماني لمحفظة نقطة البيع
  Future<ApiResponse<PosWalletModel>> updateCreditLimit({
    required int walletId,
    double? creditLimit,
  });
}

