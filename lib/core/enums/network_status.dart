import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// حالة مزود الشبكة التجاري (Network Status)
/// مطابق للقيم السلكية المعتمدة في netsales_api (App\Enums\NetworkStatus)
enum NetworkStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  pending('PENDING'),
  rejected('REJECTED'),
  banned('BANNED'),
  unknown('UNKNOWN');

  final String wireValue;
  const NetworkStatus(this.wireValue);

  static NetworkStatus fromWire(String? raw) {
    if (raw == null) return NetworkStatus.unknown;
    final trimmed = raw.trim();
    for (final status in NetworkStatus.values) {
      if (status.wireValue == trimmed) return status;
    }
    return NetworkStatus.unknown;
  }

  bool get isKnown => this != NetworkStatus.unknown;
  bool get isActive => this == NetworkStatus.active;

  String get label {
    switch (this) {
      case NetworkStatus.active:
        return 'نشط';
      case NetworkStatus.inactive:
        return 'مجمد';
      case NetworkStatus.pending:
        return 'قيد المراجعة';
      case NetworkStatus.rejected:
        return 'مرفوض';
      case NetworkStatus.banned:
        return 'محظور';
      case NetworkStatus.unknown:
        return 'غير محدد';
    }
  }

  SemanticTone get tone {
    switch (this) {
      case NetworkStatus.active:
        return SemanticTone.success;
      case NetworkStatus.inactive:
        return SemanticTone.warning;
      case NetworkStatus.pending:
        return SemanticTone.primary;
      case NetworkStatus.rejected:
      case NetworkStatus.banned:
        return SemanticTone.danger;
      case NetworkStatus.unknown:
        return SemanticTone.neutral;
    }
  }
}
