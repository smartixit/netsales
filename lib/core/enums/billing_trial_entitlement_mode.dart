import 'package:netsales/core/presentation/enums/semantic_tone.dart';

enum BillingTrialEntitlementMode {
  fullPlan('FULL_PLAN', 'كامل مزايا الخطة', SemanticTone.success),
  restricted('RESTRICTED', 'مزايا محددة', SemanticTone.warning),
  none('NONE', 'دون مزايا تشغيلية', SemanticTone.neutral),
  unknown('UNKNOWN', 'نمط استحقاق غير معروف', SemanticTone.neutral);

  const BillingTrialEntitlementMode(
    this.wireValue,
    this.label,
    this.tone,
  );

  final String wireValue;
  final String label;
  final SemanticTone tone;

  static BillingTrialEntitlementMode fromWire(String? raw) {
    if (raw == null) return BillingTrialEntitlementMode.unknown;
    final value = raw.trim().toUpperCase();
    return values.firstWhere(
      (mode) => mode.wireValue == value,
      orElse: () => BillingTrialEntitlementMode.unknown,
    );
  }
}
