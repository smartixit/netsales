import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// حالة نقطة البيع التجارية (POS Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\PosStatus)
enum PosStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  pending('PENDING'),
  rejected('REJECTED'),
  banned('BANNED'),
  unknown('UNKNOWN');

  final String wireValue;
  const PosStatus(this.wireValue);

  static PosStatus fromWire(String? raw) {
    if (raw == null) return PosStatus.unknown;
    final trimmed = raw.trim();
    for (final status in PosStatus.values) {
      if (status.wireValue == trimmed) return status;
    }
    return PosStatus.unknown;
  }

  bool get isKnown => this != PosStatus.unknown;
  bool get isActive => this == PosStatus.active;

  String get label {
    switch (this) {
      case PosStatus.active:
        return 'نشط';
      case PosStatus.inactive:
        return 'مجمد';
      case PosStatus.pending:
        return 'قيد المراجعة';
      case PosStatus.rejected:
        return 'مرفوض';
      case PosStatus.banned:
        return 'محظور';
      case PosStatus.unknown:
        return 'غير محدد';
    }
  }

  SemanticTone get tone {
    switch (this) {
      case PosStatus.active:
        return SemanticTone.success;
      case PosStatus.inactive:
        return SemanticTone.warning;
      case PosStatus.pending:
        return SemanticTone.primary;
      case PosStatus.rejected:
      case PosStatus.banned:
        return SemanticTone.danger;
      case PosStatus.unknown:
        return SemanticTone.neutral;
    }
  }
}
