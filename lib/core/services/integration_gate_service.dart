import 'package:get/get.dart';

/// ============================================================================
/// العمليات المالية الحساسة الخاضعة لبوابات التكامل المعمارية المشروطة
/// ============================================================================
enum ControlledMutation {
  /// إيداع نقدي في المحفظة
  walletDeposit,

  /// سحب نقدي من المحفظة
  walletWithdrawal,

  /// تحويل مالي بين المحافظ
  walletTransfer,

  /// إصدار فاتورة مبيعات مباشرة
  invoiceCreation,

  /// سداد مالي لفاتورة
  invoiceSettlement,

  /// اعتماد طلب توريد آجل يغير رصيد المحفظة
  creditProcurementApproval,

  /// اعتماد طلب توريد باقات
  requestApproval,

  /// إلغاء طلب توريد باقات
  requestCancellation,
}

/// ============================================================================
/// خدمة بوابات التكامل المعماري المشروط (Controlled Integration Gate Service)
/// ============================================================================
/// تضمن عزل وإقفال العمليات المالية ذات الأثر التغييري على الأرصدة (Balance-Changing Mutations)
/// أثناء المرحلة الرابعة لحين إتمام التحقق التعاقدي والمحاسبي الميداني بنسبة 100%.
class IntegrationGateService extends GetxService {
  IntegrationGateService._();

  static IntegrationGateService instance = IntegrationGateService._();

  static IntegrationGateService get to =>
      Get.isRegistered<IntegrationGateService>()
          ? Get.find<IntegrationGateService>()
          : instance;

  /// خريطة حالة فتح البوابات للإنتاج
  /// مغلقة افتراضياً لكافة العمليات المالية الحساسة في هذه المرحلة (Milestone 1)
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

  /// التحقق مما إذا كانت الحركة المالية الحساسة مصرحة للتنفيذ المباشر على الخادم
  bool isLiveMutationEnabled(ControlledMutation mutation) {
    return _mutationGates[mutation] ?? false;
  }

  /// إرجاع رسالة توضيحية موحدة للمستخدم توضح حالة القفل الآمن
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

