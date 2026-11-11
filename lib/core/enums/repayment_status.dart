import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// حالات سند سداد المديونية المعتمدة في عقد Laravel.
enum RepaymentStatus {
  completed('COMPLETED', 'سداد مكتمل', SemanticTone.success),
  reversed('REVERSED', 'سند معكوس', SemanticTone.danger),
  unknown('UNKNOWN', 'حالة غير معروفة', SemanticTone.neutral);

  const RepaymentStatus(this.wireValue, this.label, this.tone);

  final String wireValue;
  final String label;
  final SemanticTone tone;

  bool get isCompleted => this == RepaymentStatus.completed;
  bool get isReversed => this == RepaymentStatus.reversed;
  bool get isKnown => this != RepaymentStatus.unknown;

  /// قراءة الحالة السلكية بأمان مع منع الانهيار عند إضافة حالات خادم جديدة
  static RepaymentStatus fromWire(String? value) {
    if (value == null) return RepaymentStatus.unknown;
    return values.firstWhere(
      (status) => status.wireValue.toUpperCase() == value.toUpperCase(),
      orElse: () => RepaymentStatus.unknown,
    );
  }
}

