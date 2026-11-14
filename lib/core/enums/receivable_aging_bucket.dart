import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// Contracted age ranges used by receivables and debt-aging reports.
enum ReceivableAgingBucket {
  days0To30('0_30', 'حتى 30 يوماً', SemanticTone.neutral),
  days31To60('31_60', '31–60 يوماً', SemanticTone.warning),
  days61To90('61_90', '61–90 يوماً', SemanticTone.warning),
  over90('OVER_90', 'أكثر من 90 يوماً', SemanticTone.danger),
  unknown('UNKNOWN', 'تصنيف عمر الدين غير معروف', SemanticTone.neutral);

  const ReceivableAgingBucket(this.wireValue, this.label, this.tone);

  final String wireValue;
  final String label;
  final SemanticTone tone;

  bool get isKnown => this != ReceivableAgingBucket.unknown;

  static ReceivableAgingBucket fromWire(String? raw) {
    if (raw == null) return ReceivableAgingBucket.unknown;
    final normalized = raw.trim().toUpperCase();
    return values.firstWhere(
      (bucket) => bucket.wireValue == normalized,
      orElse: () => ReceivableAgingBucket.unknown,
    );
  }
}
