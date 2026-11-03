import 'package:get/get.dart';

/// العمليات المالية الحساسة الخاضعة لبوابات التكامل المعمارية المشروطة
enum ControlledMutation {
  walletDeposit,
  walletWithdrawal,
  walletTransfer,
  invoiceCreation,
  invoiceSettlement,
  creditProcurementApproval,
  requestApproval,
  requestCancellation,
}

/// خدمة بوابات التكامل المعماري المشروط (Controlled Integration Gate Service)
class IntegrationGateService extends GetxService {
  IntegrationGateService._();

  static IntegrationGateService instance = IntegrationGateService._();

  static IntegrationGateService get to =>
      Get.isRegistered<IntegrationGateService>()
      ? Get.find<IntegrationGateService>()
      : instance;

  final Map<ControlledMutation, bool> _mutationGates = {
    ControlledMutation.walletDeposit: false,
    ControlledMutation.walletWithdrawal: false,
    ControlledMutation.walletTransfer: false,
    ControlledMutation.invoiceCreation: false,
    ControlledMutation.invoiceSettlement: false,
    ControlledMutation.creditProcurementApproval: false,
    ControlledMutation.requestApproval: false,
    ControlledMutation.requestCancellation: false,
  };

  bool isLiveMutationEnabled(ControlledMutation mutation) {
    return _mutationGates[mutation] ?? false;
  }

  String getGateExplanation(ControlledMutation mutation) {
    switch (mutation) {
      case ControlledMutation.walletDeposit:
      case ControlledMutation.walletWithdrawal:
      case ControlledMutation.walletTransfer:
        return 'عمليات السحب والإيداع والتحويل المالي محصنة حالياً ببوابة أمان محاسبية مشروطة لحين اعتماد مطابقة القيود.';
      case ControlledMutation.invoiceCreation:
      case ControlledMutation.invoiceSettlement:
        return 'إصدار الفواتير الفعلي والسداد المالي المباشر مقفل في هذه النسخة التطويرية؛ يمكنك استعراض وطباعة الفواتير فقط.';
      case ControlledMutation.creditProcurementApproval:
      case ControlledMutation.requestApproval:
      case ControlledMutation.requestCancellation:
        return 'اعتماد وإلغاء طلبات التوريد مقفل تجريبياً لحماية تسوية الأرصدة التلقائية.';
    }
  }
}
